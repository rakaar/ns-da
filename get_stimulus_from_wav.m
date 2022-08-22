function final_stimulus = get_stimulus_from_wav(stimulus_type)
    stimulus_matrix = load("D:\da\HC_cell.mat").HC_cell;
    stimulus = stimulus_matrix(stimulus_type, :);
    stimulus_wave = [];
    for i=1:6
        stimulus_wave = [stimulus_wave, stimulus{i}];
    end
    Fs = 156250;
    pre_stimulus_silence = zeros(1,500);
    % 156 is 1/156250
    stimulus_wave_resampled = stimulus_wave(1,1:156:length(stimulus_wave));
    post_stimulus_silence_length = 2500 - (length(stimulus_wave_resampled) + 500);
    post_stimulus_silence = zeros(1, post_stimulus_silence_length);

    final_stimulus = [pre_stimulus_silence, stimulus_wave_resampled, post_stimulus_silence];

    %     plot(((1:length(stimulus_wave))/156250)*1000,stimulus_wave)

end