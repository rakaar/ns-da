for s=1:16
    figure
    hold on
        plot(get_stimulus_shape(s,1))
        plot(get_stimulus_from_wav(s))
    hold off
    grid
end