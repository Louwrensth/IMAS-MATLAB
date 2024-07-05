%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                            read_entire_ids                                   ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝
% This example focuses on reading whole IDS from entry.
% We are storing and reading back an IDS - equilibrium. Data are stored inside MDS+ file.

    % NOTE: this block of code uses 'w' mode in order to create example data
    mode_w = 43;
    ctx = imas_open('imas:mdsplus?path=./testdb_mdsplus', mode_w);
    
    % fill IDS with example data
    equilibrium = ids_init('equilibrium');
    equilibrium.ids_properties.homogeneous_time = 1;
    equilibrium.time = [1.0, 2.0, 3.0];
    equilibrium.vacuum_toroidal_field.b0 = [1.0, 2.0, 3.0];
    ids_put(ctx, 'equilibrium', equilibrium);
    clear equilibrium;

    % NOTE: this block of code uses 'r' mode in order to read example data
    mode_r = 40;
    ctx = imas_open('imas:mdsplus?path=./testdb_mdsplus', mode_r);
    equilibrium_check = ids_get(ctx, 'equilibrium');

    % here you can access content of the IDS equilibrium
    % some_variable = equilibrium.some_element
    % equilibrium.some_element = ...
    % etc.

    % one may check if IDS was filled with data using ids_isdefined() method
    is_defined = ids_isdefined(equilibrium_check);
    fprintf('is equilibrium defined?: %s\n', mat2str(is_defined));

    clear equilibrium_check;
    imas_close(ctx);

%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                            read_slice                                        ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝
% This example focuses on reading IDS slices from entry
% We are storing and reading back an IDS - summary. Data are stored inside MDS+ file.

    % NOTE: this block of code uses 'w' mode in order to create example data
    ctx = imas_open('imas:mdsplus?path=./testdb_mdsplus', mode_w);

    % fill IDS with example data
    summary = ids_init('summary');
    summary.ids_properties.homogeneous_time = 1;
    summary.global_quantities.ip.value = [10.0, 11.0, 12.0];
    summary.heating_current_drive.nbi = ids_allocate('summary', 'heating_current_drive/nbi', 1); 
    summary.heating_current_drive.nbi{1}.beam_current_fraction.value = [[0.0, 0.0, 0.0]; [0.0, 100.0, 200.0]; [0.0, 200.0, 400.0]];
    summary.time = [1.0, 2.0, 3.0];
    
    fprintf('\tsummary.ids_properties.homogeneous_time: %i\n', summary.ids_properties.homogeneous_time);
    fprintf('\tsummary.time:                            %.1f %.1f %.1f\n', summary.time);
    fprintf('\tsummary.global_quantities.ip.value:      %.1f %.1f %.1f\n', summary.global_quantities.ip.value);
    fprintf('\tsummary.heating_current_drive.nbi{1}.beam_current_fraction.value: \n'); 
    disp(summary.heating_current_drive.nbi{1}.beam_current_fraction.value); 
    fprintf('\n');
    ids_put(ctx, 'summary', summary);
    
    clear summary;
    imas_close(ctx);

    % NOTE: this block of code uses 'r' mode in order to read example data
    ctx = imas_open('imas:mdsplus?path=./testdb_mdsplus', mode_r);

    % Access Layer API shares 3 different methods of interpolating values from imas_open
    % 1: CLOSEST_SAMPLE
    % 2: PREVIOUS_SAMPLE
    % 3: INTERPOLATION

    % this part of code presents PREVIOUS_SAMPLE. It is interpolation method that returns the previous time slice if the requested time does not exactly exist in the original IDS
    % if requested time is outside of time array, first, or last slice will be returned respectively
    time_requested=1.75;
    summary = ids_get_slice(ctx, 'summary', time_requested, 2);
    % previous time value for 1.75 is 1.0
    % summary/global_quantities/ip/value and time=1 is 10.0
    fprintf('summary/global_quantities/ip/value for time=1:    %.1f  (Should be 10.0)\n', summary.global_quantities.ip.value);
    clear summary;

    % this part of code presents CLOSEST_SAMPLE. It is interpolation method that returns the closest time slice in the original IDS
    % if requested time is equally spaced between two time slices, slice with higher index will be returned
    time_requested=1.75;
    summary = ids_get_slice(ctx, 'summary', time_requested, 1);
    % closest time value to 1.75 is 2.0
    % value for summary/global_quantities/ip/value and time=2 is 11.0
    fprintf('summary/global_quantities/ip/value for time=2:    %.1f  (Should be 11.0)\n', summary.global_quantities.ip.value);
    clear summary;

    % this part of code presents INTERPOLATION. It is interpolation method that returns a linear interpolation between the existing slices before and after the requested time.
    % NOTE: The linear interpolation will be successful only if, between the two time slices of an interpolated dynamic array of structure,
    % the same leaves are populated and they have the same size.
    % Otherwise DBEntry.get_slice() will interpolate all fields with a compatible size and leave others empty.

    % NOTE: If time requested is smaller than <ids>.time[0], first slice will be returned. If requested time exceeds highest time, last slice will be returned.
    time_requested=1.75;
    summary = ids_get_slice(ctx, 'summary', time_requested, 3);
    % interpolated value for summary/global_quantities/ip/value and time=1.75 is 10.75
    fprintf('summary/global_quantities/ip/value for time=1.75: %.2f (Should be 10.75)\n', summary.global_quantities.ip.value);
    
    clear summary;
    imas_close(ctx);

%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                            partial_get                                       ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝
%
%   The MATLAB interface does not support partial_get
