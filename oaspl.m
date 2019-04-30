function oaspl(OASPL)
    figure(2)

    %% Load mic data
    mic_arr = load('../matlab/Configuration_Array_VTunnel.txt', '\t');
    mic_arr = mic_arr(:,2:3);

    x = mic_arr(:,1)';
    y = mic_arr(:,2)';
    
    %% Calculate 
    x = x + 0.02;
    
    OASPL = normalize(OASPL);
    z = [x;y;OASPL]; z = z';

    [xq,yq] = meshgrid(-1:.01:1, -1:.01:1);

    %% Plot
    vq = griddata(z(:,1),z(:,2),z(:,3),xq,yq,'cubic'); % Can also use different methods

    surf(xq,yq,vq)
    view(0, 90)

    hold on

    % Scatterplot
    plot3(z(:,1),z(:,2),z(:,3),'o')
end