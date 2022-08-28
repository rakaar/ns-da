%% unit wise db psth
close all;
stimulus_sets = 16; 

bin_size = 5;
total_stimulus_duration = 2500;
response_binned_cell = cell(stimulus_sets,1);

cell_to_be_analysed = only_sig_units_db;
num_of_units = 184;

for s=1:stimulus_sets
    response_for_each_stimulus = [];
    for u=1:num_of_units
        response_for_each_stimulus = [response_for_each_stimulus; cell_to_be_analysed{u,s}]; 
    end

    mean_response_for_each_stimulus = mean(response_for_each_stimulus, 1);
    mean_response_for_each_stimulus_reshaped = reshape(mean_response_for_each_stimulus,  bin_size, total_stimulus_duration/bin_size);
    binned_response_for_each_stimulus = mean(mean_response_for_each_stimulus_reshaped, 1);
   
    stimulus = get_stimulus_from_wav(s)*0.03;
    stimulus_reshaped = reshape(stimulus, bin_size, total_stimulus_duration/bin_size);
    stimulus_binned = mean(stimulus_reshaped, 1);
 
    response_binned_cell{s,1} = binned_response_for_each_stimulus;
    figure
        hold on
            plot(binned_response_for_each_stimulus)
            plot(stimulus_binned);
        hold off
        title(['stimulus-',num2str(s),'-bin-size-',num2str(bin_size)])
    grid
end
%%  same gap in one plot
close all;
all_response_matrix = zeros(stimulus_sets, total_stimulus_duration/bin_size);

for s=1:stimulus_sets
    response_for_each_stimulus = [];
    for u=1:num_of_units
        response_for_each_stimulus = [response_for_each_stimulus; cell_to_be_analysed{u,s}]; 
    end

    mean_response_for_each_stimulus = mean(response_for_each_stimulus, 1);
    mean_response_for_each_stimulus_reshaped = reshape(mean_response_for_each_stimulus,  bin_size, total_stimulus_duration/bin_size);
    binned_response_for_each_stimulus = mean(mean_response_for_each_stimulus_reshaped, 1);
    all_response_matrix(s,:) = binned_response_for_each_stimulus;
   
end

% plot all 4 with same in one gap
gap = [60, 90, 150, 280];
for p=1:4
    figure
        response_for_single_gap = all_response_matrix(p:4:p+12,:);
        hold on
        plot(response_for_single_gap.')

          stimulus = get_stimulus_from_wav(s)*0.03;
          stimulus_reshaped = reshape(stimulus, bin_size, total_stimulus_duration/bin_size);
          stimulus_binned = mean(stimulus_reshaped, 1);
          plot(stimulus_binned)
        hold off
        legend('T1-T1-T1T2', 'T1T2-T1T2-T1', 'T1T2-T1T2-T1T2', 'T1-T1-T1', 'stimulus')
        title(['gap-',num2str(gap(p)),'-binned-gap-',num2str(gap(p)/bin_size)])
    grid
end


%% the same analysis as above but animal wise
close all;
stimulus_sets = 16;

animal_number = 2;
num_of_units = 299;
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
   
    stimulus = get_stimulus_from_wav(s)*0.03;
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

