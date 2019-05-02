
%% Test Class Definition
classdef imas_perf_tests < matlab.perftest.TestCase

  properties
    TestData
  end

  properties (ClassSetupParameter)
    useCache = struct('yes',true,'no',false);
    ntime = struct('small',3,'medium',96,'large',3072)
  end

  %% Class-level setup
  methods (TestClassSetup)
    function createIMASDb(testCase, useCache, ntime)
      idx = imas_create_env('ids',9999,9999,0,0,'g2amerle','test','3');
      testCase.addTeardown(@imas_close,idx);
      if useCache
        imas_enable_mem_cache(idx);
        testCase.addTeardown(@imas_disable_mem_cache,idx);
        testCase.addTeardown(@imas_discard_mem_cache,idx);
      end
      testCase.TestData.idx = idx;
      %
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

    function Put(testCase, IDSname)
      ids = testCase.TestData.IDS.(IDSname);
      ids_put(testCase.TestData.idx, IDSname, testCase.TestData.IDS.(IDSname));
    end

    function Get(testCase, IDSname)
      ids = ids_get(testCase.TestData.idx, IDSname);
    end

  end

end
