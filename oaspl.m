function oaspl(OASPL)
    figure()

    %% Load mic data
    mic_arr = load('../matlab/Configuration_Array_VTunnel.txt', '\t');
    mic_arr = mic_arr(:,2:3);

    x = mic_arr(:,1)';
    y = mic_arr(:,2)';
    
    %% Calculate 
    x(24) = []; y(24) = []; OASPL(24) = [];
    fprintf("OASPL: center mic: %f dB, mean: %f dB\n", OASPL(40), mean(OASPL));
    
    OASPL = normalize(OASPL);
    z = [x;y;OASPL]; z = z';

    [xq,yq] = meshgrid(-1:.01:1, -1:.01:1);

    %% Plot
    vq = griddata(z(:,1),z(:,2),z(:,3),xq,yq,'v4'); % Can also use different methods

    surf(xq,yq,vq)
    view(0, 90)

    hold on

    % Scatterplot
    plot3(z(:,1),z(:,2),z(:,3),'ro')
    
    %% Plot style
    grid on

    shading interp

    xlabel('x');
    ylabel('y');

    xlim([-1.3 1.3])
    ylim([-1.3 1.3])

end