%% create the baseline 
n_units = 299;
n_stimulus = 16;
baseline_cell = cell(n_units, 5); % 1 for stim window, 4 for gap

spont_start = 200;
spont_stim_end = spont_start + 50;
spont_gap1_end = spont_start + 60;
spont_gap2_end = spont_start + 90;
spont_gap3_end = spont_start + 150;
spont_gap4_end = spont_start + 280;

for u=1:n_units
    for s=1:n_stimulus
        if isempty(all_animals_response_cell_arr{u,s})

            baseline_cell{u,1} = [baseline_cell{u,1}; nan(1, 50)];
            baseline_cell{u,2} = [baseline_cell{u,2}; nan(1, 60)];
            baseline_cell{u,3} = [baseline_cell{u,3}; nan(1, 90)];
            baseline_cell{u,4} = [baseline_cell{u,4}; nan(1, 150)];
            baseline_cell{u,5} = [baseline_cell{u,5}; nan(1, 280)];
            continue
        end

        unit_stim_response_mean = mean(all_animals_response_cell_arr{u,s}, 1);
        
        % stimulus window
        baseline_cell{u,1} = [baseline_cell{u,1}; unit_stim_response_mean(1, spont_start+1:spont_stim_end)];

        % gaps
        baseline_cell{u,2} = [baseline_cell{u,2}; unit_stim_response_mean(1, spont_start+1:spont_gap1_end)];
        baseline_cell{u,3} = [baseline_cell{u,3}; unit_stim_response_mean(1, spont_start+1:spont_gap2_end)];
        baseline_cell{u,4} = [baseline_cell{u,4}; unit_stim_response_mean(1, spont_start+1:spont_gap3_end)];
        baseline_cell{u,5} = [baseline_cell{u,5}; unit_stim_response_mean(1, spont_start+1:spont_gap4_end)];

    end
end

%% make the significance matrix - 16 x 6 alongside ignore unit or not
units_significance_matrix = cell(n_units, 2); % col-1-16x6 matrix, col-2-ignore unit or not
stim_durn = 50;
alpha = 0.05;
for u=1:n_units
    sig_matrix = cell(16,6); % first 3 - stim tokens, next 3 - gaps
    for s=1:n_stimulus
        if isempty(all_animals_response_cell_arr{u,s})
            sig_matrix{s,1} = [sig_matrix{s,1}; NaN];
            sig_matrix{s,2} = [sig_matrix{s,2}; NaN];
            sig_matrix{s,3} = [sig_matrix{s,3}; NaN];
            sig_matrix{s,4} = [sig_matrix{s,4}; NaN];
            sig_matrix{s,5} = [sig_matrix{s,5}; NaN];
            sig_matrix{s,6} = [sig_matrix{s,6}; NaN];
            continue
        end
        
        gap_type = mod(s,4);
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

        unit_stim_response = all_animals_response_cell_arr{u,s};
        n_res = size(unit_stim_response,1);
        bonferoni_factor = n_res;
        for n=1:n_res
            response_for_single_unit_stim_res = unit_stim_response(n,:);
            % responses
            token1_response = response_for_single_unit_stim_res(1, token1_start_time:token1_end_time);
            token2_response = response_for_single_unit_stim_res(1, token2_start_time:token2_end_time);
            token3_response = response_for_single_unit_stim_res(1, token3_start_time:token3_end_time);
            
            gap1_response = response_for_single_unit_stim_res(1, gap1_start_time:gap1_end_time);
            gap2_response = response_for_single_unit_stim_res(1, gap2_start_time:gap2_end_time);
            gap3_response = response_for_single_unit_stim_res(1, gap3_start_time:gap3_end_time);

        
            % ttests
            if isnan(baseline_cell{u,1}(s,1))
                sig_matrix{s,1} = [sig_matrix{s,1}; NaN];
                sig_matrix{s,2} = [sig_matrix{s,1}; NaN];
                sig_matrix{s,3} = [sig_matrix{s,1}; NaN];
            else
                sig_matrix{s,1} = [sig_matrix{s,1}; ttest2(token1_response, baseline_cell{u,1}(s,:), 'Alpha',alpha/bonferoni_factor)]; 
                sig_matrix{s,2} = [sig_matrix{s,2}; ttest2(token2_response, baseline_cell{u,1}(s,:), 'Alpha',alpha/bonferoni_factor)]; 
                sig_matrix{s,3} = [sig_matrix{s,3}; ttest2(token3_response, baseline_cell{u,1}(s,:), 'Alpha',alpha/bonferoni_factor)]; 
            end
            
            if gap_type == 0
                gap_index_in_cell = 5;
            else
                gap_index_in_cell = gap_type + 1;
            end

            if isnan(baseline_cell{u,gap_index_in_cell}(s,1))
                sig_matrix{s,4} = [sig_matrix{s,4}; NaN];
                sig_matrix{s,5} = [sig_matrix{s,5}; NaN];
                sig_matrix{s,6} = [sig_matrix{s,6}; NaN];
            else
                sig_matrix{s,4} = [sig_matrix{s,4}; ttest2(gap1_response, baseline_cell{u,gap_index_in_cell}(s,:), 'Alpha',alpha/bonferoni_factor)]; 
                sig_matrix{s,5} = [sig_matrix{s,5}; ttest2(gap2_response, baseline_cell{u,gap_index_in_cell}(s,:), 'Alpha',alpha/bonferoni_factor)]; 
                sig_matrix{s,6} = [sig_matrix{s,6}; ttest2(gap3_response, baseline_cell{u,gap_index_in_cell}(s,:), 'Alpha',alpha/bonferoni_factor)]; 
            end
            
        end
        
    end
    
    units_significance_matrix{u,1} = sig_matrix;

end

%% find number of decent units = that are significant due to more than one stimuli, if only one stimuli, then more than 4 responding iters
for u=1:n_units
    single_unit_all_stim_sig_matrix = units_significance_matrix{u,1};
    num_of_sig = zeros(1,n_stimulus);

    for s=1:n_stimulus
        for tok_gaps=1:6
            h_values =  single_unit_all_stim_sig_matrix{s,tok_gaps};
            num_of_sig(1,s) = num_of_sig(1,s) + length(find(h_values==1));
        end
    end

    % if num of stimulus is more than 15 and non zero had more than 1
    responding_stim_indices = find(num_of_sig > 0);
    if isempty(responding_stim_indices) % no stim responds
        units_significance_matrix{u,2} = 0;
    elseif length(responding_stim_indices) == 1 % only 1 stim, there has to be atleast 4 for sig
            if num_of_sig(responding_stim_indices(1)) > 3
                units_significance_matrix{u,2} = 1;
            else
                units_significance_matrix{u,2} = 0;
            end
    else % more than one stim responds
            units_significance_matrix{u,2} = 1;
    end
        
end



%% num of decent num of units
decent_num = 0;
for u=1:299
    if units_significance_matrix{u,2} == 1
        decent_num = decent_num + 1;
    end
end
disp(decent_num)

%% make db of only significantly responding stim
all_animals_only_sig_responses_cell_arr = cell(n_units,n_stimulus);
for u=1:n_units
    if units_significance_matrix{u,2} == 0
        continue
    end

    for s=1:n_stimulus
        single_stim_sig = units_significance_matrix{u,1}(s,:);
        n_res = size(single_stim_sig{1},1);
        for n=1:n_res
            is_sig_in_res = 0;
            for tok=1:6
                single_rep_single_stim_sig = single_stim_sig{tok}(n);
                if single_rep_single_stim_sig == 1
                    is_sig_in_res = 1;
                    all_animals_only_sig_responses_cell_arr{u,s} = [all_animals_only_sig_responses_cell_arr{u,s}; all_animals_response_cell_arr{u,s}(n,:)];
                    break
                end
            end
        end
    end
end
