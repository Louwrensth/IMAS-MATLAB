
%% Test Class Definition
classdef imas_perf_tests < matlab.perftest.TestCase

  properties
    TestData
  end

  properties (ClassSetupParameter)
    % useCache = struct('yes',true,'no',false); % Disabled for now ...
    useCache = struct('no',false);
    ntime = struct('small',3,'medium',24,'large',192)
  end

  %% Class-level setup
  methods (TestClassSetup)
    function createIMASDb(testCase, useCache, ntime)
      run = imas_perf_tests.getRunNumber(ntime);
      idxr = imas_open_env('ids',9999,run,0,0,getenv('USER'),'test','3');
      idxw = imas_create_env('ids',9999,run+9900,getenv('USER'),'test','3');
      testCase.addTeardown(@imas_close,idx);
      if useCache
        imas_enable_mem_cache(idx);
        testCase.addTeardown(@imas_disable_mem_cache,idx);
        testCase.addTeardown(@imas_discard_mem_cache,idx);
      end
      testCase.TestData.idxr = idxr;
      testCase.TestData.idxw = idxw;
      %
      for name = IDS_list.'
        testCase.TestData.IDS.(name{1}) = ids_rand(name{1},ntime,false);
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
      ids_put(testCase.TestData.idxw, IDSname, testCase.TestData.IDS.(IDSname));
    end

    function Get(testCase, IDSname)
      ids = ids_get(testCase.TestData.idxr, IDSname);
    end

  end
  
  %% Static Method Block
  methods (Static)
    
    function run = getRunNumber(ntime)
      newLL = str2num(strtok(getenv('AL_VERSION'),'.')) > 3;
      base = 0+10*~newLL;
      switch ntime
        case 3,    number = 1;
        case 24,   number = 2;
        case 192,  number = 3;
        otherwise, number = 9;
      end
      run = base + number;
    end
    
  end
end
