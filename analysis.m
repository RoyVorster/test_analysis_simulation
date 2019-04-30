function [PSD, f, spl, OASPL, info] = analysis(file_path, log_list, mode)
    %% Mode setting
    if ~exist('mode', 'var')
        mode = 'normal'; 
    end

    %% Check if in workspace
    file_name = split(file_path, ["/", "\"]);
    file_name = file_name{end};
    
    name = regexp(file_name, '.+(?=\.)', 'match'); name = name{1};
    assignin('base', 'name', name);
    
    disp(name);

    if ~evalin('base', "exist(name, 'var')")
        assignin('base', name, load(file_path));
    else
        disp("Selecting dataset already in workspace");
    end
    
    data = evalin('base', name + ".data");
        
    p = zeros(length(data(:, 1)), length(data(1,:)));
    for i = 1:length(data(1,:))
        p(:,i) = data(:,i) - mean(data(:,i));
    end

    %% Parse filename
    info = struct();
    info.name = name;

    % Retrieve info from file name
    rpm = regexp(file_name, '(?<=_rpm)\d{2,}', 'match');
    info.rpm = str2num(rpm{1});

    wind_speed = regexp(file_name, '(?<=_U)\d{1,}', 'match');
    info.wind_speed = str2num(wind_speed{1});

    %% Parameters    
    fs = 60000;
    info.f = info.rpm/60;               % Rotational frequency

    B = 2;                              % Number of blades
    info.bpf = info.f*B;                % BPF

    info.omega = 2*pi*info.f;           % Rotational velocity [rad/s]
    N_mic = 64;                         % Number of microphones

    data_len = 30;                      % Data length [s]

    % Parameters for pwelch
    info.window = 2^15;                 % Window length (it should be a power of 2)

    overlap = round(info.window/2);            % Overlapping between windows
    nfft = info.window;                 % Number of points to use in the PSD
    p_ref = 2e-6;                      % Reference pressure

    npr = fs/info.f;                    % Samples per rotation
    nrot = data_len*info.f;             % Total number of rotations
        
%     %% VKF
%     [a,c] = vkf(p(:,1), fs, info.f*[1:0.5:80], 1, 0.00000001*fs);
%     x = real(a.*c);
%     
%     tot = x(:,1);
%     for i = 2:length(x(1,:))
%         tot = tot + x(:,i);
%     end
%     
%     broadband = p(:,1) - tot;
% 
%     [PSD, f, spl, OASPL] = get_psd(tot, info.window, overlap, nfft, fs, p_ref);
%     [PSD_b, ~, spl_b, OASPL_b] = get_psd(broadband, info.window, overlap, nfft, fs, p_ref);
%     
%     spl = max(spl, 0);
%     
%     figure(10); semilogx(f, spl - 20, 'LineWidth', 1, 'DisplayName', "Tonal"); hold on;
%     semilogx(f, spl_b + spl, 'LineWidth', 1, 'DisplayName', "Full"); hold on;
%     semilogx(f, spl_b, 'LineWidth', 1, 'DisplayName', "Broadband");
%     grid on
%     
%     legend
% 
%     soundsc(tot,fs); 
%     pause(1);
%     soundsc(p(:,1), fs);
    
%     soundsc(p(:, 41), fs);

    %% Calculate PSD's
    PSD = init(info.window, log_list); 
    if (mode == "split_broadband_sree") || (mode == "split_tonal_sree")
        for i = 1:length(log_list)
            idx = log_list(i);

            broadband = tonal_splitting_sree(p, idx, npr, nrot);
            [PSD(:,i), f, spl(:,i), OASPL(:,i)] = get_psd(broadband, info.window, overlap, nfft, fs, p_ref);
            
            if mode == "split_tonal_sree"
                spl_bb = init(info.window, log_list); spl_full = init(info.window, log_list);
                PSD_bb = init(info.window, log_list); PSD_full = init(info.window, log_list);

                PSD_bb(:, i) = PSD(:,i); spl_bb(:,i) = spl(:,i); OASPL_bb(:,i) = OASPL(:, i);
                [PSD_full(:,i), ~, spl_full(:,i), OASPL_full(:,i)] = get_psd(p(:, idx), info.window, overlap, nfft, fs, p_ref);

                PSD(:,i) = PSD_full(:, i) - PSD_bb(:, i); spl(:,i) = spl_full(:, i) - spl_bb(:, i); OASPL(:, i) - OASPL_bb(:, i);
            end
        end
    elseif (mode == "split_broadband_visual") || (mode == "split_tonal_visual")
        for i = 1:length(log_list)
            idx = log_list(i);

%             p(:, idx) = highpass(p(:, idx), info.f*2.5, fs);

            [~, f, spl_f(:,i), ~] = get_psd(p(:, idx), info.window, overlap, nfft, fs, p_ref);

            [spl(:,i), spl_f, f] = tonal_splitting_visual(spl_f, f);

            PSD = []; OASPL = [];
            if mode == "split_tonal_visual"
                spl(:,i) = spl_f(:,i) - spl(:,i);
                spl = max(spl, 0);
            end
        end
    elseif (mode == "oaspl")
        oaspl_name = name + "_OASPL"; assignin('base', 'oaspl_name', oaspl_name);

        PSD = []; f = []; spl = []; OASPL = [];

        if ~evalin('base', "exist(oaspl_name, 'var')")
            [PSD, f, spl, OASPL] = get_psds(p, 1:N_mic, info.window, overlap, nfft, fs, p_ref);
            assignin('base', oaspl_name, OASPL);
        else
            disp("Selecting OASPL data already in workspace");
        end

        oaspl_data = evalin('base', oaspl_name);
        oaspl(oaspl_data);
    else
        [PSD, f, spl, OASPL] = get_psds(p, log_list, info.window, overlap, nfft, fs, p_ref);
    end
end

%% Functions
function [PSD, f, spl, OASPL] = get_psds(p, log_list, window, overlap, nfft, fs, p_ref)
    for i = 1:length(log_list)
        idx = log_list(i);

        [PSD(:,i), f, spl(:,i), OASPL(:,i)] = get_psd(p(:,idx), window, overlap, nfft, fs, p_ref);
    end
end

function [PSD, f, spl, OASPL] = get_psd(dat, window, overlap, nfft, fs, p_ref)
    [PSD, f] = pwelch(dat, window, overlap, nfft, fs);
    spl = 10*(log10(PSD/(p_ref^2)));
    OASPL = 20*log10(std(dat)/p_ref);
end

function [out] = init(window, log_list)
    out = zeros(window/2 + 1, length(log_list));
end