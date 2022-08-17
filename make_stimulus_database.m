%% make stimulus wise database 
clear all
sorted_data_path = "D:\ami_hc_new_data_ephys\sorted data";
all_stimulus_code = load("D:\da\stimulus_sets.mat").HC_rand_mat;
num_channels = 16;
num_stimulus_sets = 16;
num_iters = 5;
all_stimulus_database = struct;
max_iters = 10;

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

% initialise struct
for s=1:num_stimulus_sets
    stimulus_field_str = strcat('stimulus',num2str(s));
    all_stimulus_database.(stimulus_field_str) = struct;
    all_stimulus_database.(stimulus_field_str).waveform = get_stimulus_wave(s, all_stimulus_code, all_stimulus_code_struct, pre_stimulus_silence);
    for iter=1:max_iters
        iter_field_str = strcat('iter',num2str(iter));
        all_stimulus_database.(stimulus_field_str).(iter_field_str) = struct;
    end
end

all_folders_info = dir(sorted_data_path);
animal_names = {};
for i=3:length(all_folders_info)
    animal_names = [animal_names, all_folders_info(i).name];
end

for a=1:length(animal_names)
    disp('a')
    disp(animal_names{a})
    stimulus_path = strcat(sorted_data_path, '\', animal_names{a}, '\', 'stimcodes');
    disp('stimulus path')
    disp(stimulus_path)
    stimulus_path_info = dir(stimulus_path);
      
    for s=3:length(stimulus_path_info)
        stimulus_file = strcat(stimulus_path, '\', stimulus_path_info(s).name);
        disp(stimulus_file)
        stimulus_matrix = load(stimulus_file).codes; % 16 x 5 matrix
        for iter=1:num_iters
                
        end
    end
end

%% testing cell array
test = cell(16,5);
test{3,2} =  [test{3,2}; zeros(1,2000)];
test{3,2} =  [test{3,2},; ones(1,2000)];
