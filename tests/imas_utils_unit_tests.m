
%% Test Class Definition
classdef imas_utils_unit_tests < matlab.unittest.TestCase

  properties (ClassSetupParameter)
  end

  %% Class-level setup
  methods (TestClassSetup)
  end

  %% Test Method Parameters
  properties (TestParameter)
    IDSname = IDS_list.';
    ntime = struct('small',3);
  end

  %% Test Method Block
  methods (Test)

    function rand(TestCase, IDSname, ntime)
      ids1 = ids_rand(IDSname, ntime, 0);
      ids2 = ids_rand(IDSname, ntime, 2);
    end

    function gen(TestCase, IDSname)
      ids = ids_gen(IDSname);
    end

    function int_to_double(TestCase, IDSname, ntime)
      ids = ids_rand(IDSname, ntime, 0);
      sdi = ids_int_to_double(IDSname, ids);
    end
    
    function double_to_int(TestCase, IDSname, ntime)
      ids = ids_int_to_double(IDSname, ids_rand(IDSname, ntime, 0));
      sdi = ids_double_to_int(IDSname, ids);
    end
    
    function empty_to_nan(TestCase, IDSname, ntime)
      ids = ids_rand(IDSname, ntime, 0);
      sdi = ids_empty_to_nan(IDSname, ids);
    end
    
    function nan_to_empty(TestCase, IDSname, ntime)
      ids = ids_rand(IDSname, ntime, 0);
      sdi = ids_nan_to_empty(IDSname, ids);
    end
    
    function cell_to_struct(TestCase, IDSname, ntime)
      params = imas_get_mex_params;
      imas_set_mex_params('use_cell_array_for_array_of_structures',true);
      ids = ids_rand(IDSname, ntime, 0);
      sdi = ids_cell_to_struct(IDSname, ids);
      imas_set_mex_params(params);
    end
    
    function struct_to_cell(TestCase, IDSname, ntime)
      params = imas_get_mex_params;
      imas_set_mex_params('use_cell_array_for_array_of_structures',false);
      ids = ids_rand(IDSname, ntime, 0);
      sdi = ids_struct_to_cell(IDSname, ids);
      imas_set_mex_params(params);
    end
    
  end

end
