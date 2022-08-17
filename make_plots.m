%% animal wise
field_names_db = fieldnames(all_animals_database);
bin_size = 1; % in ms
matfiles_path = "D:\da_mat_files";
images_path = "D:\da-images";
for i=1:length(field_names_db)
    animal_field = field_names_db{i};
    animal_data = all_animals_database.(animal_field);

    animal_name = animal_data.name;
    channels_data = animal_data.channels;

    for s=1:num_stimulus_sets
        stimulus_field_str = strcat('stimulus',num2str(s));
        stimulus_wave = get_stimulus_wave(stimulus_type, all_stimulus_code,all_stimulus_code_struct, pre_stimulus_silence);
        response_all_channels = [];

        for c=1:num_channels
            channel_field_str = strcat('channel',num2str(c));
            responses_in_channel = channels_data.(channel_field_str);
            if length(fieldnames(responses_in_channel)) == 0
                continue; % no data in this channel
            end
            response_for_stimulus = responses_in_channel.(stimulus_field_str);
            
            fields_response_for_stimulus_struct = fieldnames(response_for_stimulus);
            num_reps = (length(fields_response_for_stimulus_struct) - 1)/2;
           
            for n=1:num_reps
                spikes_rep_field = strcat('spikes',num2str(n));
                spikes_rep = response_for_stimulus.(spikes_rep_field);
                response_all_channels = [response_all_channels; spikes_rep];
            end
        end % end of all channels
         
        matfile_name = strcat(animal_name,'-stimulus-',num2str(s),'-all-reps-channel-avg-spikes.mat');
        matfile_path = strcat(matfiles_path,'\',matfile_name);
        save(matfile_path);


        % make psth
        spikes_avg_all_reps_all_channels = mean(response_all_channels, 1);
        spikes_avg_reshape = reshape(spikes_avg_all_reps_all_channels,  bin_size, length(spikes_avg_all_reps_all_channels)/bin_size);
        spikes_avg_binned = mean(spikes_avg_reshape,1)/(bin_size * 0.001);


        figure
            hold on
                plot(spikes_avg_binned)
                plot(stimulus_wave, 'LineWidth',5)
            hold off
            
            title(['animal-',animal_name,'-stimulus-',num2str(s),'-all-channels-avg-all-reps-avg-bin-size', num2str(bin_size)]);
            
            image_name = strcat(images_path,'\','animal-',animal_name,'-stimulus-',num2str(s),'-all-channels-avg-all-reps-avg-bin-size', num2str(bin_size),'.fig');
            saveas(gcf, image_name);
        grid
    end

end
