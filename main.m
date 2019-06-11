clc

%% Retrieve data

% If you want to add something. Add an entry in every one of these arrays.
% So an entry in file_names for the filename, mics for which microphones
% and modes for which mode. 

% You can also use split_broadband_visual and
% split_tonal_visual for nice split plots. Works quite well.

figure(1)

file_names = {'../matlab/Baseline_propeller_scaled/prop_U10_rpm4000.mat', ...
'../matlab/Serrated_propeller_scaled/serrated_U10_rpm4000.mat'};

% file_names = {'../matlab/Background_noise/background_noise.mat', ...
%     '../matlab/Background_noise/background_noise_U5.mat', ...
%     '../matlab/Background_noise/background_noise_U10.mat', ...
%     '../matlab/Background_noise/background_noise_U15.mat', ...
%     '../matlab/Background_noise/background_noise_U20.mat'};

mics = {[41], [41]};

modes = {["normal", "split_tonal_visual", "split_broadband_visual"], ...
    ["normal", "split_tonal_visual", "split_broadband_visual"]};

bg_noise = {1, 1};
for i = 1:length(file_names)
    log_list = mics{i};
    file_path = file_names{i};

    bg_noise_on = bg_noise{i};
    legend_on = 1;

    m = modes{i};
    for k = 1:length(m)
        mode = m(k);

        [PSD, f, spl, OASPL, info] = analysis(file_path, log_list, mode, bg_noise_on);
        if mode ~= "oaspl"
            figure(1)

            for j = 1:length(log_list)
                line_color = 0;
                if startsWith(info.name, 'serrated')
                    legend_entry = "Serrated propeller, ";
                else
                    legend_entry = "Baseline propeller, ";
                end

                if mode == "split_broadband_visual"
                    legend_entry = strrep(legend_entry + "U: " + info.wind_speed + " m/s, \omega: " + info.rpm + " rpm, broadband spectrum", "_", " ");
%                     legend_entry = strrep(legend_entry + "broadband spectrum", "_", " ");
                    line_width = 1.7;
                    if startsWith(info.name, 'serrated'); line_color = 'm'; end
                elseif mode == "split_tonal_visual"
                    legend_entry = strrep(legend_entry + "U: " + info.wind_speed + " m/s, tonal spectrum", "_", " ");
%                     legend_entry = strrep(legend_entry + "tonal spectrum", "_", " ");
                    line_width = 0.5;
                    if startsWith(info.name, 'serrated'); line_color = 'g'; end
                else
                    legend_entry = strrep(legend_entry + "U: " + info.wind_speed + " m/s, full spectrum", "_", " ");
%                     legend_entry = strrep(legend_entry + "full spectrum", "_", " ");
                    line_width = 0.5;
                end

                if line_color ~= 0
                    p = semilogx(f, spl(:,j), 'LineWidth', line_width, 'Color', line_color, 'DisplayName', legend_entry);
                else
                    p = semilogx(f, spl(:,j), 'LineWidth', line_width, 'DisplayName', legend_entry);
                end
                
                if mode == "normal" 
                    p.Color(4) = 0.2;
                elseif mode == "split_tonal_visual"
                    p.Color(4) = 0.6;
                end

                hold on
            end
        end
    end
end

%% Plot specifics

% Spectral density
main_fig = figure(1);
set(gcf, 'Position', get(0, 'Screensize'));

set(gca, 'FontSize', 22);

if legend_on
    legend('Location', 'northeast')
end

grid on
xlim([10 2*10^4]);
ylim([0 80]);
xlabel('f [Hz]');
ylabel('SPL [dB]');

saveas(main_fig, "plots/" + string(info.wind_speed) + "_rpm" + string(info.rpm) + ".png")
