%% make animal wise cell array
clear all

sorted_data_path = "D:\ami_hc_new_data_ephys\sorted data";
num_stimulus_sets = 16;
total_iters = 80;
total_stimulus_duration = 2500;

all_folders_info = dir(sorted_data_path);
animal_names = {};
for i=3:length(all_folders_info)
    animal_names = [animal_names, all_folders_info(i).name];
end
all_animals_db = struct;
all_animals_response_cell_arr = cell(500,16);
all_animals_units_counter = 1;

for a=1:length(animal_names)
    stimulus_path = strcat(sorted_data_path, '\', animal_names{a}, '\', 'stimcodes');
    stimulus_path_info = dir(stimulus_path);
    n_units = 1;
    response_db_per_animal = cell(200,16);
    

    for s=3:length(stimulus_path_info)
        stimulus_file = strcat(stimulus_path, '\', stimulus_path_info(s).name);
        stimulus_matrix = load(stimulus_file).codes; % 16 x 5 matrix
        reshaped_stimulus_matrix = reshape(stimulus_matrix, 1, numel(stimulus_matrix));
        
        recording_file = strrep(stimulus_file, '_stimcode', '_unit_record');
        recording_file = strrep(recording_file, '\stimcodes\', '\');
        
        unit_record_spike = load(recording_file).unit_record_spike;

        for u=1:length(unit_record_spike)
            if isempty(unit_record_spike(u).negspikemat)
                continue
            end

            channel_wise_spike_time = unit_record_spike(u).negspiketime;
            channel_wise_spike_time = channel_wise_spike_time.cl1; % single cluster only

            % for each stimulus
            for iter=1:total_iters
                stimulus_played = reshaped_stimulus_matrix(1,iter);
                iter_field_str = strcat('iter',num2str(iter));
                negative_spike_timings = channel_wise_spike_time.(iter_field_str);
                spikes_from_timings = get_spikes_from_timings(total_stimulus_duration, negative_spike_timings);
                response_db_per_animal{n_units, stimulus_played} = [response_db_per_animal{n_units, stimulus_played}; spikes_from_timings];
                all_animals_response_cell_arr{all_animals_units_counter, stimulus_played} = [all_animals_response_cell_arr{all_animals_units_counter, stimulus_played}; spikes_from_timings];
            end
            all_animals_units_counter = all_animals_units_counter + 1;
            n_units = n_units + 1;
        end % end of unit

    end
    
    animal_field_str = strcat('animal',num2str(a));
    all_animals_db.(animal_field_str) = struct;
    all_animals_db.(animal_field_str).name = animal_names{a};
    all_animals_db.(animal_field_str).response = response_db_per_animal;
end
