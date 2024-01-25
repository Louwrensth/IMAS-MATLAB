ad = ids_gen('amns_data');

disp('Test empty IDS:')
try
    ids_validate('amns_data', ad)
catch ME
    switch ME.identifier
        case 'IMAS:ids_validate:empty_ids'
            if not(contains(ME.message,'ids%ids_properties%homogeneous_time is not defined'))
                rethrow(ME)
            end 
        otherwise
            rethrow(ME)
    end
end
disp('Test passed...')
fprintf("\n")

ad.ids_properties.homogeneous_time = 1;

disp('Test empty time:')
try
    ids_validate('amns_data', ad)
catch ME
    switch ME.identifier
        case 'IMAS:ids_validate:empty_time'
            if not(contains(ME.message,'If time is homogeneous, ids%time must have at least one element'))
                rethrow(ME)
            end 
        otherwise
            rethrow(ME)
    end
end
disp('Test passed...')
fprintf("\n")

disp('Test non-empty time:')
ad.time(1) = 0.1;
try
    ids_validate('amns_data', ad)
catch ME
    rethrow(ME)
end
disp('Test passed...')
fprintf("\n")

disp('Test coordinate_index:')
ad.process{1}.charge_state{1}.table_1d(1) = 1.0;
ad.process{1}.coordinate_index = 1;
ad.coordinate_system{1}.coordinate{1}.values(3) = 1.0;
ad.coordinate_system{2}.coordinate{1}.values(1) = 1.0;
try
    ids_validate('amns_data', ad)
catch ME
    switch ME.identifier
        case 'IMAS:ids_validate:internal_error'
            if not(contains(ME.message,'internal error of type HLI occured with message:') & ...
                contains(ME.message,'Wrong dimension 1 for /table_1d (1).') & ...
                contains(ME.message,'(coordinate_system(process(i1)/coordinate_index)/coordinate(1)/values)')) 
                rethrow(ME)
            end 
        otherwise
            rethrow(ME)
    end
end
disp('Test passed...')
fprintf("\n")

disp('Test coordinate_index fixed:')
ad.process{1}.coordinate_index = 2;
try
    ids_validate('amns_data', ad)
catch ME
    rethrow(ME)
end
disp('Test passed...')
fprintf("\n")