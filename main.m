clc

%% Retrieve data

% If you want to add something. Add an entry in every one of these arrays.
% So an entry in file_names for the filename, mics for which microphones
% and modes for which mode. For modeds; there's also split_broadband and
% split_tonal, they kinda work but not propely yet.

figure(1)

file_names = {'../matlab/Serrated_propeller_scaled/serrated_U0_rpm4000.mat', ...
    '../matlab/Baseline_propeller_scaled/prop_U0_rpm4000.mat'};

mics = {[41], [41]};

modes = {["normal", "split_broadband_visual", "split_tonal_visual", "oaspl"], ...
    ["normal", "split_broadband_visual", "split_tonal_visual"]};

for i = 1:length(file_names)
    log_list = mics{i};
    file_path = file_names{i};

    m = modes{i};
    for k = 1:length(m)
        mode = m(k);

        [PSD, f, spl, OASPL, info] = analysis(file_path, log_list, mode);
        if mode ~= "oaspl"
            figure(1)

            for j = 1:length(log_list)
                legend_entry = strrep(info.name + ", mic: " + log_list(j) + ", mode: " + mode, "_", " ");

                semilogx(f, spl(:,j), 'LineWidth', 1, 'DisplayName', legend_entry)
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

% OASPL
figure(2)

grid on

shading interp

xlabel('x');
ylabel('y');

xlim([-1.3 1.3])
ylim([-1.3 1.3])
