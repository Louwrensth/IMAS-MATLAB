%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                            creating_completly_new_ids                        ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝
    % This example focuses on creating empty IDS and allocating arrays inside IDS structure

    % empty IDS structures can be created without opening data entry
    % all you have to do is to instantiate IDS object

    empty_core_profiles = ids_init('core_profiles');

    % Note! Every IDS must have <ids>/ids_properties/homogeneous_time field set with one of possible values
    % Possible homogeneous_time values are:
    %  0 - IDS_TIME_MODE_HETEROGENEOUS: All time-dependent quantities in the IDS may have different time coordinates.
    %  1 - IDS_TIME_MODE_HOMOGENEOUS: All time-dependent quantities in this IDS use the same time coordinate, namely <ids>/time
    %  2 - IDS_TIME_MODE_INDEPENDENT: The IDS stores no time-dependent data.
    empty_core_profiles.ids_properties.homogeneous_time = 1;

    % it is also recommended to provide basic information regarding data source
    % even though this information is not required to store IDS, it is highly recommended
    % to fill these fields.
    %  <ids>/ids_properties/comment
    %  <ids>/ids_properties/provider
    %  <ids>/ids_properties/creation_date

    % when ids_properties.homogeneous_time is set to IDS_TIME_MODE_HOMOGENEOUS, 
    % all time-dependent fields values correspond to <ids>.time vector.
    empty_core_profiles.time = [1.0, 2.0, 3.0];

    % size of time dependent variables must be equal to the size of time vector
    empty_core_profiles.global_quantities.ip = [1.0, 2.0, 3.0];

    % IDSs can be printed using frpintf() method.
    fprintf('Dumping empty_core_profiles:\n');
    fprintf('\tempty_core_profiles.ids_properties.homogeneous_time: %i\n', empty_core_profiles.ids_properties.homogeneous_time);
    fprintf('\tempty_core_profiles.time:                            %i %i %i\n', empty_core_profiles.time);
    fprintf('\tempty_core_profiles.global_quantities.ip:            %i %i %i\n', empty_core_profiles.global_quantities.ip);
    fprintf('\n');

    % some fields are automatically written by AL during 'put' procedure
    % AL adds some information behind your back. This is particularly important
    % in case you want later on find out what particular version of AL was used when data were stored.
    % examples of this type of fields are <ids>/ids_properties/version_put and <ids>/ids_properties/plugins

    % this time we do not save IDS into database entry, all we do here is deallocating the memory
    % we have allocated in all previous steps.
    clear empty_core_profiles;

%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                            default_values_and_aos_operations                 ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝
% This example focuses on handling arrays of structures and default values

    % create empty edge_profiles
    edge_profiles = ids_init('edge_profiles');

    % set mandatory field
    edge_profiles.ids_properties.homogeneous_time = 1;

    % edge_profiles/grid_ggd is array of structures and must be resized before accessing any of it's elements
    edge_profiles.grid_ggd = ids_allocate('edge_profiles', 'grid_ggd', 1);
    edge_profiles.grid_ggd{1}.identifier.name = 'First test struct';

    % single element can be added to AoS the following way
    % in this example we will create copy of edge_profiles.grid_ggd{1} and modify it's values
    aos_element = edge_profiles.grid_ggd{1};
    aos_element.identifier.name = 'Second test struct';

    % append aos_element to edge_profiles.grid_ggd AoS
    edge_profiles.grid_ggd{2} = aos_element;

    % common action would be merging two different AoS
    % edge_profiles2/grid_ggd will be merged with edge_profiles/grid_ggd
    % first, we have to create new AoS and fill it with data
    edge_profiles2 = ids_init('edge_profiles');
    edge_profiles2.grid_ggd = ids_allocate('edge_profiles', 'grid_ggd', 1);
    edge_profiles2.grid_ggd{1}.identifier.name = 'Third test struct';

    % once data are in place, we can merge two AoS objects
    for idx = length(edge_profiles2.grid_ggd)
        next_position = length(edge_profiles.grid_ggd) +1;
        edge_profiles.grid_ggd{next_position} = edge_profiles2.grid_ggd{idx};
    end

    fprintf('edge_profiles/grid_ggd after merge:\n');
    for struct_to_display = edge_profiles.grid_ggd
       fprintf('\tstruct_to_display{1}.identifier.name: %s\n', struct_to_display{1}.identifier.name);
    end
    fprintf('\n');

    % ids fields have default values different for every data type
    fprintf('Default value for "INT"          %i (edge_profiles/midplane/index) \n', edge_profiles.midplane.index);
    fprintf('Default value for "FLOAT"        %s (edge_profiles/vacuum_toroidal_field/vacuum_toroidal_field/r0) \n', edge_profiles.vacuum_toroidal_field.r0);
    fprintf('Default value for 1+ dimensional [%s]  (Empty array)\n', edge_profiles.vacuum_toroidal_field.b0);
    fprintf('\n');

    % IDSs can be printed using fprintf() method.
    fprintf('edge_profiles.ids_properties.homogeneous_time: %i\n', edge_profiles.ids_properties.homogeneous_time);
    fprintf('\tedge_profiles.grid_ggd{1}.identifier.name:     %s\n', edge_profiles.grid_ggd{1}.identifier.name);
    fprintf('\tedge_profiles.grid_ggd{2}.identifier.name:     %s\n', edge_profiles.grid_ggd{2}.identifier.name);
    fprintf('\tedge_profiles.grid_ggd{3}.identifier.name:     %s\n', edge_profiles.grid_ggd{3}.identifier.name);
    fprintf('\n');

    clear edge_profiles;
    clear edge_profiles2;

%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                            copying_and_validating_ids                        ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝
% This example focuses on creating multi-dimensional arrays, using copmlex type and copying IDS structures

    % create empty gyrokinetics_local
    % NOTE: gyrokinetics_local is an alpha IDS
    gyrokinetics_local = ids_init('gyrokinetics_local');

    % there is mandatory field <ids>/ids_properties/homogeneous_time
    gyrokinetics_local.ids_properties.homogeneous_time = 1; 

    % some IDS fields contain multi-dimensional arrays
    gyrokinetics_local.non_linear.fields_zonal_2d.phi_potential_perturbed_norm = ones(3,3);
    fprintf('Filled 2D array (gyrokinetics_local/non_linear/fields_zonal_2d/phi_potential_perturbed_norm):\n');
    disp(gyrokinetics_local.non_linear.fields_zonal_2d.phi_potential_perturbed_norm);

    % some fields have coordinates consistency. isd_validate() method checks for this consistency.
    % example of field of this type is gyrokinetics_local/non_linear/fields_zonal_2d/phi_potential_perturbed_norm
    % it's first dimension size must be equal to non_linear/radial_wavevector_norm size and second dimension size equal to non_linear/time_norm
    try
        ids_validate('gyrokinetics_local', gyrokinetics_local);
    catch ME
        disp('Caught exception (raised intentionally)');
    end

    % to fix this
    gyrokinetics_local.non_linear.radial_wavevector_norm = [1.0, 2.0, 3.0];
    gyrokinetics_local.non_linear.time_norm              = [1.0, 2.0, 3.0];

    % gyrokinetics_local/linear.wavevector(i1)/eigenmode(i2)/fields.phi_potential_perturbed_norm has two dimensions and stores complex numbers

    gyrokinetics_local.linear.wavevector = ids_allocate('gyrokinetics_local', 'linear/wavevector', 1);
    gyrokinetics_local.linear.wavevector{1}.eigenmode = ids_allocate('gyrokinetics_local', 'linear/wavevector/eigenmode', 1);
    gyrokinetics_local.linear.wavevector{1}.eigenmode{1}.fields.phi_potential_perturbed_norm = complex(ones(3,3),ones(3,3)); 

    % right way to copy IDS
    gyrokinetics_local_copy = gyrokinetics_local;

    gyrokinetics_local_copy.linear.wavevector{1}.eigenmode{1}.fields.phi_potential_perturbed_norm = complex(ones(2,2),ones(2,2));
    fprintf('Original value:\n');
    disp(gyrokinetics_local.linear.wavevector{1}.eigenmode{1}.fields.phi_potential_perturbed_norm);
    fprintf('Copied   value:\n');
    disp(gyrokinetics_local_copy.linear.wavevector{1}.eigenmode{1}.fields.phi_potential_perturbed_norm);

    % IDSs can be printed using fprintf() and disp() methods.
    fprintf('gyrokinetics_local.ids_properties.homogeneous_time:   %i\n', gyrokinetics_local.ids_properties.homogeneous_time);
    fprintf('gyrokinetics_local.non_linear.radial_wavevector_norm: %i %i %i\n', gyrokinetics_local.non_linear.radial_wavevector_norm);
    fprintf('gyrokinetics_local.non_linear.time_norm:              %i %i %i\n', gyrokinetics_local.non_linear.time_norm);
    fprintf('gyrokinetics_local/non_linear/fields_zonal_2d/phi_potential_perturbed_norm:\n');
    disp(gyrokinetics_local.non_linear.fields_zonal_2d.phi_potential_perturbed_norm);
    fprintf('gyrokinetics_local.linear.wavevector{1}.eigenmode{1}.fields.phi_potential_perturbed_norm:\n');
    disp(gyrokinetics_local.linear.wavevector{1}.eigenmode{1}.fields.phi_potential_perturbed_norm);

    clear gyrokinetics_local;
    clear gyrokinetics_local_copy;
