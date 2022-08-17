clear all;
% makes database of animals, channels,stimulus, timings and spikes in each
% iter
sorted_data_path = "D:\ami_hc_new_data_ephys\sorted data";
all_animals_database = struct; % contains each animals data with psth
all_folders_info = dir(sorted_data_path);
num_channels = 16;
num_stimulus_sets = 16;
num_iters = 5;
all_stimulus_code = load("D:\da\stimulus_sets.mat").HC_rand_mat;
all_stimulus_code_struct = struct;
T1 = 6; T2 = 2*T1; T12 = T1 + T2;

pre_stimulus_silence = zeros(1, 500);
all_stimulus_code_struct.('s1') = T1*ones(1,50);
all_stimulus_code_struct.('s2') = T2*ones(1,50);
all_stimulus_code_struct.('s3') = T12*ones(1,50);

all_stimulus_code_struct.('s4') = zeros(1,60);
all_stimulus_code_struct.('s5') = zeros(1,90);
all_stimulus_code_struct.('s6') = zeros(1,150);
all_stimulus_code_struct.('s7') = zeros(1,280);


animal_names = {};
for i=3:length(all_folders_info)
    animal_names = [animal_names, all_folders_info(i).name];
end

for a=1:length(animal_names)
    animal_data_struct = struct;
    animal_data_struct.name = animal_names{1};
    animal_data_struct.channels = struct;

    stimulus_path = strcat(sorted_data_path, '\', animal_names{a}, '\', 'stimcodes');
    stimulus_path_info = dir(stimulus_path);
    for s=3:length(stimulus_path_info)
        stimulus_file = strcat(stimulus_path, '\', stimulus_path_info(s).name);
        stimulus_matrix = load(stimulus_file).codes; % 16 x 5 matrix
        
        recording_file = strrep(stimulus_file, '_stimcode', '_unit_record');
        recording_file = strrep(recording_file, '\stimcodes\', '\');
        unit_record_spike = load(recording_file).unit_record_spike;
        num_channels_with_data = length(unit_record_spike);

        negative_spike_time = unit_record_spike.negspiketime;
        if isempty(negative_spike_time)
            continue; % for this stimulus, no response in this channel
        end
        cluster1_negative_spike_time = negative_spike_time.cl1;
        
        for channel=1:num_channels
             channel_num_str = strcat('channel', num2str(channel)); 
             if ~isfield(animal_data_struct.channels, channel_num_str)
                    animal_data_struct.channels.(channel_num_str) = struct;
             end
              if channel > num_channels_with_data
                continue; % the channel doesn't give data
              end
            
            negative_spike_time = unit_record_spike(channel).negspiketime;
            
            if isempty(negative_spike_time)
                continue; % no data in the channel, skip rest of the loop
            end
            cluster1_negative_spike_time = negative_spike_time.cl1;

            for iter=1:num_iters
                for stim_set=1:num_stimulus_sets
                    iter_index = (iter-1)*num_stimulus_sets + stim_set;
                    stimulus_type = stimulus_matrix(stim_set, iter);
                    stimulus_type_str = strcat('stimulus', num2str(stimulus_type));
                    if ~isfield(animal_data_struct.channels.(channel_num_str), stimulus_type_str)
                        animal_data_struct.channels.(channel_num_str).(stimulus_type_str) = struct;
                        animal_data_struct.channels.(channel_num_str).(stimulus_type_str).stimulus_wave = get_stimulus_wave(stimulus_type, all_stimulus_code, all_stimulus_code_struct, pre_stimulus_silence);
                    end
                  

                    rep_num = ((length(fieldnames(animal_data_struct.channels.(channel_num_str).(stimulus_type_str))) - 1)/2) + 1;
                    iter_index_field = strcat('iter', num2str(iter_index));
                    spike_times = cluster1_negative_spike_time.(iter_index_field);
                    stimulus_duration = length(animal_data_struct.channels.(channel_num_str).(stimulus_type_str).stimulus_wave);
                    spikes = get_spikes_from_timings(stimulus_duration, spike_times);
                   
                    spike_times_field = strcat('spike_times', num2str(rep_num));
                    spikes_field = strcat('spikes', num2str(rep_num));

                    animal_data_struct.channels.(channel_num_str).(stimulus_type_str).(spike_times_field) = spike_times;
                    animal_data_struct.channels.(channel_num_str).(stimulus_type_str).(spikes_field) = spikes;
                    
                end
            end
        end % end of channel
        

    end

    all_animals_database.(strcat('animal', num2str(a))) = animal_data_struct;
end

%% make stimulus wise database
