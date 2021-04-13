
%% Test Class Definition
classdef imas_unit_tests < matlab.unittest.TestCase

  properties
    TestData
  end

  properties (ClassSetupParameter)
	backend_id = struct('MDSPLUS',13,'HDF5',13); %new backend for testing should be added here using ('backend label', backend_ID) where backend_ID is defined in /lowlevel/ual_const.h
  end

  methods (TestClassSetup)
        function classSetup(testCase,backend_id)
			message = ['Executing unit tests for backend ID: ' , num2str(backend_id)];
		    disp(message);
			%hdf5_version = getenv('EBVERSIONHDF5');
			hdf5_version = '1.8.12';
			al_hdf5_maj_version = int32(hdf5_version(1)) - int32('0');
			al_hdf5_min_version = int32(hdf5_version(3)) - int32('0');
			al_hdf5_rel_version = int32(hdf5_version(3)) - int32('0');
			[majnum, minnum, relnum] = H5.get_libversion();
			testCase.TestData.ignoreTests = 0;
			if (backend_id == 13 && (al_hdf5_maj_version ~= majnum || al_hdf5_min_version ~= minnum  ))
				testCase.TestData.ignoreTests = 1;
				warning('HDF5 version %s not supported (MATLAB is using HDF5 version %s.%s.%s). HDF5 backend tests will be disabled.\n ', hdf5_version, int2str(majnum), int2str(minnum), int2str(relnum));
				return;
			end
			idx = imas_create_env_backend (9999, 9999, getenv('USER'),'test','3', backend_id);
			testCase.TestData.idx = idx;
			testCase.addTeardown(@imas_close,idx);
        end
    end

  properties (MethodSetupParameter)
    % useCache = struct('yes',true,'no',false); % Disabled for now ...
    useCache = struct('no',false);
    homogeneousTime = struct('yes',true,'no',false);
  end

  %% Class-level setup
  methods (TestMethodSetup)
    function methodSetup(testCase, useCache, homogeneousTime)
		if (testCase.TestData.ignoreTests == 1)
			return
		end
		if useCache
			imas_enable_mem_cache(testCase.TestData.idx);
			testCase.addTeardown(@imas_disable_mem_cache,testCase.TestData.idx);
			testCase.addTeardown(@imas_discard_mem_cache,testCase.TestData.idx);
		end
		%testCase.TestData.idx = idx;
		%
		ntime = 3;
		hT = int32(homogeneousTime);
		for name = IDS_list.'
			testCase.TestData.IDS.(name{1}) = ids_rand(name{1},ntime,0);
			testCase.TestData.IDS.(name{1}).ids_properties.homogeneous_time = hT;
			testCase.TestData.IDS_slice.(name{1}) = cell(ntime,1);
			for itime = 1:ntime
			  testCase.TestData.IDS_slice.(name{1}){itime} = ids_rand(name{1},ntime,itime);
			  testCase.TestData.IDS_slice.(name{1}){itime}.ids_properties.homogeneous_time = hT;
			end
		end
	  %end
      %
    end
  end

  %% Test Method Parameters
  properties (TestParameter)
    IDSname = IDS_list.';
  end


  %% Test Method Block
  methods (Test)

    
    
    function testPutSlice(testCase, IDSname)
	  if (testCase.TestData.ignoreTests == 1)
			return
	  end
	 
	  message = ['Executing ids_put slice unit tests for : ' , IDSname];
	  disp(message);
      idx = testCase.TestData.idx;
      ids = testCase.TestData.IDS.(IDSname);
      ids_slice = testCase.TestData.IDS_slice.(IDSname);
      ids_put(idx,IDSname,ids_slice{1});
	  message = ['Executing ids_put_slice unit tests for : ' , IDSname];
	  disp(message);
      for itime=2:numel(ids_slice)
        ids_put_slice(idx,IDSname,ids_slice{itime});
      end
      % Test get
	  message = ['Executing ids_get unit tests for : ' , IDSname];
	  disp(message);
      sdi = ids_get(idx,IDSname);
      comparator(ids,sdi,IDSname);
      % Test get_slice
      itime = 2;
      interp = 1; % closest sample
	  message = ['Executing ids_get_slice unit tests for : ' , IDSname];
	  disp(message);
      sdi = ids_get_slice(idx,IDSname,ids.time(itime),interp);
      comparator(ids_slice{itime},sdi,IDSname);
    end

  end

end
