%% for each unit, construct a 16 x 6 matrix, 16 stim , 3 tokens 3 gaps
% not significant if responds to only 1 stimulus and that too less than 4
% responses

stimulus_path = "D:\recheck_sorted_data\stimulus";
response_path = "D:\recheck_sorted_data\response";

total_stimulus_duration = 2500;
stimulus_path_dir = dir(stimulus_path);
total_iters = 80;
n_units = 299;
unit_counter = 1;
n_stimulus = 16;
alpha = 0.05;

units_sig_matrix = cell(500,2); % the cell arr

for f=3:length(stimulus_path_dir)
    stimulus_file_name = stimulus_path_dir(f).name;
    stimulus_file_path = strcat(stimulus_path, '\', stimulus_file_name);
    stimulus_matrix = load(stimulus_file_path).codes;
    stimulus_matrix_reshaped = reshape(stimulus_matrix, 1, total_iters);

    response_file = strrep(stimulus_file_path, '_stimcode', '_unit_record');
    response_file = strrep(response_file,'\stimulus\','\response\');
    response_struct = load(response_file).unit_record_spike;

     for u=1:length(response_struct)
        single_unit_sig_matrix = zeros(16,6);
        response_negspiketime = response_struct(u).negspiketime;
        if isempty(response_negspiketime)
            continue
        end

        cluster1_response_timings = response_negspiketime.cl1;

        % calculate spont
        stim_spont = zeros(1, total_iters);
        gap1_spont = zeros(1, total_iters);
        gap2_spont = zeros(1, total_iters);
        gap3_spont = zeros(1, total_iters);
        gap4_spont = zeros(1, total_iters);
        stim_durn = 50 + 20; gap1_durn = 60; gap2_durn = 90; gap3_durn = 150; gap4_durn = 280;
        starting_pt = 500;

        for iter=1:80
             iter_field = strcat('iter', num2str(iter));
             negspike_timings = cluster1_response_timings.(iter_field);
             spikes_from_negspike_timings = get_spikes_from_timings(total_stimulus_duration, negspike_timings);
             stim_spont(1,iter) = sum(spikes_from_negspike_timings(1, starting_pt-stim_durn+1:starting_pt));  
             gap1_spont(1,iter) = sum(spikes_from_negspike_timings(1, starting_pt-gap1_durn+1:starting_pt));  
             gap2_spont(1,iter) = sum(spikes_from_negspike_timings(1, starting_pt-gap2_durn+1:starting_pt));  
             gap3_spont(1,iter) = sum(spikes_from_negspike_timings(1, starting_pt-gap3_durn+1:starting_pt));  
             gap4_spont(1,iter) = sum(spikes_from_negspike_timings(1, starting_pt-gap4_durn+1:starting_pt));  
        end

        for s=1:n_stimulus
            responses_for_single_stim = [];
            s_stim_indices = find(stimulus_matrix_reshaped == s);
            for i=1:length(s_stim_indices)
                iter_field = strcat('iter', num2str(s_stim_indices(i)));
                negspike_timings = cluster1_response_timings.(iter_field);
                spikes_from_negspike_timings = get_spikes_from_timings(total_stimulus_duration, negspike_timings);
                responses_for_single_stim = [responses_for_single_stim; spikes_from_negspike_timings];
            end
            
            n_res = size(responses_for_single_stim, 1);
            bonferoni_factor = 16;
            % sig test
            if n_res < 4
                single_unit_sig_matrix(s,1:6) = nan;
            else
             gap_type = mod(s,4);
            if gap_type == 1
                gap_durn = 60;
                gap_spont = gap1_spont;
            elseif gap_type == 2
                gap_durn = 90;
                gap_spont = gap2_spont;
            elseif gap_type == 3
                gap_durn = 150;
                gap_spont = gap3_spont;
            elseif gap_type == 0
                gap_durn = 280;
                gap_spont = gap4_spont;
            end
    
            token1_start_time = 501;
            token1_end_time = token1_start_time - 1 + stim_durn;
    
            gap1_start_time = token1_end_time + 1;
            gap1_end_time = gap1_start_time - 1 + gap_durn;
    
            token2_start_time = gap1_end_time + 1;
            token2_end_time = token2_start_time - 1 + stim_durn;
    
            gap2_start_time = token2_end_time + 1;
            gap2_end_time = gap2_start_time - 1 + gap_durn;
    
            token3_start_time = gap2_end_time + 1;
            token3_end_time = token3_start_time - 1 + stim_durn;
    
            gap3_start_time = token3_end_time + 1;
            gap3_end_time = gap3_start_time - 1 + gap_durn;
    
            single_unit_sig_matrix(s,1) = ttest2(stim_spont, sum(responses_for_single_stim(:, token1_start_time:token1_end_time), 2), 'Alpha',alpha/bonferoni_factor);  
            single_unit_sig_matrix(s,2) = ttest2(stim_spont, sum(responses_for_single_stim(:, token2_start_time:token2_end_time), 2), 'Alpha',alpha/bonferoni_factor); 
            single_unit_sig_matrix(s,3) = ttest2(stim_spont, sum(responses_for_single_stim(:, token3_start_time:token3_end_time), 2), 'Alpha',alpha/bonferoni_factor);
    
            single_unit_sig_matrix(s,4) = ttest2(gap_spont, sum(responses_for_single_stim(:, gap1_start_time:gap1_end_time), 2), 'Alpha',alpha/bonferoni_factor);
            single_unit_sig_matrix(s,5) = ttest2(gap_spont, sum(responses_for_single_stim(:, gap2_start_time:gap2_end_time), 2), 'Alpha',alpha/bonferoni_factor);
            single_unit_sig_matrix(s,6) = ttest2(gap_spont, sum(responses_for_single_stim(:, gap3_start_time:gap3_end_time), 2), 'Alpha',alpha/bonferoni_factor);
        end
            
        end % end of all stimulus

        units_sig_matrix{unit_counter, 1} = single_unit_sig_matrix;
        unit_counter = unit_counter + 1;    
     end % end of unit
end % end of all files

%% check if the unit is significant
for u=1:n_units
    per_unit_sig_matrix = units_sig_matrix{u,1};
    h_values_is1_per_stim = zeros(1, n_stimulus); % for a single stim, out of 6 segments if any segment as 1
    
    for s=1:n_stimulus
        if any(per_unit_sig_matrix(s,:) == 1)
            h_values_is1_per_stim(1,s) = 1;
        end
    end
    
    num_of_h1 = length(find(h_values_is1_per_stim == 1));
    
    if num_of_h1 > 0
        units_sig_matrix{u,2} = 1;
    else
        units_sig_matrix{u,2} = 0;
    end

    
end

%% num of sig units
decent_num = 0;
for u=1:299
    if units_sig_matrix{u,2} == 1
        decent_num = decent_num + 1;
    end
end
disp(decent_num)
%% make a db of only significant units
only_sig_units_db = cell(500, n_stimulus);
sig_unit_counter = 1;
for u=1:n_units
    if units_sig_matrix{u,2} == 0
        continue;
    end

    for s=1:n_stimulus
        only_sig_units_db{sig_unit_counter,s} = all_animals_response_cell_arr{u,s};
    end

    sig_unit_counter = sig_unit_counter + 1;
end

%% make baselines for each unit - 
baseline_all_units = cell(500,1); % 80 stimulus x 6 segments, each unit, 6 baselines 
unit_counter = 1;

for f=3:length(stimulus_path_dir)
    stimulus_file_name = stimulus_path_dir(f).name;
    stimulus_file_path = strcat(stimulus_path, '\', stimulus_file_name);
    stimulus_matrix = load(stimulus_file_path).codes;
    stimulus_matrix_reshaped = reshape(stimulus_matrix, 1, total_iters);

    response_file = strrep(stimulus_file_path, '_stimcode', '_unit_record');
    response_file = strrep(response_file,'\stimulus\','\response\');
    response_struct = load(response_file).unit_record_spike;

     for u=1:length(response_struct)
        response_negspiketime = response_struct(u).negspiketime;
        if isempty(response_negspiketime)
            continue
        end

        cluster1_response_timings = response_negspiketime.cl1;
        baseline_matrix = zeros(80, 6);
        
        for iter=1:80 
            iter_field = strcat('iter', num2str(iter));
            negspike_timings = cluster1_response_timings.(iter_field);
            spikes_from_negspike_timings = get_spikes_from_timings(total_stimulus_duration, negspike_timings);
            
            stimulus_played = stimulus_matrix_reshaped(1, iter);

            stim_durn = 50;
            gap_type = mod(stimulus_played,4);
            if gap_type == 1
                gap_durn = 60;
            elseif gap_type == 2
                gap_durn = 90;
            elseif gap_type == 3
                gap_durn = 150;
            elseif gap_type == 0
                gap_durn = 280;
            end

            token1_start_time = 501;
            token1_end_time = token1_start_time - 1 + stim_durn;
    
            gap1_start_time = token1_end_time + 1;
            gap1_end_time = gap1_start_time - 1 + gap_durn;
    
            token2_start_time = gap1_end_time + 1;
            token2_end_time = token2_start_time - 1 + stim_durn;
    
            gap2_start_time = token2_end_time + 1;
            gap2_end_time = gap2_start_time - 1 + gap_durn;
    
            token3_start_time = gap2_end_time + 1;
            token3_end_time = token3_start_time - 1 + stim_durn;
    
            gap3_start_time = token3_end_time + 1;
            gap3_end_time = gap3_start_time - 1 + gap_durn;
            
            % stim tokens
            baseline_matrix(iter,1) = mean(spikes_from_negspike_timings(1, token1_start_time:token1_end_time));
            baseline_matrix(iter,2) = mean(spikes_from_negspike_timings(1, token2_start_time:token2_end_time));
            baseline_matrix(iter,3) = mean(spikes_from_negspike_timings(1, token3_start_time:token3_end_time));
            % gaps
            baseline_matrix(iter,4) = mean(spikes_from_negspike_timings(1, gap1_start_time:gap1_end_time));
            baseline_matrix(iter,5) = mean(spikes_from_negspike_timings(1, gap2_start_time:gap2_end_time));
            baseline_matrix(iter,6) = mean(spikes_from_negspike_timings(1, gap3_start_time:gap3_end_time));
        end % end of iter

        baseline_all_units{unit_counter,1} = baseline_matrix;
        unit_counter = unit_counter + 1;
     end % end of unit
    
end

%% mean values in each significant unit
mean_all_units = cell(500,1); % for each unit, 16 x 20 x 6 - single stim, 20 reps, 6 segments
unit_counter = 1;
for u=1:n_units
    if units_sig_matrix{u,2} == 0
        continue
    end

    single_unit_all_stim_6segement_values = nan(n_stimulus, 20, 6); % 16 stim, max 20 rep of each stim, 6 segments
   
    for s=1:n_stimulus
        stim_durn = 50;
        gap_type = mod(stimulus_played,4);
        if gap_type == 1
            gap_durn = 60;
        elseif gap_type == 2
            gap_durn = 90;
        elseif gap_type == 3
            gap_durn = 150;
        elseif gap_type == 0
            gap_durn = 280;
        end

        token1_start_time = 501;
        token1_end_time = token1_start_time - 1 + stim_durn;

        gap1_start_time = token1_end_time + 1;
        gap1_end_time = gap1_start_time - 1 + gap_durn;

        token2_start_time = gap1_end_time + 1;
        token2_end_time = token2_start_time - 1 + stim_durn;

        gap2_start_time = token2_end_time + 1;
        gap2_end_time = gap2_start_time - 1 + gap_durn;

        token3_start_time = gap2_end_time + 1;
        token3_end_time = token3_start_time - 1 + stim_durn;

        gap3_start_time = token3_end_time + 1;
        gap3_end_time = gap3_start_time - 1 + gap_durn;

        unit_response_for_stim = all_animals_response_cell_arr{u,s};
        n_rep = size(unit_response_for_stim, 1);

        for n=1:n_rep
            single_rep_single_unit_single_stim_res = unit_response_for_stim(n,:);
            % stim tokens
            single_unit_all_stim_6segement_values(s,n,1) = mean(unit_response_for_stim(1, token1_start_time:token1_end_time));
            single_unit_all_stim_6segement_values(s,n,2) = mean(unit_response_for_stim(1, token2_start_time:token2_end_time));
            single_unit_all_stim_6segement_values(s,n,3) = mean(unit_response_for_stim(1, token3_start_time:token3_end_time));

            % gaps
            single_unit_all_stim_6segement_values(s,n,4) = mean(unit_response_for_stim(1, gap1_start_time:gap1_end_time));
            single_unit_all_stim_6segement_values(s,n,5) = mean(unit_response_for_stim(1, gap2_start_time:gap2_end_time));
            single_unit_all_stim_6segement_values(s,n,6) = mean(unit_response_for_stim(1, gap3_start_time:gap3_end_time));
        
        end % end of a rep
    end % end of stim
    mean_all_units{unit_counter,1} = single_unit_all_stim_6segement_values;
    unit_counter = unit_counter + 1;
end % end of unit

