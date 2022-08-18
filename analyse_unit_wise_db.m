%% unit wise db psth
close all;
stimulus_sets = 16;
num_of_units = 305;
bin_size = 5;
total_stimulus_duration = 2500;

for s=1:stimulus_sets
    response_for_each_stimulus = [];
    for u=1:num_of_units
        response_for_each_stimulus = [response_for_each_stimulus; all_animals_response_cell_arr{u,s}]; 
    end

    mean_response_for_each_stimulus = mean(response_for_each_stimulus, 1);
    mean_response_for_each_stimulus_reshaped = reshape(mean_response_for_each_stimulus,  bin_size, total_stimulus_duration/bin_size);
    binned_response_for_each_stimulus = mean(mean_response_for_each_stimulus_reshaped, 1);
   
    stimulus = get_stimulus_shape(s,0.03);
    stimulus_reshaped = reshape(stimulus, bin_size, total_stimulus_duration/bin_size);
    stimulus_binned = mean(stimulus_reshaped, 1);
 
    figure
        hold on
            plot(binned_response_for_each_stimulus)
            plot(stimulus_binned);
        hold off
        title(['stimulus-',num2str(s),'-bin-size-',num2str(bin_size)])
    grid
end

%% the same analysis as above but animal wise
close all;
stimulus_sets = 16;

animal_number = 2;
num_of_units = 87;
animal_field_str = strcat('animal',num2str(animal_number));

animal_response = all_animals_db.(animal_field_str);
animal_response = animal_response.response;

bin_size = 10;
total_stimulus_duration = 2500;

for s=1:stimulus_sets
    response_for_each_stimulus = [];
    for u=1:num_of_units
        response_for_each_stimulus = [response_for_each_stimulus; animal_response{u,s}]; 
    end

    mean_response_for_each_stimulus = mean(response_for_each_stimulus, 1);
    mean_response_for_each_stimulus_reshaped = reshape(mean_response_for_each_stimulus,  bin_size, total_stimulus_duration/bin_size);
    binned_response_for_each_stimulus = mean(mean_response_for_each_stimulus_reshaped, 1);
   
    stimulus = get_stimulus_shape(s,0.03);
    stimulus_reshaped = reshape(stimulus, bin_size, total_stimulus_duration/bin_size);
    stimulus_binned = mean(stimulus_reshaped, 1);
 
    figure
        hold on
            plot(binned_response_for_each_stimulus)
            plot(stimulus_binned);
        hold off
        title(['stimulus-',num2str(s),'-bin-size-',num2str(bin_size)])
    grid
end

