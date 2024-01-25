d = ids_gen('distributions');

disp('Test empty IDS:')
try
    ids_validate('distributions', d)
    disp("Error: no exception occured.")
catch ME
    switch ME.identifier
        case 'IMAS:ids_validate:empty_ids'
            disp('Test passed...')
        otherwise
            rethrow(ME)
    end
end
fprintf("\n")

d.ids_properties.homogeneous_time = 1;

disp('Test empty time:')
try
    ids_validate('distributions', d)
    disp("Error: no exception occured.")
catch ME
    switch ME.identifier
        case 'IMAS:ids_validate:empty_time'
            disp('Test passed...')
        otherwise
            rethrow(ME)
    end
end
fprintf("\n")

d.time(1) = 0.1;

d.distribution{1}.profiles_2d{1}.grid.r(3) = 1.0;
d.distribution{1}.profiles_2d{1}.grid.z(3) = 1.0;
d.distribution{1}.profiles_2d{1}.grid.theta_straight(3) = 1.0;
d.distribution{1}.profiles_2d{1}.density(3,2) = 1.0;

disp('Test alternatives coordinates issues:')
try
    ids_validate('distributions', d)
    disp("Error: no exception occured.")
catch ME
    switch ME.identifier
        case 'IMAS:ids_validate:internal_error'
            disp('Test passed...')
        otherwise
            rethrow(ME)
    end
end
fprintf("\n")

d = ids_gen('distributions');
d.ids_properties.homogeneous_time = 1;
d.time(1) = 0.1;
d.distribution{1}.profiles_2d{1}.grid.r(3) = 1.0;
d.distribution{1}.profiles_2d{1}.grid.z(3) = 1.0;
d.distribution{1}.profiles_2d{1}.density(3,2) = 1.0;

disp('Test matching size coordinates issues:')
try
    ids_validate('distributions', d)
    disp("Error: no exception occured.")
catch ME
    switch ME.identifier
        case 'IMAS:ids_validate:internal_error'
            disp('Test passed...')
        otherwise
            rethrow(ME)
    end
end
fprintf("\n")

d.distribution{1}.profiles_2d{1}.density(3,3) = 1.0;

disp('Test matching size coordinates issues fixed:')

try
    ids_validate('distributions', d)
    disp('Test passed...')
catch ME
    rethrow(ME)
end
fprintf("\n")

d = ids_gen('distributions');
d.ids_properties.homogeneous_time = 1;
d.time(1) = 0.1;
d.distribution{1}.ggd{1}.grid.grid_subset{1}.element{3}.object{1}.dimension = 1;
d.distribution{1}.ggd{1}.grid.grid_subset{1}.base{1}.tensor_covariant(:,:,5) = [10 11 12 13 14; 13 14 15 16 17; 16 17 18 19 20];
d.distribution{1}.ggd{1}.grid.grid_subset{1}.base{1}.tensor_contravariant(:,:,6) = [10 11 12 13 14; 13 14 15 16 17; 16 17 18 19 20];

disp('Test multiple alternative coordinates same_as:')

try
    ids_validate('distributions', d)
    disp("Error: no exception occured.")
catch ME
    switch ME.identifier
        case 'IMAS:ids_validate:internal_error'
            disp('Test passed...')
        otherwise
            rethrow(ME)
    end
end
fprintf("\n")

d.distribution{1}.ggd{1}.grid.grid_subset{1}.base{1}.tensor_covariant(:,:,6) = [10 11 12 13 14; 13 14 15 16 17; 16 17 18 19 20];

disp('Test multiple alternative coordinates same_as fixed:')
try
    ids_validate('distributions', d)
catch ME
    rethrow(ME)
end
disp('Test passed...')
fprintf("\n")

d = ids_gen('distributions');
d.ids_properties.homogeneous_time = 0;
d.time(1) = 0.1;
for a=1:6
    d.distribution{a}.global_quantities{1}.time = 0.1;
    d.distribution{a}.profiles_1d{1}.time = 0.1;
    d.distribution{a}.ggd{1}.time = 0.1;
    d.distribution{a}.markers{1}.time = 0.1;
    for b=1:6
        d.distribution{a}.profiles_2d{b}.time = b;
    end
    d.distribution{a}.profiles_2d{7}.trapped.collisions.ion{1}.element{1}.a = 0.5;
    for b=8:15
        d.distribution{a}.profiles_2d{b}.time = b;
    end
end
disp('Test heterogeneous scalar time coordinate issue:')
try
    ids_validate('distributions', d)
    disp("Error: no exception occured.")
catch ME
    switch ME.identifier
        case 'IMAS:ids_validate:internal_error'
            disp('Test passed...')
        otherwise
            rethrow(ME)
    end
end
fprintf("\n")

for a=1:6
    d.distribution{a}.profiles_2d{7}.time = 7;
end

disp('Test heterogeneous scalar time coordinate issue fixed:')
try
    ids_validate('distributions', d)
catch ME
    rethrow(ME)
end
disp('Test passed...')
fprintf("\n")