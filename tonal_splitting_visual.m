function [broadband, full, broadband_f] = tonal_splitting_visual(spl, f)
    %% Visual method
        
    [~, locs, widths, ~] = findpeaks(spl, f, 'MinPeakProminence', 1, ... 
        'WidthReference', 'halfprom');

    f = interp(f, 4); spl = interp(spl, 4);

%     locs = locs(2:end); widths = widths(2:end);

%     pks = pks(2:end);
%     figure(10);
%     scatter(locs, pks)
%     hold on
%     
%     for i = 1:length(locs)
%         w = widths(i);
%         plot([locs(i) - w, locs(i) - w, locs(i) + w, locs(i) + w], [0, pks(i), pks(i), 0])
%         hold on
%         
%         start_idx = find(f < locs(i) - w);
%         end_idx = find(f > locs(i) + w);
%         
%         start_idx = start_idx(end); end_idx = end_idx(1);
% 
%         if mod(i,2)
%             c = 'red';
%         else
%             c = 'green';
%         end
% 
%         plot(f(start_idx:end_idx), spl(start_idx:end_idx), 'color', c)
%         hold on
%     end
% 
%     semilogx(f, spl)

    broadband = spl; full = spl; broadband_f = f; offset = 0;
    for i = 1:length(locs)
        w = widths(i)*1.1;

        start_idx = find(f <= locs(i) - w);
        end_idx = find(f >= locs(i) + w);

        if ~isempty(start_idx) && ~isempty(end_idx) && w < 50
            start_idx = start_idx(end); end_idx = end_idx(1);

            inter = f(start_idx:end_idx);

            f(start_idx:end_idx) = [];
            spl(start_idx:end_idx) = [];

            new_spl = interp1(f, spl, inter, 'pchip');

            broadband(start_idx + offset:end_idx + offset) = new_spl;
            offset = (end_idx - start_idx + 1) + offset;
        end        
    end
    
    broadband = smooth(broadband, 500);
end