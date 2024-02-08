w = ids_gen('waves');

disp('Test empty IDS:')
try
    ids_validate('waves', w)
    disp("Error: no exception occured.")
catch ME
    switch ME.identifier
        case 'IMAS:ids_validate:empty_ids'
            if not(contains(ME.message,'ids%ids_properties%homogeneous_time is not defined'))
                rethrow(ME)
            else
                disp('Test passed...')
            end 
        otherwise
            rethrow(ME)
    end
end
fprintf("\n")

w.ids_properties.homogeneous_time = 1;

disp('Test empty time:')
try
    ids_validate('waves', w)
    disp("Error: no exception occured.")
catch ME
    switch ME.identifier
        case 'IMAS:ids_validate:empty_time'
            if not(contains(ME.message,'If time is homogeneous, ids%time must have at least one element'))
                rethrow(ME)
            else 
                disp('Test passed...')
            end 
        otherwise
            rethrow(ME)
    end
end
fprintf("\n")

w.time(1) = 0.1;

w.coherent_wave{1}.global_quantities{1}.n_tor(1) = 1.0;
w.coherent_wave{1}.global_quantities{1}.n_tor(2) = 8.0;
w.coherent_wave{1}.global_quantities{1}.ion{1}.power_thermal_n_tor(1) = 5.0;
w.coherent_wave{1}.global_quantities{1}.ion{1}.power_thermal_n_tor(2) = 5.0;

w.coherent_wave{1}.global_quantities{1}.ion{2}.power_thermal_n_tor(1) = 5.0;
w.coherent_wave{1}.global_quantities{1}.ion{2}.power_thermal_n_tor(2) = 5.0;

w.coherent_wave{1}.profiles_1d{1}.power_density(4)= 0.5;
w.coherent_wave{1}.profiles_1d{1}.grid.rho_tor_norm(1)= 0.1;
w.coherent_wave{1}.profiles_1d{1}.grid.rho_tor_norm(2)= 0.2;
w.coherent_wave{1}.profiles_1d{1}.grid.rho_tor_norm(3)= 0.3;
w.coherent_wave{1}.profiles_1d{1}.grid.rho_tor_norm(4)= 0.4;
w.coherent_wave{1}.profiles_1d{1}.grid.rho_tor_norm(5)= 0.5;

disp('Test empty power_density size not equals to rho_tor_norm:')
try
    ids_validate('waves', w)
    disp("Error: no exception occured.")
catch ME
    switch ME.identifier
        case 'IMAS:ids_validate:internal_error'
            if not(contains(ME.message,'grid/rho_tor_norm'))
                rethrow(ME)
            else 
                disp('Test passed...')
            end 
        otherwise
            rethrow(ME)
    end
end
fprintf("\n")
