% partial_get_tests.m

uri = 'imas:hdf5?path=./test_db_test_core_profiles';
save_data(uri)
execute(uri);

% Utility function to check path values in a range
function assertions = checkPathValuesInRange(ids, start_idx, end_idx, path, expected_value, ids_name, is_time)
    assertions = struct('passed', {}, 'description', {});
    epsilon = eps; % MATLAB equivalent of std::numeric_limits<double>::epsilon()
    if strcmp(ids_name, 'core_profiles')
        for i = start_idx:end_idx
            matlab_idx = i + 1;
            if matlab_idx > length(ids.profiles_1d)
                assertions(end+1) = create_assertion(false, sprintf('Index %d out of bounds for %s', i, path));
                continue;
            end
            passed = false;
            desc = '';
            if strcmp(path, 'profiles_1d.time')
                actual = ids.profiles_1d{matlab_idx}.time;
                if is_time
                    expected = i + 1.0;
                else
                    expected = expected_value;
                end
                passed = abs(actual - expected) < epsilon;
                desc = sprintf('%s(%d) == %g', path, i, expected);
            else
                assertions(end+1) = create_assertion(false, sprintf('Unsupported path: %s', path));
                continue;
            end
            assertions(end+1) = create_assertion(passed, desc);
        end
    else
        assertions(end+1) = create_assertion(false, sprintf('Unsupported IDS type: %s', ids_name));
    end
end

% Structure to hold assertion results
function assertion = create_assertion(passed, description)
    assertion = struct('passed', passed, 'description', description);
end

% Utility function to check array sizes in a range
function assertions = checkArraySizeInRange(ids, start_idx, end_idx, array_path, expected_size, ids_name)
    assertions = struct('passed', {}, 'description', {});
    if strcmp(ids_name, 'core_profiles')
        for i = start_idx:end_idx
            matlab_idx = i + 1;
            if matlab_idx > length(ids.profiles_1d)
                assertions(end+1) = create_assertion(false, sprintf('Index %d out of bounds for %s', i, array_path));
                continue;
            end
            actual_size = 0;
            if strcmp(array_path, 'profiles_1d.ion')
                actual_size = length(ids.profiles_1d{matlab_idx}.ion);
            else
                assertions(end+1) = create_assertion(false, sprintf('Unsupported array path: %s', array_path));
                continue;
            end
            passed = (actual_size == expected_size);
            desc = sprintf('%s(%d).size() == %d', array_path, i, expected_size);
            assertions(end+1) = create_assertion(passed, desc);
        end
    else
        assertions(end+1) = create_assertion(false, sprintf('Unsupported IDS type: %s', ids_name));
    end
end

% Utility function to check if a value is uninitialized (value == -9e40)
function assertions = checkUninitializedInRange(ids, start_idx, end_idx, path, ids_name)
    assertions = struct('passed', {}, 'description', {});
    epsilon = eps;
    if strcmp(ids_name, 'core_profiles')
        for i = start_idx:end_idx
            matlab_idx = i + 1;
            if matlab_idx > length(ids.profiles_1d)
                assertions(end+1) = create_assertion(false, sprintf('Index %d out of bounds for %s', i, path));
                continue;
            end
            passed = false;
            desc = '';
            if strcmp(path, 'profiles_1d.time')
                actual = ids.profiles_1d{matlab_idx}.time;
                passed = abs(actual + 9e40) < epsilon;
                desc = sprintf('%s(%d) is uninitialized', path, i);
            else
                assertions(end+1) = create_assertion(false, sprintf('Unsupported path: %s', path));
                continue;
            end
            assertions(end+1) = create_assertion(passed, desc);
        end
    else
        assertions(end+1) = create_assertion(false, sprintf('Unsupported IDS type: %s', ids_name));
    end
end

% Utility function to add time assertions
function assertions = addTimeAssertions(assertions, ids, profile_idx, expected_time, is_initialized, ids_name)
    epsilon = eps;
    if strcmp(ids_name, 'core_profiles')
        matlab_idx = profile_idx + 1;
        if matlab_idx > length(ids.profiles_1d)
            assertions(end+1) = create_assertion(false, 'Failed to access core_profiles for time assertions');
            return;
        end
        if is_initialized
            passed = abs(ids.profiles_1d{matlab_idx}.time - expected_time) < epsilon;
            desc = sprintf('profiles_1d(%d).time == %g', profile_idx, expected_time);
        else
            passed = abs(ids.profiles_1d{matlab_idx}.time + 9e40) < epsilon;
            desc = sprintf('profiles_1d(%d).time is uninitialized', profile_idx);
        end
        assertions(end+1) = create_assertion(passed, desc);
    else
        assertions(end+1) = create_assertion(false, sprintf('Unsupported IDS type: %s', ids_name));
    end
end

% Utility function to add specific assertions
function assertions = addSpecificAssertions(assertions, ids, profile_idx, ion_idx, expected_size, ids_name, z_min_checks)
    if nargin < 7
        z_min_checks = {};
    end
    if strcmp(ids_name, 'core_profiles')
        matlab_profile_idx = profile_idx + 1;
        matlab_ion_idx = ion_idx + 1;
        if matlab_profile_idx > length(ids.profiles_1d)
            assertions(end+1) = create_assertion(false, 'Failed to access core_profiles for state assertions');
            return;
        end
        passed = length(ids.profiles_1d{matlab_profile_idx}.ion{matlab_ion_idx}.state) == expected_size;
        desc = sprintf('profiles_1d(%d).ion(%d).state.size() == %d', profile_idx, ion_idx, expected_size);
        assertions(end+1) = create_assertion(passed, desc);
        for z_check = z_min_checks
            state_idx = z_check.state_idx;
            z_min = z_check.z_min;
            matlab_state_idx = state_idx + 1;
            passed = ids.profiles_1d{matlab_profile_idx}.ion{matlab_ion_idx}.state{matlab_state_idx}.z_min == z_min;
            desc = sprintf('profiles_1d(%d).ion(%d).state(%d).z_min == %d', profile_idx, ion_idx, state_idx, z_min);
            assertions(end+1) = create_assertion(passed, desc);
        end
    else
        assertions(end+1) = create_assertion(false, sprintf('Unsupported IDS type: %s', ids_name));
    end
end

% Utility function to run a test and collect assertions
function all_passed = runTest(test_number, request, exclude, ids, assertions)
    all_passed = true;
    for i = 1:length(assertions)
        if ~assertions(i).passed
            all_passed = false;
            fprintf('Assertion #%d failed for test %d (request=%s): %s\n', i, test_number, request, assertions(i).description);
        end
    end
    fprintf('Partial plugin test %d completed with %d assertions.\n', test_number, length(assertions));
end

% Main execution function
function execute(uri)

    mode = 40;
    idx = imas_open(uri, mode);

    all_tests_passed = true;
    test_index = 0;

    % TEST 1: Check ids_properties
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'ids_properties', '');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) ~= 0, 'ids_properties.comment.length() != 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 0, 'profiles_1d.size() == 0');
    all_tests_passed = all_tests_passed && runTest(test_index, 'ids_properties', '', ids, assertions);

    % TEST 2: Check profiles_1d(:)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(:)', '');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    time_checks = checkPathValuesInRange(ids, 0, 9, 'profiles_1d.time', 0, 'core_profiles', true);
    assertions = [assertions, time_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(:)', '', ids, assertions);

    % TEST 3: Check profiles_1d(1:5:1)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(1:5:1)', '');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    time_checks = checkPathValuesInRange(ids, 0, 4, 'profiles_1d.time', 0, 'core_profiles', true);
    uninit_checks = checkUninitializedInRange(ids, 5, 9, 'profiles_1d.time', 'core_profiles');
    assertions = [assertions, time_checks, uninit_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(1:5:1)', '', ids, assertions);

    % TEST 4: Check profiles_1d(1:5:1) with exclude profiles_1d(2)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(1:5:1)', 'profiles_1d(2)');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    time_checks = struct('idx', {0, 1, 2, 3, 4}, 'time', {1.0, 0.0, 3.0, 4.0, 5.0}, 'initialized', {true, false, true, true, true});
    for i = 1:length(time_checks)
        assertions = addTimeAssertions(assertions, ids, time_checks(i).idx, time_checks(i).time, time_checks(i).initialized, 'core_profiles');
    end
    uninit_checks = checkUninitializedInRange(ids, 5, 9, 'profiles_1d.time', 'core_profiles');
    assertions = [assertions, uninit_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(1:5:1)', 'profiles_1d(2)', ids, assertions);

    % TEST 5: Check profiles_1d(:) with exclude profiles_1d(2)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(:)', 'profiles_1d(2)');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    assertions = addTimeAssertions(assertions, ids, 0, 1.0, true, 'core_profiles');
    assertions = addTimeAssertions(assertions, ids, 1, 0.0, false, 'core_profiles');
    time_checks = checkPathValuesInRange(ids, 2, 9, 'profiles_1d.time', 0, 'core_profiles', true);
    assertions = [assertions, time_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(:)', 'profiles_1d(2)', ids, assertions);

    % TEST 6: Check ids_properties;profiles_1d(1:5:2) with exclude profiles_1d(2)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'ids_properties;profiles_1d(1:5:2)', 'profiles_1d(2)');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) ~= 0, 'ids_properties.comment.length() != 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    time_checks = struct('idx', {0, 1, 2, 3, 4}, 'time', {1.0, 0.0, 3.0, 0.0, 5.0}, 'initialized', {true, false, true, false, true});
    for i = 1:length(time_checks)
        assertions = addTimeAssertions(assertions, ids, time_checks(i).idx, time_checks(i).time, time_checks(i).initialized, 'core_profiles');
    end
    uninit_checks = checkUninitializedInRange(ids, 5, 9, 'profiles_1d.time', 'core_profiles');
    assertions = [assertions, uninit_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'ids_properties;profiles_1d(1:5:2)', 'profiles_1d(2)', ids, assertions);

    % TEST 7: Check profiles_1d(1:5:2)/ion(3)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(1:5:2)/ion(3)', '');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    ion_sizes = checkArraySizeInRange(ids, 0, 4, 'profiles_1d.ion', 0, 'core_profiles');
    ion_sizes(1).passed = length(ids.profiles_1d{1}.ion) == 1;
    ion_sizes(1).description = 'profiles_1d(0).ion.size() == 1';
    ion_sizes(3).passed = length(ids.profiles_1d{3}.ion) == 3;
    ion_sizes(3).description = 'profiles_1d(2).ion.size() == 3';
    ion_sizes(5).passed = length(ids.profiles_1d{5}.ion) == 5;
    ion_sizes(5).description = 'profiles_1d(4).ion.size() == 5';
    assertions = [assertions, ion_sizes];
    state_checks = struct('profile_idx', {0, 2, 2, 2, 4, 4, 4, 4, 4}, ...
                          'ion_idx', {0, 0, 1, 2, 0, 1, 2, 3, 4}, ...
                          'expected_size', {0, 0, 0, 10, 0, 0, 10, 0, 0});
    z_min_checks = {struct('profile_idx', 2, 'ion_idx', 2, 'checks', ...
                           {struct('state_idx', 5, 'z_min', 5), struct('state_idx', 6, 'z_min', 6)}), ...
                    struct('profile_idx', 4, 'ion_idx', 2, 'checks', ...
                           {struct('state_idx', 5, 'z_min', 5), struct('state_idx', 6, 'z_min', 6)})};
    for i = 1:length(state_checks)
        profile_idx = state_checks(i).profile_idx;
        ion_idx = state_checks(i).ion_idx;
        if ~isscalar(profile_idx) || ~isscalar(ion_idx)
            error('Non-scalar profile_idx or ion_idx at state_checks(%d): profile_idx=%s, ion_idx=%s', ...
                  i, mat2str(profile_idx), mat2str(ion_idx));
        end
        z_checks = {};
        for j = 1:length(z_min_checks)
            z_profile = z_min_checks{j}.profile_idx;
            z_ion = z_min_checks{j}.ion_idx;
            if ~isscalar(z_profile) || ~isscalar(z_ion)
                error('Non-scalar z_min_checks{%d}.profile_idx or ion_idx: profile_idx=%s, ion_idx=%s', ...
                      j, mat2str(z_profile), mat2str(z_ion));
            end
            if z_profile == profile_idx && z_ion == ion_idx
                z_checks = z_min_checks{j}.checks;
                break;
            end
        end
        assertions = addSpecificAssertions(assertions, ids, profile_idx, ion_idx, state_checks(i).expected_size, 'core_profiles', z_checks);
    end
    uninit_checks = checkUninitializedInRange(ids, 0, 9, 'profiles_1d.time', 'core_profiles');
    assertions = [assertions, uninit_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(1:5:2)/ion(3)', '', ids, assertions);

    % TEST 8: Check profiles_1d(1:5:2)/ion(3);profiles_1d(1:5:2)/ion(1)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(1:5:2)/ion(3);profiles_1d(1:5:2)/ion(1)', '');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    ion_sizes = checkArraySizeInRange(ids, 0, 4, 'profiles_1d.ion', 0, 'core_profiles');
    ion_sizes(1).passed = length(ids.profiles_1d{1}.ion) == 1;
    ion_sizes(1).description = 'profiles_1d(0).ion.size() == 1';
    ion_sizes(3).passed = length(ids.profiles_1d{3}.ion) == 3;
    ion_sizes(3).description = 'profiles_1d(2).ion.size() == 3';
    ion_sizes(5).passed = length(ids.profiles_1d{5}.ion) == 5;
    ion_sizes(5).description = 'profiles_1d(4).ion.size() == 5';
    assertions = [assertions, ion_sizes];
    state_checks = struct('profile_idx', {0, 2, 2, 2, 4, 4, 4, 4, 4}, ...
                          'ion_idx', {0, 0, 1, 2, 0, 1, 2, 3, 4}, ...
                          'expected_size', {10, 10, 0, 10, 10, 0, 10, 0, 0});
    z_min_checks = {struct('profile_idx', 2, 'ion_idx', 2, 'checks', ...
                           {struct('state_idx', 5, 'z_min', 5), struct('state_idx', 6, 'z_min', 6)}), ...
                    struct('profile_idx', 4, 'ion_idx', 2, 'checks', ...
                           {struct('state_idx', 5, 'z_min', 5), struct('state_idx', 6, 'z_min', 6)})};
    for i = 1:length(state_checks)
        profile_idx = state_checks(i).profile_idx;
        ion_idx = state_checks(i).ion_idx;
        if ~isscalar(profile_idx) || ~isscalar(ion_idx)
            error('Non-scalar profile_idx or ion_idx at state_checks(%d): profile_idx=%s, ion_idx=%s', ...
                  i, mat2str(profile_idx), mat2str(ion_idx));
        end
        z_checks = {};
        for j = 1:length(z_min_checks)
            z_profile = z_min_checks{j}.profile_idx;
            z_ion = z_min_checks{j}.ion_idx;
            if ~isscalar(z_profile) || ~isscalar(z_ion)
                error('Non-scalar z_min_checks{%d}.profile_idx or ion_idx: profile_idx=%s, ion_idx=%s', ...
                      j, mat2str(z_profile), mat2str(z_ion));
            end
            if z_profile == profile_idx && z_ion == ion_idx
                z_checks = z_min_checks{j}.checks;
                break;
            end
        end
        assertions = addSpecificAssertions(assertions, ids, profile_idx, ion_idx, state_checks(i).expected_size, 'core_profiles', z_checks);
    end
    uninit_checks = checkUninitializedInRange(ids, 0, 9, 'profiles_1d.time', 'core_profiles');
    assertions = [assertions, uninit_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(1:5:2)/ion(3);profiles_1d(1:5:2)/ion(1)', '', ids, assertions);

    % TEST 9: Check profiles_1d(1:5:2)/ion(3);profiles_1d(1:5:2)/time
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(1:5:2)/ion(3);profiles_1d(1:5:2)/time', '');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    ion_sizes = checkArraySizeInRange(ids, 0, 4, 'profiles_1d.ion', 0, 'core_profiles');
    ion_sizes(1).passed = length(ids.profiles_1d{1}.ion) == 1;
    ion_sizes(1).description = 'profiles_1d(0).ion.size() == 1';
    ion_sizes(3).passed = length(ids.profiles_1d{3}.ion) == 3;
    ion_sizes(3).description = 'profiles_1d(2).ion.size() == 3';
    ion_sizes(5).passed = length(ids.profiles_1d{5}.ion) == 5;
    ion_sizes(5).description = 'profiles_1d(4).ion.size() == 5';
    assertions = [assertions, ion_sizes];
    state_checks = struct('profile_idx', {0, 2, 2, 2, 4, 4, 4, 4, 4}, ...
                          'ion_idx', {0, 0, 1, 2, 0, 1, 2, 3, 4}, ...
                          'expected_size', {0, 0, 0, 10, 0, 0, 10, 0, 0});
    z_min_checks = {struct('profile_idx', 2, 'ion_idx', 2, 'checks', ...
                           {struct('state_idx', 5, 'z_min', 5), struct('state_idx', 6, 'z_min', 6)}), ...
                    struct('profile_idx', 4, 'ion_idx', 2, 'checks', ...
                           {struct('state_idx', 5, 'z_min', 5), struct('state_idx', 6, 'z_min', 6)})};
    for i = 1:length(state_checks)
        profile_idx = state_checks(i).profile_idx;
        ion_idx = state_checks(i).ion_idx;
        if ~isscalar(profile_idx) || ~isscalar(ion_idx)
            error('Non-scalar profile_idx or ion_idx at state_checks(%d): profile_idx=%s, ion_idx=%s', ...
                  i, mat2str(profile_idx), mat2str(ion_idx));
        end
        z_checks = {};
        for j = 1:length(z_min_checks)
            z_profile = z_min_checks{j}.profile_idx;
            z_ion = z_min_checks{j}.ion_idx;
            if ~isscalar(z_profile) || ~isscalar(z_ion)
                error('Non-scalar z_min_checks{%d}.profile_idx or ion_idx: profile_idx=%s, ion_idx=%s', ...
                      j, mat2str(z_profile), mat2str(z_ion));
            end
            if z_profile == profile_idx && z_ion == ion_idx
                z_checks = z_min_checks{j}.checks;
                break;
            end
        end
        assertions = addSpecificAssertions(assertions, ids, profile_idx, ion_idx, state_checks(i).expected_size, 'core_profiles', z_checks);
    end
    time_checks = struct('idx', {0, 2, 4, 1, 3, 5, 6}, 'time', {1.0, 3.0, 5.0, 0.0, 0.0, 0.0, 0.0}, 'initialized', {true, true, true, false, false, false, false});
    for i = 1:length(time_checks)
        assertions = addTimeAssertions(assertions, ids, time_checks(i).idx, time_checks(i).time, time_checks(i).initialized, 'core_profiles');
    end
    uninit_checks = checkUninitializedInRange(ids, 7, 9, 'profiles_1d.time', 'core_profiles');
    assertions = [assertions, uninit_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(1:5:2)/ion(3);profiles_1d(1:5:2)/time', '', ids, assertions);

    % TEST 10: Check ids_properties;profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'ids_properties;profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time', '');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) ~= 0, 'ids_properties.comment.length() != 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    ion_sizes = struct('profile_idx', {0, 1, 2, 3, 4}, 'ion_idx', {0, 0, 0, 0, 0}, 'expected_size', {1, 2, 3, 4, 5});
    for i = 1:length(ion_sizes)
        matlab_idx = ion_sizes(i).profile_idx + 1;
        assertions(end+1) = create_assertion(length(ids.profiles_1d{matlab_idx}.ion) == ion_sizes(i).expected_size, ...
            sprintf('profiles_1d(%d).ion.size() == %d', ion_sizes(i).profile_idx, ion_sizes(i).expected_size));
    end
    ion_sizes_rest = checkArraySizeInRange(ids, 5, 9, 'profiles_1d.ion', 0, 'core_profiles');
    assertions = [assertions, ion_sizes_rest];
    time_checks = checkPathValuesInRange(ids, 0, 9, 'profiles_1d.time', 0, 'core_profiles', true);
    assertions = [assertions, time_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'ids_properties;profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time', '', ids, assertions);

    % TEST 11: Check ids_properties;profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time with exclude
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'ids_properties;profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time', ...
        'profiles_1d(2:3:1);profiles_1d(5)/ion(1)');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) ~= 0, 'ids_properties.comment.length() != 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    ion_sizes = struct('profile_idx', {0, 1, 2, 3, 4}, 'ion_idx', {0, 0, 0, 0, 0}, 'expected_size', {1, 0, 0, 4, 5});
    for i = 1:length(ion_sizes)
        matlab_idx = ion_sizes(i).profile_idx + 1;
        assertions(end+1) = create_assertion(length(ids.profiles_1d{matlab_idx}.ion) == ion_sizes(i).expected_size, ...
            sprintf('profiles_1d(%d).ion.size() == %d', ion_sizes(i).profile_idx, ion_sizes(i).expected_size));
    end
    time_checks = struct('idx', {0, 3, 4, 5, 6, 1, 2}, ...
                        'time', {1.0, 4.0, 5.0, 6.0, 7.0, 0.0, 0.0}, ...
                        'initialized', {true, true, true, true, true, false, false});
    for i = 1:length(time_checks)
        assertions = addTimeAssertions(assertions, ids, time_checks(i).idx, time_checks(i).time, time_checks(i).initialized, 'core_profiles');
    end
    assertions(end+1) = create_assertion(ids.profiles_1d{4}.ion{1}.state{6}.z_min == 5, ...
        'profiles_1d(3).ion(0).state(5).z_min == 5');
    assertions(end+1) = create_assertion(ids.profiles_1d{4}.ion{1}.state{7}.z_min == 6, ...
        'profiles_1d(3).ion(0).state(6).z_min == 6');
    assertions(end+1) = create_assertion(length(ids.profiles_1d{5}.ion{1}.state) == 0, ...
        'profiles_1d(4).ion(0).state.size() == 0');
    all_tests_passed = all_tests_passed && runTest(test_index, ...
        'ids_properties;profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time', ...
        'profiles_1d(2:3:1);profiles_1d(5)/ion(1)', ids, assertions);

    % TEST 12: Check empty request
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, '', '');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) ~= 0, 'ids_properties.comment.length() != 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    time_checks = checkPathValuesInRange(ids, 0, 9, 'profiles_1d.time', 0, 'core_profiles', true);
    assertions = [assertions, time_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, '', '', ids, assertions);

    % TEST 13: Check profiles_1d(1:5:2)/ion(:);profiles_1d(1:5:2)/time
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(1:5:2)/ion(:);profiles_1d(1:5:2)/time', '');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    ion_sizes = checkArraySizeInRange(ids, 0, 4, 'profiles_1d.ion', 0, 'core_profiles');
    ion_sizes(1).passed = length(ids.profiles_1d{1}.ion) == 1;
    ion_sizes(1).description = 'profiles_1d(0).ion.size() == 1';
    ion_sizes(3).passed = length(ids.profiles_1d{3}.ion) == 3;
    ion_sizes(3).description = 'profiles_1d(2).ion.size() == 3';
    ion_sizes(5).passed = length(ids.profiles_1d{5}.ion) == 5;
    ion_sizes(5).description = 'profiles_1d(4).ion.size() == 5';
    assertions = [assertions, ion_sizes];
    state_checks = struct('profile_idx', {0, 2, 2, 2, 4, 4, 4, 4, 4}, ...
                        'ion_idx', {0, 0, 1, 2, 0, 1, 2, 3, 4}, ...
                        'expected_size', {10, 10, 10, 10, 10, 10, 10, 10, 10});
    z_min_checks = {struct('profile_idx', 4, 'ion_idx', 2, 'checks', ...
                        {struct('state_idx', 5, 'z_min', 5), struct('state_idx', 6, 'z_min', 6)}), ...
                    struct('profile_idx', 4, 'ion_idx', 3, 'checks', ...
                        {struct('state_idx', 5, 'z_min', 5), struct('state_idx', 6, 'z_min', 6)})};
    for i = 1:length(state_checks)
        profile_idx = state_checks(i).profile_idx;
        ion_idx = state_checks(i).ion_idx;
        if iscell(profile_idx)
            profile_idx = profile_idx{1};
        end
        if iscell(ion_idx)
            ion_idx = ion_idx{1};
        end
        if ~isnumeric(profile_idx) || ~isscalar(profile_idx) || ~isnumeric(ion_idx) || ~isscalar(ion_idx)
            error('Invalid profile_idx or ion_idx at state_checks(%d): profile_idx=%s, ion_idx=%s', ...
                i, mat2str(profile_idx), mat2str(ion_idx));
        end
        z_checks = {};
        for j = 1:length(z_min_checks)
            z_profile = z_min_checks{j}.profile_idx;
            z_ion = z_min_checks{j}.ion_idx;
            if iscell(z_profile)
                z_profile = z_profile{1};
            end
            if iscell(z_ion)
                z_ion = z_ion{1};
            end
            if ~isnumeric(z_profile) || ~isscalar(z_profile) || ~isnumeric(z_ion) || ~isscalar(z_ion)
                error('Invalid z_min_checks{%d}.profile_idx or ion_idx: profile_idx=%s, ion_idx=%s', ...
                    j, mat2str(z_profile), mat2str(z_ion));
            end
            if z_profile == profile_idx && z_ion == ion_idx
                z_checks = z_min_checks{j}.checks;
                break;
            end
        end
        assertions = addSpecificAssertions(assertions, ids, profile_idx, ion_idx, state_checks(i).expected_size, 'core_profiles', z_checks);
    end
    time_checks = struct('idx', {0, 2, 4, 3, 5, 6}, ...
                        'time', {1.0, 3.0, 5.0, 0.0, 0.0, 0.0}, ...
                        'initialized', {true, true, true, false, false, false});
    for i = 1:length(time_checks)
        assertions = addTimeAssertions(assertions, ids, time_checks(i).idx, time_checks(i).time, time_checks(i).initialized, 'core_profiles');
    end
    uninit_checks = checkUninitializedInRange(ids, 7, 9, 'profiles_1d.time', 'core_profiles');
    assertions = [assertions, uninit_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(1:5:2)/ion(:);profiles_1d(1:5:2)/time', '', ids, assertions);

    % TEST 14: Check profiles_1d(:) with exclude profiles_1d(:)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(:)', 'profiles_1d(:)');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 0, 'profiles_1d.size() == 0');
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(:)', 'profiles_1d(:)', ids, assertions);

    % TEST 15: Check profiles_1d(1:5)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(1:5)', '');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    time_checks = checkPathValuesInRange(ids, 0, 4, 'profiles_1d.time', 0, 'core_profiles', true);
    uninit_checks = checkUninitializedInRange(ids, 5, 9, 'profiles_1d.time', 'core_profiles');
    assertions = [assertions, time_checks, uninit_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(1:5)', '', ids, assertions);

    % TEST 16: Check profiles_1d(1:5) with exclude profiles_1d(1:2)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(1:5)', 'profiles_1d(1:2)');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    time_checks = checkPathValuesInRange(ids, 2, 4, 'profiles_1d.time', 0, 'core_profiles', true);
    uninit_checks = checkUninitializedInRange(ids, 0, 1, 'profiles_1d.time', 'core_profiles');
    uninit_checks_5_9 = checkUninitializedInRange(ids, 5, 9, 'profiles_1d.time', 'core_profiles');
    uninit_checks = [uninit_checks, uninit_checks_5_9];
    assertions = [assertions, time_checks, uninit_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(1:5)', 'profiles_1d(1:2)', ids, assertions);

    % TEST 17: Check profiles_1d(::2)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(::2)', '');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    for i = 0:4
        assertions = addTimeAssertions(assertions, ids, 2*i, (2*i) + 1.0, true, 'core_profiles');
        assertions = addTimeAssertions(assertions, ids, 2*i+1, 0.0, false, 'core_profiles');
    end
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(::2)', '', ids, assertions);

    % TEST 18: Check profiles_1d(:3)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(:3)', '');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    time_checks = checkPathValuesInRange(ids, 0, 2, 'profiles_1d.time', 0, 'core_profiles', true);
    uninit_checks = checkUninitializedInRange(ids, 3, 9, 'profiles_1d.time', 'core_profiles');
    assertions = [assertions, time_checks, uninit_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(:3)', '', ids, assertions);

    % TEST 19: Check profiles_1d(4:)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(4:)', '');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    uninit_checks = checkUninitializedInRange(ids, 0, 2, 'profiles_1d.time', 'core_profiles');
    time_checks = checkPathValuesInRange(ids, 3, 9, 'profiles_1d.time', 0, 'core_profiles', true);
    assertions = [assertions, uninit_checks, time_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(4:)', '', ids, assertions);

    % TEST 20: Check profiles_1d(1:5) with exclude profiles_1d(3)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(1:5)', 'profiles_1d(3)');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    time_checks = struct('idx', {0, 1, 2, 3, 4}, ...
                        'time', {1.0, 2.0, 0.0, 4.0, 5.0}, ...
                        'initialized', {true, true, false, true, true});
    for i = 1:length(time_checks)
        assertions = addTimeAssertions(assertions, ids, time_checks(i).idx, time_checks(i).time, time_checks(i).initialized, 'core_profiles');
    end
    uninit_checks = checkUninitializedInRange(ids, 5, 9, 'profiles_1d.time', 'core_profiles');
    assertions = [assertions, uninit_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(1:5)', 'profiles_1d(3)', ids, assertions);

    % TEST 21: Check profiles_1d(:) with exclude profiles_1d(1:2)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(:)', 'profiles_1d(1:2)');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    time_checks = struct('idx', {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}, ...
                        'time', {0.0, 0.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0}, ...
                        'initialized', {false, false, true, true, true, true, true, true, true, true});
    for i = 1:length(time_checks)
        assertions = addTimeAssertions(assertions, ids, time_checks(i).idx, time_checks(i).time, time_checks(i).initialized, 'core_profiles');
    end
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(:)', 'profiles_1d(1:2)', ids, assertions);

    % TEST 22: Check profiles_1d(1:5:2)/ion(3) with exclude profiles_1d(5)/ion(3)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(1:5:2)/ion(3)', 'profiles_1d(5)/ion(3)');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    ion_sizes = struct('profile_idx', {0, 1, 2, 3, 4}, ...
                    'ion_idx', {0, 0, 0, 0, 0}, ...
                    'expected_size', {1, 0, 3, 0, 0});
    for i = 1:length(ion_sizes)
        matlab_idx = ion_sizes(i).profile_idx + 1;
        assertions(end+1) = create_assertion(length(ids.profiles_1d{matlab_idx}.ion) == ion_sizes(i).expected_size, ...
            sprintf('profiles_1d(%d).ion.size() == %d', ion_sizes(i).profile_idx, ion_sizes(i).expected_size));
    end
    assertions(end+1) = create_assertion(length(ids.profiles_1d{5}.ion) == 0, 'profiles_1d(4).ion(0).size() == 0');
    state_checks = struct('profile_idx', {0, 2, 2, 2}, ...
                        'ion_idx', {0, 0, 1, 2}, ...
                        'expected_size', {0, 0, 0, 10});
    z_min_checks = {struct('profile_idx', 2, 'ion_idx', 2, 'checks', ...
                        {struct('state_idx', 5, 'z_min', 5), struct('state_idx', 6, 'z_min', 6)})};
    for i = 1:length(state_checks)
        profile_idx = state_checks(i).profile_idx;
        ion_idx = state_checks(i).ion_idx;
        if iscell(profile_idx), profile_idx = profile_idx{1}; end
        if iscell(ion_idx), ion_idx = ion_idx{1}; end
        if ~isnumeric(profile_idx) || ~isscalar(profile_idx) || ~isnumeric(ion_idx) || ~isscalar(ion_idx)
            error('Invalid profile_idx or ion_idx at state_checks(%d): profile_idx=%s, ion_idx=%s', ...
                i, mat2str(profile_idx), mat2str(ion_idx));
        end
        z_checks = {};
        for j = 1:length(z_min_checks)
            z_profile = z_min_checks{j}.profile_idx;
            z_ion = z_min_checks{j}.ion_idx;
            if iscell(z_profile), z_profile = z_profile{1}; end
            if iscell(z_ion), z_ion = z_ion{1}; end
            if ~isnumeric(z_profile) || ~isscalar(z_profile) || ~isnumeric(z_ion) || ~isscalar(z_ion)
                error('Invalid z_min_checks{%d}.profile_idx or ion_idx: profile_idx=%s, ion_idx=%s', ...
                    j, mat2str(z_profile), mat2str(z_ion));
            end
            if z_profile == profile_idx && z_ion == ion_idx
                z_checks = z_min_checks{j}.checks;
                break;
            end
        end
        assertions = addSpecificAssertions(assertions, ids, profile_idx, ion_idx, state_checks(i).expected_size, 'core_profiles', z_checks);
    end
    uninit_checks = checkUninitializedInRange(ids, 0, 9, 'profiles_1d.time', 'core_profiles');
    assertions = [assertions, uninit_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(1:5:2)/ion(3)', 'profiles_1d(5)/ion(3)', ids, assertions);

    % TEST 23: Check profiles_1d(1:5:1)/ion(1:4:2) with exclude profiles_1d(3)/ion(1)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(1:5:1)/ion(1:4:2)', 'profiles_1d(3)/ion(1)');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    ion_sizes = struct('profile_idx', {0, 1, 2, 3, 4}, ...
                    'ion_idx', {0, 0, 0, 0, 0}, ...
                    'expected_size', {1, 2, 3, 4, 5});
    for i = 1:length(ion_sizes)
        matlab_idx = ion_sizes(i).profile_idx + 1;
        assertions(end+1) = create_assertion(length(ids.profiles_1d{matlab_idx}.ion) == ion_sizes(i).expected_size, ...
            sprintf('profiles_1d(%d).ion.size() == %d', ion_sizes(i).profile_idx, ion_sizes(i).expected_size));
    end
    state_checks = struct('profile_idx', {2, 2, 4, 4, 4, 4, 4}, ...
                        'ion_idx', {0, 1, 0, 1, 2, 3, 4}, ...
                        'expected_size', {0, 0, 10, 0, 10, 0, 0});
    for i = 1:length(state_checks)
        profile_idx = state_checks(i).profile_idx;
        ion_idx = state_checks(i).ion_idx;
        if iscell(profile_idx), profile_idx = profile_idx{1}; end
        if iscell(ion_idx), ion_idx = ion_idx{1}; end
        if ~isnumeric(profile_idx) || ~isscalar(profile_idx) || ~isnumeric(ion_idx) || ~isscalar(ion_idx)
            error('Invalid profile_idx or ion_idx at state_checks(%d): profile_idx=%s, ion_idx=%s', ...
                i, mat2str(profile_idx), mat2str(ion_idx));
        end
        assertions = addSpecificAssertions(assertions, ids, profile_idx, ion_idx, state_checks(i).expected_size, 'core_profiles', {});
    end
    uninit_checks = checkUninitializedInRange(ids, 0, 9, 'profiles_1d.time', 'core_profiles');
    assertions = [assertions, uninit_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(1:5:1)/ion(1:4:2)', 'profiles_1d(3)/ion(1)', ids, assertions);

    % TEST 24: Check profiles_1d(:)/time with exclude profiles_1d(3:5)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(:)/time', 'profiles_1d(3:5)');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    time_checks = struct('idx', {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}, ...
                        'time', {1.0, 2.0, 0.0, 0.0, 0.0, 6.0, 7.0, 8.0, 9.0, 10.0}, ...
                        'initialized', {true, true, false, false, false, true, true, true, true, true});
    for i = 1:length(time_checks)
        assertions = addTimeAssertions(assertions, ids, time_checks(i).idx, time_checks(i).time, time_checks(i).initialized, 'core_profiles');
    end
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(:)/time', 'profiles_1d(3:5)', ids, assertions);

    % TEST 25: Check ids_properties;profiles_1d(1:5:2) with exclude profiles_1d(1:3:2)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'ids_properties;profiles_1d(1:5:2)', 'profiles_1d(1:3:2)');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) ~= 0, 'ids_properties.comment.length() != 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    time_checks = struct('idx', {0, 1, 2, 3, 4}, ...
                        'time', {0.0, 0.0, 0.0, 0.0, 5.0}, ...
                        'initialized', {false, false, false, false, true});
    for i = 1:length(time_checks)
        assertions = addTimeAssertions(assertions, ids, time_checks(i).idx, time_checks(i).time, time_checks(i).initialized, 'core_profiles');
    end
    uninit_checks = checkUninitializedInRange(ids, 5, 9, 'profiles_1d.time', 'core_profiles');
    assertions = [assertions, uninit_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'ids_properties;profiles_1d(1:5:2)', 'profiles_1d(1:3:2)', ids, assertions);

    % TEST 26: Check profiles_1d(1:5:2)/ion(:) with exclude profiles_1d(3)/ion(2)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(1:5:2)/ion(:)', 'profiles_1d(3)/ion(2)');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    ion_sizes = struct('profile_idx', {0, 1, 2, 3, 4}, ...
                    'ion_idx', {0, 0, 0, 0, 0}, ...
                    'expected_size', {1, 0, 3, 0, 5});
    for i = 1:length(ion_sizes)
        matlab_idx = ion_sizes(i).profile_idx + 1;
        assertions(end+1) = create_assertion(length(ids.profiles_1d{matlab_idx}.ion) == ion_sizes(i).expected_size, ...
            sprintf('profiles_1d(%d).ion.size() == %d', ion_sizes(i).profile_idx, ion_sizes(i).expected_size));
    end
    state_checks = struct('profile_idx', {0, 2, 2, 4, 4, 4, 4, 4}, ...
                        'ion_idx', {0, 0, 1, 0, 1, 2, 3, 4}, ...
                        'expected_size', {10, 10, 0, 10, 10, 10, 10, 10});
    z_min_checks = {struct('profile_idx', 4, 'ion_idx', 2, 'checks', ...
                        {struct('state_idx', 5, 'z_min', 5), struct('state_idx', 6, 'z_min', 6)}), ...
                    struct('profile_idx', 4, 'ion_idx', 3, 'checks', ...
                        {struct('state_idx', 5, 'z_min', 5), struct('state_idx', 6, 'z_min', 6)})};
    for i = 1:length(state_checks)
        profile_idx = state_checks(i).profile_idx;
        ion_idx = state_checks(i).ion_idx;
        if iscell(profile_idx), profile_idx = profile_idx{1}; end
        if iscell(ion_idx), ion_idx = ion_idx{1}; end
        if ~isnumeric(profile_idx) || ~isscalar(profile_idx) || ~isnumeric(ion_idx) || ~isscalar(ion_idx)
            error('Invalid profile_idx or ion_idx at state_checks(%d): profile_idx=%s, ion_idx=%s', ...
                i, mat2str(profile_idx), mat2str(ion_idx));
        end
        z_checks = {};
        for j = 1:length(z_min_checks)
            z_profile = z_min_checks{j}.profile_idx;
            z_ion = z_min_checks{j}.ion_idx;
            if iscell(z_profile), z_profile = z_profile{1}; end
            if iscell(z_ion), z_ion = z_ion{1}; end
            if ~isnumeric(z_profile) || ~isscalar(z_profile) || ~isnumeric(z_ion) || ~isscalar(z_ion)
                error('Invalid z_min_checks{%d}.profile_idx or ion_idx: profile_idx=%s, ion_idx=%s', ...
                    j, mat2str(z_profile), mat2str(z_ion));
            end
            if z_profile == profile_idx && z_ion == ion_idx
                z_checks = z_min_checks{j}.checks;
                break;
            end
        end
        assertions = addSpecificAssertions(assertions, ids, profile_idx, ion_idx, state_checks(i).expected_size, 'core_profiles', z_checks);
    end
    uninit_checks = checkUninitializedInRange(ids, 0, 9, 'profiles_1d.time', 'core_profiles');
    assertions = [assertions, uninit_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(1:5:2)/ion(:)', 'profiles_1d(3)/ion(2)', ids, assertions);

    % TEST 27: Check profiles_1d(::2)/time with exclude profiles_1d(4)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(::2)/time', 'profiles_1d(4)');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    time_checks = struct('idx', {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}, ...
                        'time', {1.0, 0.0, 3.0, 0.0, 5.0, 0.0, 7.0, 0.0, 9.0, 0.0}, ...
                        'initialized', {true, false, true, false, true, false, true, false, true, false});
    for i = 1:length(time_checks)
        assertions = addTimeAssertions(assertions, ids, time_checks(i).idx, time_checks(i).time, time_checks(i).initialized, 'core_profiles');
    end
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(::2)/time', 'profiles_1d(4)', ids, assertions);

    % TEST 28: Check profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time with exclude profiles_1d(5:6)/ion(3)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time', 'profiles_1d(5:6)/ion(3)');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    ion_sizes = struct('profile_idx', {0, 1, 2, 3, 4}, ...
                    'ion_idx', {0, 0, 0, 0, 0}, ...
                    'expected_size', {1, 2, 3, 4, 5});
    for i = 1:length(ion_sizes)
        matlab_idx = ion_sizes(i).profile_idx + 1;
        assertions(end+1) = create_assertion(length(ids.profiles_1d{matlab_idx}.ion) == ion_sizes(i).expected_size, ...
            sprintf('profiles_1d(%d).ion.size() == %d', ion_sizes(i).profile_idx, ion_sizes(i).expected_size));
    end
    ion_sizes_rest = checkArraySizeInRange(ids, 5, 9, 'profiles_1d.ion', 0, 'core_profiles');
    assertions = [assertions, ion_sizes_rest];
    time_checks = checkPathValuesInRange(ids, 0, 9, 'profiles_1d.time', 0, 'core_profiles', true);
    assertions = [assertions, time_checks];
    state_checks = struct('profile_idx', {4, 4, 4, 4}, ...
                        'ion_idx', {0, 1, 2, 3}, ...
                        'expected_size', {10, 0, 0, 0});
    for i = 1:length(state_checks)
        profile_idx = state_checks(i).profile_idx;
        ion_idx = state_checks(i).ion_idx;
        if iscell(profile_idx), profile_idx = profile_idx{1}; end
        if iscell(ion_idx), ion_idx = ion_idx{1}; end
        if ~isnumeric(profile_idx) || ~isscalar(profile_idx) || ~isnumeric(ion_idx) || ~isscalar(ion_idx)
            error('Invalid profile_idx or ion_idx at state_checks(%d): profile_idx=%s, ion_idx=%s', ...
                i, mat2str(profile_idx), mat2str(ion_idx));
        end
        assertions = addSpecificAssertions(assertions, ids, profile_idx, ion_idx, state_checks(i).expected_size, 'core_profiles', {});
    end
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(1:5:1)/ion(1:4:2);profiles_1d(:)/time', 'profiles_1d(5:6)/ion(3)', ids, assertions);

    % TEST 29: Check profiles_1d(:3)/ion(2) with exclude profiles_1d(2)/ion(2)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(:3)/ion(2)', 'profiles_1d(2)/ion(2)');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    ion_sizes = struct('profile_idx', {0, 1, 2}, ...
                    'ion_idx', {0, 0, 0}, ...
                    'expected_size', {1, 0, 3});
    for i = 1:length(ion_sizes)
        matlab_idx = ion_sizes(i).profile_idx + 1;
        assertions(end+1) = create_assertion(length(ids.profiles_1d{matlab_idx}.ion) == ion_sizes(i).expected_size, ...
            sprintf('profiles_1d(%d).ion.size() == %d', ion_sizes(i).profile_idx, ion_sizes(i).expected_size));
    end
    state_checks = struct('profile_idx', {2}, ...
                        'ion_idx', {1}, ...
                        'expected_size', {10});
    z_min_checks = {struct('profile_idx', 2, 'ion_idx', 1, 'checks', ...
                        {struct('state_idx', 5, 'z_min', 5), struct('state_idx', 6, 'z_min', 6)})};
    for i = 1:length(state_checks)
        profile_idx = state_checks(i).profile_idx;
        ion_idx = state_checks(i).ion_idx;
        if iscell(profile_idx), profile_idx = profile_idx{1}; end
        if iscell(ion_idx), ion_idx = ion_idx{1}; end
        if ~isnumeric(profile_idx) || ~isscalar(profile_idx) || ~isnumeric(ion_idx) || ~isscalar(ion_idx)
            error('Invalid profile_idx or ion_idx at state_checks(%d): profile_idx=%s, ion_idx=%s', ...
                i, mat2str(profile_idx), mat2str(ion_idx));
        end
        z_checks = {};
        for j = 1:length(z_min_checks)
            z_profile = z_min_checks{j}.profile_idx;
            z_ion = z_min_checks{j}.ion_idx;
            if iscell(z_profile), z_profile = z_profile{1}; end
            if iscell(z_ion), z_ion = z_ion{1}; end
            if ~isnumeric(z_profile) || ~isscalar(z_profile) || ~isnumeric(z_ion) || ~isscalar(z_ion)
                error('Invalid z_min_checks{%d}.profile_idx or ion_idx: profile_idx=%s, ion_idx=%s', ...
                    j, mat2str(z_profile), mat2str(z_ion));
            end
            if z_profile == profile_idx && z_ion == ion_idx
                z_checks = z_min_checks{j}.checks;
                break;
            end
        end
        assertions = addSpecificAssertions(assertions, ids, profile_idx, ion_idx, state_checks(i).expected_size, 'core_profiles', z_checks);
    end
    uninit_checks = checkUninitializedInRange(ids, 0, 9, 'profiles_1d.time', 'core_profiles');
    assertions = [assertions, uninit_checks];
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(:3)/ion(2)', 'profiles_1d(2)/ion(2)', ids, assertions);

    % TEST 30: Check profiles_1d() (expecting ALPluginException)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    exception_caught = false;
    try
        ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d()', '');
    catch
        exception_caught = true;
    end
    if exception_caught
        desc = 'ALPluginException caught as expected for profiles_1d()';
    else
        desc = 'Expected ALPluginException not thrown for profiles_1d()';
    end
    assertions(end+1) = create_assertion(exception_caught, desc);
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d()', '', ids, assertions);

    % TEST 31: Check profiles_1d("") (expecting ALPluginException)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    exception_caught = false;
    try
        ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d("")', '');
    catch
        exception_caught = true;
    end
    if exception_caught
        desc = 'ALPluginException caught as expected for profiles_1d("")';
    else
        desc = 'Expected ALPluginException not thrown for profiles_1d("")';
    end
    assertions(end+1) = create_assertion(exception_caught, desc);
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d("")', '', ids, assertions);

    % TEST 32: Check profiles_1d(-1) (expecting ALPluginException)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    exception_caught = false;
    try
        ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(-1)', '');
    catch
        exception_caught = true;
    end
    if exception_caught
        desc = 'ALPluginException caught as expected for profiles_1d(-1)';
    else
        desc = 'Expected ALPluginException not thrown for profiles_1d(-1)';
    end
    assertions(end+1) = create_assertion(exception_caught, desc);
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(-1)', '', ids, assertions);

    % TEST 33: Check profiles_1d(9999) (expecting no data at all from profiles_1d, only allocated)
    test_index = test_index + 1;
    assertions = struct('passed', {}, 'description', {});
    ids = imas_partial_get(idx, 'core_profiles', 0, 'profiles_1d(9999)', '');
    assertions(end+1) = create_assertion(length(ids.ids_properties.comment) == 0, 'ids_properties.comment.length() == 0');
    assertions(end+1) = create_assertion(length(ids.profiles_1d) == 10, 'profiles_1d.size() == 10');
    time_checks = struct('idx', {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}, ...
                        'time', {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0}, ...
                        'initialized', false);
    for i = 1:length(time_checks)
        assertions = addTimeAssertions(assertions, ids, time_checks(i).idx, time_checks(i).time, time_checks(i).initialized, 'core_profiles');
    end
    all_tests_passed = all_tests_passed && runTest(test_index, 'profiles_1d(9999)', '', ids, assertions);

    fprintf('----------------------------------------\n\n');
    if all_tests_passed
        fprintf('Partial get plugin tests successful.\n');
    else
        fprintf('ERROR: Partial get plugin tests have failed.\n');
        error('Tests failed');
    end

    imas_close(idx);
end

function save_data(uri)
    % SAVE_DATA Saves core_profiles IDS data to an IMAS database.
    %   uri: String specifying the database URI
    %
    %   This function creates and populates an IMAS core_profiles IDS structure,
    %   allocates nested arrays, fills them with data, and saves to the database.

    % Initialize IDS data entry
    idx = imas_open(uri, 43)
    ids = ids_init('core_profiles');

    % Define parameters
    number = 10; % Number of elements for profiles_1d
    pulse = 12;
    run = 2;
    refpulse = 0;
    refrun = 0;

    % Define first generic vector and its time base
    time_1 = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0];
    vect1DDouble_1 = time_1 * 10; % Element-wise multiplication

    % Define second generic vector
    time_2 = [11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0];
    vect1DDouble_2 = time_2 * 2 + 10; % Element-wise operation

    % Allocate ids fields
    Sz = length(time_1); % Number of profiles_1d elements
    % Initialize profiles_1d
    ids.profiles_1d = ids_allocate('core_profiles', 'profiles_1d', Sz);

    fprintf('Completed allocation of %d profiles_1d\n', Sz);

    % Fill profiles_1d fields
    for i = 1:Sz
        % Vary the size of the grid.rho_tor_norm array with time index
        ids.profiles_1d{i}.grid.rho_tor_norm = zeros(1, i); % MATLAB 1-based, size i
        for j = 1:i
            ids.profiles_1d{i}.grid.rho_tor_norm(j) = vect1DDouble_1(j);
        end
        ids.profiles_1d{i}.time = time_1(i);

        % Allocate ion array of structures

        ids.profiles_1d{i}.ion = ids_allocate('core_profiles', 'profiles_1d/ion', i);

        % Fill ion fields
        for j = 1:i
            ids.profiles_1d{i}.ion{j}.z_ion = time_1(j);
            % Allocate density array
            ids.profiles_1d{i}.ion{j}.density = zeros(1, i); % Size i
            for k = 1:i
                ids.profiles_1d{i}.ion{j}.density(k) = vect1DDouble_1(k) + (j-1);
            end
            % Allocate state array of structures
            ids.profiles_1d{i}.ion{j}.state = ids_allocate('core_profiles', 'profiles_1d/ion/state', 10);

            for k = 1:10
                ids.profiles_1d{i}.ion{j}.state{k}.z_min = k-1;
            end
        end
    end
    fprintf('Completed filling of profiles_1d fields\n');

    % Fill top-level ids fields
    ids.ids_properties.homogeneous_time = 0; % Mandatory property
    ids.ids_properties.comment = 'Testing the partial get plugin';

    % Allocate and fill global_quantities.ip
    ids.global_quantities.ip = zeros(1, length(time_2));
    for ii = 1:length(time_2)
        ids.global_quantities.ip(ii) = vect1DDouble_2(ii);
    end

    % Allocate and fill ids.time
    ids.time = zeros(1, length(time_2));
    for j = 1:length(time_2)
        ids.time(j) = time_2(j);
    end

    % Save the core_profiles IDS
    fprintf('\nStart Putting the core_profiles IDS\n');
    
    ids_put(idx, 'core_profiles', ids);

    fprintf('core_profiles IDS pulse:%d, run:%d, refpulse:%d, refrun:%d saved\n', ...
            pulse, run, refpulse, refrun);

    % Close the data entry
    imas_close(idx)
end

