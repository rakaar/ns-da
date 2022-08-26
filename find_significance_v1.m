% find each unit's mean spont - 50ms - 250ms
bin_size = 5;
% stimulus


n_stimulus_sets = 16;
total_stimulus_duration = 2500;

n_units = 299;
units_stim_spont = cell(n_units,1);
units_gap_spont = cell(n_units,4);
units_activity = cell(n_units, 1);

gap = [60 90 150 280];
gap_binned = gap/bin_size;

for u=1:n_units
    spont_start_time_for_stim = randi([6, 40])*10; 
    spont_end_time_for_stim = spont_start_time_for_stim + 50; % in ms
    
    spont_start_time_for_stim = spont_start_time_for_stim/bin_size;
    spont_end_time_for_stim = spont_end_time_for_stim/bin_size;
    
    spont_start_time_for_gap = randi([6, 40])*10;
    spont_gap_end = zeros(1,4);
    for g=1:4
        spont_gap_end(1,g) = spont_start_time_for_gap + gap(g);
    end
    spont_start_time_for_gap = spont_start_time_for_gap/bin_size;
    spont_gap_end(1,:) = spont_gap_end(1,:)/bin_size;
    

    each_unit_response = [];
    for s=1:n_stimulus_sets
        each_unit_response = [each_unit_response; all_animals_response_cell_arr{u,s}];
    end

    mean_each_unit_response = mean(each_unit_response, 1);
    mean_each_unit_response_binned = mean(reshape(mean_each_unit_response, bin_size, total_stimulus_duration/bin_size) ,1); 
    
    units_stim_spont{u,1} = mean_each_unit_response_binned(1,spont_start_time_for_stim+1:spont_end_time_for_stim);
    for g=1:4
        units_gap_spont{u,g} = mean_each_unit_response_binned(1, spont_start_time_for_gap+1:spont_gap_end(g));
    end
    
    units_activity{u,1} = mean_each_unit_response_binned;
end

%% to be run after analyse_unit_wise_db first section
% response_binned_cell is required
significance_matrix = cell(stimulus_sets,6); % 3 stim, 3 gap
all_units_mean_stim_spont = [];
all_units_mean_gap_spont = cell(1,4); 
for u=1:299
    all_units_mean_stim_spont = [all_units_mean_stim_spont; units_stim_spont{u,1}];
    for g=1:4
        all_units_mean_gap_spont{1,g} = [all_units_mean_gap_spont{1,g}; units_gap_spont{u,g}];
   end
  
end

all_units_mean_stim_spont = mean(all_units_mean_stim_spont,1);
for g=1:4
    all_units_mean_gap_spont{1,g} = mean(all_units_mean_gap_spont{1,g}, 1);
end

% avg all units
for s=1:stimulus_sets
    token1_start = 500/bin_size;
    stim_durn = 50/bin_size;
    gap_type = mod(s,4);
    if gap_type == 0
        gap_type = 4;
    end
    gap_durn = gap_binned(gap_type);
    token1_end = token1_start + stim_durn;

    token2_start = token1_end + gap_durn;
    token2_end = token2_start + stim_durn;

    token3_start = token2_end + gap_durn;
    token3_end = token3_start + stim_durn;

    token4_start = token3_end + gap_durn;
    response_for_stim_binned = response_binned_cell{s,:};
    significance_matrix{s,1} = ttest(response_for_stim_binned(1, token1_start+1:token1_end), all_units_mean_stim_spont);
    significance_matrix{s,2} = ttest2(response_for_stim_binned(1, token2_start+1:token2_end), all_units_mean_stim_spont);
    significance_matrix{s,3} = ttest2(response_for_stim_binned(1, token3_start+1:token3_end), all_units_mean_stim_spont);

    significance_matrix{s,4} = ttest2(response_for_stim_binned(1, token1_end+1:token2_start), all_units_mean_gap_spont{1,gap_type});
    significance_matrix{s,5} = ttest2(response_for_stim_binned(1, token2_end+1:token3_start), all_units_mean_gap_spont{1,gap_type});
    significance_matrix{s,6} = ttest2(response_for_stim_binned(1, token3_end+1:token4_start), all_units_mean_gap_spont{1,gap_type});
 
end
disp('-------------')