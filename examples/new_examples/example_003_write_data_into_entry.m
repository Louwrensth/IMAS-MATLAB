%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                            put_entire_ids                                    ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝
% This example focuses on putting IDS into entry and passing IDS validation
    mode = 43;
    ctx = imas_open('imas:mdsplus?path=./testdb_mdsplus', mode);

    equilibrium = ids_init('equilibrium');

    % set mandatory field
    equilibrium.ids_properties.homogeneous_time = 1;

    % when ids_properties.homogeneous_time is set to IDS_TIME_MODE_HOMOGENEOUS,
    % all time-dependent fields values correspond to <ids>.time vector.
    equilibrium.time = [1.0, 2.0, 3.0];

    % intentional error when entering data. equilibrium/vacuum_toroidal_field/b0 should have the same size as equilibrium/time
    equilibrium.vacuum_toroidal_field.b0 = [1.0];

    % NOTE: putting ids into entry will NOT trigger validate function.
    % IDS fields types and dimensions must be checked by ids_validate function!
    % The try-catch statement below will work
    try
        ids_validate('equilibrium', equilibrium);
        ids_put(ctx, 'equilibrium', equilibrium);
    catch ME
        fprintf('Caught exception (raised intentionally)\n');
    end

    % fix wrong IDS field size
    equilibrium.vacuum_toroidal_field.b0 = [1.0, 2.0, 3.0];
    ids_put(ctx, 'equilibrium', equilibrium);
    clear equilibrium;

    % NOTE: some IDS fields are put automatically by Access Layer. Examples of this type of fields are:
    % - <ids>/ids_properties/version_put/data_dictionary
    % - <ids>/ids_properties/version_put/access_layer
    % - <ids>/ids_properties/version_put/access_layer_language

    % IDSs can be printed using fprintf() method.
    fprintf('Dumping equilibrium from ids_get() function\n');
    equilibrium_check = ids_get(ctx, 'equilibrium');
    fprintf('\tequilibrium.ids_properties.homogeneous_time: %i\n', equilibrium_check.ids_properties.homogeneous_time);
    fprintf('\tequilibrium.time:                            %i %i %i\n', equilibrium_check.time);
    fprintf('\tequilibrium.vacuum_toroidal_field.b0:        %i %i %i\n', equilibrium_check.vacuum_toroidal_field.b0);
    fprintf('\n');
    clear equilibrium_check;

    imas_close(ctx);

%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                            put_slice                                         ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝
% This example focuses on putting multiple slices of IDS into entry

    ctx = imas_open('imas:mdsplus?path=./testdb_mdsplus', mode);

    summary = ids_init('summary');

    % set mandatory field
    summary.ids_properties.homogeneous_time = 1;

    summary.heating_current_drive.nbi = ids_allocate('summary', 'heating_current_drive/nbi', 1);

    for x = 1:5
        % NOTE: time-independent data is being put only if it is empty in entry
        % In this case summary/stationary_phase_flag/source will be put only at first iteration.
        % Suggested way to fill this type of fields is to do this outside loop
        %summary.stationary_phase_flag.source = 
        summary.stationary_phase_flag.source = strcat('Name saved by example code iteration: ', num2str(x));
 
        % Fill example data
        summary.stationary_phase_flag.value = [10.0 .* x];

        % Fill 2D data
        summary.heating_current_drive.nbi{1}.beam_current_fraction.value = [ x*100, x*100, x*100 ]'; 

        % NOTE: it is user's responsibility to organize <ids>/time field in ascending manner
        % breaking this rule will make get_slice() command to fail
        % slice time is being appended to <ids>/time stored in entry
        summary.time = double(x);
        ids_put_slice(ctx, 'summary', summary);
    end

    % multiple slices can be put into entry as well
    summary.stationary_phase_flag.value = [11.0, 12.0, 13.0];
    summary.heating_current_drive.nbi{1}.beam_current_fraction.value = [[1000.0, 2000.0, 3000.0]; [1000.0, 2000.0, 3000.0]; [1000.0, 2000.0, 3000.0]]; 
    summary.time = [50.0, 60.0, 70.0];

    ids_validate('summary', summary);
    ids_put_slice(ctx, 'summary', summary);
    clear summary;

    % IDSs can be printed using fprintf() and dump() methods.
    fprintf('Dumping summary from fprintf() and disp() functions\n');
    summary_check = ids_get(ctx, 'summary');
    fprintf('\tsummary.ids_properties.homogeneous_time: %i\n', summary_check.ids_properties.homogeneous_time);
    fprintf('\tsummary.time: \n');
    disp(summary_check.time');
    fprintf('\tsummary.stationary_phase_flag.value:     %s\n');
    disp(summary_check.stationary_phase_flag.value');
    fprintf('\tsummary.stationary_phase_flag.source:    %s\n', summary_check.stationary_phase_flag.source);
    fprintf('\tsummary.heating_current_drive.nbi{0}.beam_current_fraction.value: \n'); 
    disp(summary_check.heating_current_drive.nbi{1}.beam_current_fraction.value); 
    fprintf('\n');
    clear summary_check;

    imas_close(ctx);

%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                            put_into_non_default_occurrence                   ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝
% This example focuses on putting IDS into another occurrence

    mode = 43;
    ctx = imas_open('imas:mdsplus?path=./testdb_mdsplus', mode);
    
    % default occurrence for get/put is 0
    % list of available occurrences can be found inside Data Dictionary documentation.
    equilibrium = ids_init('equilibrium');

    % set mandatory field
    equilibrium.ids_properties.homogeneous_time = 1;

    % when ids_properties.homogeneous_time is set to IDS_TIME_MODE_HOMOGENEOUS,
    % all time-dependent fields values correspond to <ids>.time vector.
    equilibrium.time = [1.0, 2.0, 3.0];

    % fill fields with some data
    equilibrium.vacuum_toroidal_field.r0 = 2.5;
    equilibrium.vacuum_toroidal_field.b0 = [10, 20, 30];

    % put IDS into occurrence 1
    ids_put(ctx, 'equilibrium', 1, equilibrium);

    % modify data, so differences between occurrences can be spotted
    equilibrium.vacuum_toroidal_field.r0 = 25.5;
    equilibrium.vacuum_toroidal_field.b0 = [11, 22, 33];

    % put IDS into occurrence 2
    ids_put(ctx, 'equilibrium', 2, equilibrium);
    clear equilibrium;

    % NOTE: there is ids_properties/occurrence_type structure
    % it stores additional information about specific occurrence

    % IDSs can be printed using fprintf() and dump() method
    fprintf('Dumping equilibrium (occurence 1) from put_another_occurence() function\n');
    equilibrium_check = ids_get(ctx, 'equilibrium', 1);
    fprintf('\tequilibrium.ids_properties.homogeneous_time: %i\n', equilibrium_check.ids_properties.homogeneous_time);
    fprintf('\tequilibrium.time:                            %i %i %i\n', equilibrium_check.time);
    fprintf('\tequilibrium.vacuum_toroidal_field.r0:        %i\n', equilibrium_check.vacuum_toroidal_field.r0);
    fprintf('\tequilibrium.vacuum_toroidal_field.b0:        %i %i %i\n', equilibrium_check.vacuum_toroidal_field.b0);

    % occurrences can be listed with imas_list_all_occurrences() function
    % list_all_occurrences also returns content of IDS pointed by node_path argument
    [occurrence_list, node_content_list] = imas_list_all_occurrences(ctx, 'equilibrium', 'vacuum_toroidal_field/r0');
    
    fprintf('occurence list: [%i %i]\n ', occurrence_list);
    fprintf('equilibrium/vacuum_toroidal_field/r0 in different occurrences: \n');
    disp(node_content_list);
    clear equilibrium_check;

    imas_close(ctx);
