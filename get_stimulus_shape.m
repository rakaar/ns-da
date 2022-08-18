function stimulus_shape = get_stimulus_shape(stimulus_type, maximum_value)
    % stimulus type - 1 to 16
    % maximum value  - peak of stimulus as per visual convenience
    pre_stimulus_silence = zeros(1,500);
    token = maximum_value*ones(1, 50);
    gap_type = mod(stimulus_type,4);
    if gap_type == 1
        gap = zeros(1,60);
    elseif gap_type == 2
        gap = zeros(1,90);
    elseif gap_type == 3
        gap = zeros(1,150);
    elseif gap_type == 0
        gap = zeros(1,280);
    end
 
    stimulus_shape = [];
    stimulus_shape = [stimulus_shape, pre_stimulus_silence, token, gap, token, gap,token, gap];

    post_stimulus_silence_len = 2500 - length(stimulus_shape);
    post_stimulus_silence = zeros(1, post_stimulus_silence_len);

    stimulus_shape = [stimulus_shape, post_stimulus_silence];
    
end