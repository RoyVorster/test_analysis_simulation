clc

%% Retrieve data

% If you want to add something. Add an entry in every one of these arrays.
% So an entry in file_names for the filename, mics for which microphones
% and modes for which mode. 

% You can also use split_broadband_visual and
% split_tonal_visual for nice split plots. Works quite well.

figure(1)

file_names = {'../matlab/Baseline_propeller_scaled/prop_U5_rpm4000.mat', ...
    '../matlab/Serrated_propeller_scaled/serrated_U5_rpm4000.mat'};

mics = {[41], [41], [41]};

modes = {["oaspl"], ...
    ["normal", "split_broadband_visual", "split_tonal_visual"], ["normal"]};

bg_noise = {0, 0, 0};

for i = 1:length(file_names)
    log_list = mics{i};
    file_path = file_names{i};
    
    bg_noise_on = bg_noise{i};

    m = modes{i};
    for k = 1:length(m)
        mode = m(k);

        [PSD, f, spl, OASPL, info] = analysis(file_path, log_list, mode, bg_noise_on);
        if mode ~= "oaspl"
            figure(1)

            for j = 1:length(log_list)
                line_width = 1;
                if mode == "split_broadband_visual"
                    line_width = 1.5; 
                end

                legend_entry = strrep(info.name + ", mic: " + log_list(j) + ", mode: " + mode + ", bg: " + string(bg_noise_on), "_", " ");

                p = semilogx(f, spl(:,j), 'LineWidth', line_width, 'DisplayName', legend_entry);
                if mode == "normal" 
                    p.Color(4) = 0.2;
                end

                hold on
            end
        end
    end
end

%% Plot specifics

% Spectral density
figure(1)

legend

grid on
xlim([10 2*10^4]);
xlabel('f [Hz]');
ylabel('SPL [dB]');
