
%% Test Class Definition
classdef imas_unit_tests < matlab.unittest.TestCase

  properties
    TestData
  end

  properties (ClassSetupParameter)
    useCache = struct('yes',true,'no',false);
  end

  %% Class-level setup
  methods (TestClassSetup)
    function createIMASDb(testCase, useCache)
      idx = imas_create_env('ids',9999,9999,0,0,'g2amerle','test','3');
      testCase.addTeardown(@imas_close,idx);
      if useCache
        imas_enable_mem_cache(idx);
        testCase.addTeardown(@imas_disable_mem_cache,idx);
        testCase.addTeardown(@imas_discard_mem_cache,idx);
      end
      testCase.TestData.idx = idx;
      %
      ntime = 3;
      for name = IDS_list.'
        testCase.TestData.IDS.(name{1})       = ids_rand(name{1},ntime,false);
        testCase.TestData.IDS_slice.(name{1}) = ids_rand(name{1},ntime,true );
      end
      %
    end
  end

  %% Test Method Parameters
  properties (TestParameter)
    IDSname = IDS_list.';
  end

  %% Test Method Block
  methods (Test)

    function testPutGet(testCase, IDSname)
      idx = testCase.TestData.idx;
      ids = testCase.TestData.IDS.(IDSname);
      ids_put(idx,IDSname,ids);
      sdi = ids_get(idx,IDSname);
      comparator(ids,sdi,IDSname);
    end
    
    function testPutGetSlice(testCase, IDSname)
      idx = testCase.TestData.idx;
      ids = testCase.TestData.IDS.(IDSname);
      time = 1.0;
      interp = 1; % closest sample
      ids_slice = testCase.TestData.IDS_slice.(IDSname);
      ids_put(idx,IDSname,ids);
      sdi = ids_get_slice(idx,IDSname,time,interp);
      comparator(ids_slice,sdi,IDSname);
    end
    
    function testPutSliceGet(testCase, IDSname)
      idx = testCase.TestData.idx;
      ids_slice = testCase.TestData.IDS_slice.(IDSname);
      ids_put(idx,IDSname,ids_slice);
      sdi = ids_get(idx,IDSname);
      comparator(ids_slice,sdi,IDSname);
    end

    function testPutSliceGetSlice(testCase, IDSname)
      idx = testCase.TestData.idx;
      time = 1.0;
      interp = 1; % closest sample
      ids_slice = testCase.TestData.IDS_slice.(IDSname);
      ids_put(idx,IDSname,ids_slice);
      sdi = ids_get_slice(idx,IDSname,time,interp);
      comparator(ids_slice,sdi,IDSname);
    end

  end

end
