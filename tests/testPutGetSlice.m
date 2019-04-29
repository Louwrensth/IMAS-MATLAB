function testPutGetSlice(testCase, path)
  idx = testCase.TestData.idx;
  ids = testCase.TestData.IDS.(path);
  time = 1.0;
  interp = 1; % closest sample
  ids_slice = testCase.TestData.IDS_slice.(path);
  ids_put(idx,path,ids);
  sdi = ids_get_slice(idx,path,time,interp);
  comparator(ids_slice,sdi,path);
end