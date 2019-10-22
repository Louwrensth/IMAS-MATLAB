
%% Test Class Definition
classdef imas_perf_tests_convert < matlab.perftest.TestCase

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
      run = imas_perf_tests_convert.getRunNumber(ntime);
      if useCache
        idxr = imas_open_memory('ids',9999,run     ,'test','3');
        idxw = imas_open_memory('ids',9999,run+9900,'test','3');
      else
        idxr = imas_create_env('ids',9999,run     ,0,0,getenv('USER'),'test','3');
        idxw = imas_create_env('ids',9999,run+9900,0,0,getenv('USER'),'test','3');
      end
      testCase.addTeardown(@imas_close,idxr);
      testCase.addTeardown(@imas_close,idxw);
      testCase.TestData.idxr = idxr;
      testCase.TestData.idxw = idxw;
      %
      for name = testCase.IDSname
        clear ids;
        ids = ids_rand(name{1},ntime,false);
        %
        ids_put(idxr,name{1},ids);
        ids_put(idxw,name{1},ids);
        %
        testCase.TestData.IDS.(name{1}) = ids;
        testCase.TestData.IDS_conv.(name{1}) = ids_int_to_double(name{1},ids);
      end
    end
  end

  %% Test Method Setup Parameters
  properties (MethodSetupParameter)
    convMethod = struct('no',-1,'loc',0,'glo',1,'ext',2)
  end
  
  methods (TestMethodSetup)
    function setupTest(testCase, convMethod)
      params = imas_get_mex_params;
      testCase.addTeardown(@imas_set_mex_params,params);
      switch convMethod
        case {-1,2}
          params.put_int_from_double = false;
          params.get_int_as_double = false;
        case 0
          params.convert_whole_ids = false;
          params.put_int_from_double = true;
          params.get_int_as_double = true;
        case 1
          params.convert_whole_ids = true;
          params.put_int_from_double = true;
          params.get_int_as_double = true;
        otherwise
          error('Unsupported value for convMethod: %d',convMethod);
      end
      imas_set_mex_params(params);
      testCase.TestData.convMethod = convMethod;
    end
  end
  
  %% Test Method Parameters
  properties (TestParameter)
    IDSname = IDS_list.';
  end
      

  %% Test Method Block
  methods (Test)

    function Put(testCase, IDSname)
      switch testCase.TestData.convMethod
        case -1
          testCase.startMeasuring;
          ids_put(testCase.TestData.idxw, IDSname, testCase.TestData.IDS.(IDSname));
          testCase.stopMeasuring;
        case {0,1}
          testCase.startMeasuring;
          ids_put(testCase.TestData.idxw, IDSname, testCase.TestData.IDS_conv.(IDSname));
          testCase.stopMeasuring;
        case 2
          testCase.startMeasuring;
          ids = ids_double_to_int(IDSname,testCase.TestData.IDS_conv.(IDSname));
          ids_put(testCase.TestData.idxw, IDSname, ids);
          testCase.stopMeasuring;
      end
    end

    function Get(testCase, IDSname)
      switch testCase.TestData.convMethod
        case {-1,0,1}
          testCase.startMeasuring;
          ids = ids_get(testCase.TestData.idxr, IDSname);
          testCase.stopMeasuring;
        case 2
          testCase.startMeasuring;
          sdi = ids_get(testCase.TestData.idxr, IDSname);
          ids = ids_int_to_double(IDSname, sdi);
          testCase.stopMeasuring;
      end
    end

  end
  
  %% Static Method Block
  methods (Static)
    
    function run = getRunNumber(ntime)
      newLL = str2double(strtok(getenv('UAL_VERSION'),'.')) > 3;
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
