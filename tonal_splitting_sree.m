function [broadband] = tonal_splitting_sree(p, idx, npr, nrot)
    %% Sree's method
    npr = round(npr);
    nrot = round(nrot);
    p(:, idx) = bandpass(p(:, idx), [10, 20e3], 60e3);

    broadband = [];
    for i = 0:1:(nrot - 3)
        % Two consecutive bits
        x_start = i*npr + 1; x_end = (i + 1)*npr;
        y_start = (i + 1)*npr + 1; y_end = (i + 2)*npr;

        x = p(x_start:x_end, idx); y = p(y_start:y_end, idx);
        
        h_window = tukeywin(length(x), 0.05);

        r_full = smooth(xcorr(x.*h_window, y.*h_window)*npr, 10); [~, max_idx] = max(abs(r_full));
        r = max(min(round(r_full(max_idx)), npr), -npr);

        if sign(r) == -1
            y_start = y_start - r; y_end = y_end - r;
            y = p(y_start:y_end, idx);  
        elseif sign(r) == 1
            x_start = x_start + r; x_end = x_end + r;
            x = p(x_start:x_end, idx);
        end

        z = (x - y)/sqrt(2);

        broadband = [broadband; z];
    end
end