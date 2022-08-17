function stimulus_wave = get_stimulus_wave(stimulus_type, all_stimulus_code,all_stimulus_code_struct, pre_stimulus_silence)
    % stimulus_type is the line number in D:\da\stimulus_sets.mat
    stimulus_coded = all_stimulus_code(stimulus_type, :);
    stimulus_wave = [];
    stimulus_wave = [stimulus_wave, pre_stimulus_silence];
    for i=1:length(stimulus_coded)
        stimulus_part = all_stimulus_code_struct.(strcat('s', num2str(stimulus_coded(i))));
        stimulus_wave = [stimulus_wave, stimulus_part];
    end
    
    total_aquisition_time = 2500;
    post_stimulus_silence_duration = total_aquisition_time - length(stimulus_wave);
    post_stimulus_silence = zeros(1, post_stimulus_silence_duration);

    stimulus_wave = [stimulus_wave, post_stimulus_silence];
    
end