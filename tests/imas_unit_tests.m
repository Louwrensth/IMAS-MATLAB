%% Test Class Definition
classdef imas_unit_tests < matlab.unittest.TestCase

  properties
    TestData
  end

  properties (ClassSetupParameter)
    % useCache = struct('yes',true,'no',false); % Disabled for now ...
    useCache = struct('no',false);
    homogeneousTime = struct('yes',true,'no',false);
    backend = struct('MDSplus',12,'HDF5',13);
  end

  %% Class-level setup
  methods (TestClassSetup)
    function createIMASDb(testCase,backend,useCache,homogeneousTime)
      idx = imas_create_env_backend(9999,9999,getenv('USER'),'test','3',backend);
      testCase.addTeardown(@imas_close,idx);
      if useCache
        imas_enable_mem_cache(idx);
        testCase.addTeardown(@imas_disable_mem_cache,idx);
        testCase.addTeardown(@imas_discard_mem_cache,idx);
      end
      testCase.TestData.idx = idx;
      %
      ntime = 3;
      hT = int32(homogeneousTime);
      for name = IDS_list.'
        testCase.TestData.IDS.(name{1}) = ids_rand(name{1},ntime,0);
    if isfield(testCase.TestData.IDS.(name{1}), "time") 
        testCase.TestData.IDS.(name{1}).ids_properties.homogeneous_time = hT;
    else %IDS is constant, homogeneous_time is set to 2
        testCase.TestData.IDS.(name{1}).ids_properties.homogeneous_time = int32(2);
    end
        testCase.TestData.IDS_slice.(name{1}) = cell(ntime,1);
        for itime = 1:ntime
          testCase.TestData.IDS_slice.(name{1}){itime} = ids_rand(name{1},ntime,itime);
      if isfield(testCase.TestData.IDS.(name{1}), "time")
        testCase.TestData.IDS_slice.(name{1}){itime}.ids_properties.homogeneous_time = hT;
      else
        testCase.TestData.IDS_slice.(name{1}){itime}.ids_properties.homogeneous_time = int32(2);
      end
        end
      end
      %
    end
  end

  methods (TestClassTeardown)
    function closeIMASDb(testCase,backend,useCache,homogeneousTime)
      idx = testCase.TestData.idx
      imas_close(idx)
    end
  end

  %% Test Method Parameters
  properties (TestParameter)
    IDSname = IDS_list.';
  end

  %% Test Method Block
  methods (Test)

    function testPut(testCase, IDSname)
      idx = testCase.TestData.idx;
      ids = testCase.TestData.IDS.(IDSname);
      ids_slice = testCase.TestData.IDS_slice.(IDSname);

      try
        ids_put(idx,IDSname,ids);
      catch ME
        if strcmp(ME.identifier, 'IMAS:ids_put:internal_error')
          warning('Test skipped in ids_put/validate for %s due to %s', IDSname, ME.message);
          return;
        else
          rethrow(ME);
        end
      end

      % Test get
      sdi = ids_get(idx,IDSname);
      comparator(ids,sdi,IDSname);
      % Test get_slice
      if isfield(ids,'time')
        itime = 2;
        interp = 1; % closest sample
        sdi = ids_get_slice(idx,IDSname,ids.time(itime),interp);
        comparator(ids_slice{itime},sdi,IDSname);
      else %IDS is constant, ids_get_slice() should behave as get()
        sdi_slice = ids_get_slice(idx,IDSname,0,1);
        comparator(sdi,sdi_slice,IDSname);
      end	
    end
    
    function testPutSlice(testCase, IDSname)
      idx = testCase.TestData.idx;
      ids = testCase.TestData.IDS.(IDSname);
      ids_slice = testCase.TestData.IDS_slice.(IDSname);

      try
        ids_put(idx,IDSname,ids_slice{1});
        for itime=2:numel(ids_slice)
          ids_put_slice(idx,IDSname,ids_slice{itime});
        end
      catch ME
        if strcmp(ME.identifier, 'IMAS:ids_put:internal_error')
          warning('Test skipped in ids_put/validate for %s due to %s', IDSname, ME.message);
          return;
        else
          rethrow(ME);
        end
      end

      % Test get
      sdi = ids_get(idx,IDSname);
      comparator(ids,sdi,IDSname);
      % Test get_slice
      if isfield(ids,'time')
        itime = 2;
        interp = 1; % closest sample
        sdi = ids_get_slice(idx,IDSname,ids.time(itime),interp);
        comparator(ids_slice{itime},sdi,IDSname);
      else %IDS is constant, ids_put_slice() should behave as put()
        comparator(sdi,ids,IDSname);
      end
    end

  end

end
