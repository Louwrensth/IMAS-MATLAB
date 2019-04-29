function testPutSliceGetSlice(testCase, path)
  idx = testCase.TestData.idx;
  time = 1.0;
  interp = 1; % closest sample
  ids_slice = testCase.TestData.IDS_slice.(path);
  ids_put_non_timed(idx,path,ids_slice);
  ids_put_slice(idx,path,ids_slice);
  sdi = ids_get_slice(idx,path,time,interp);
  comparator(ids_slice,sdi,path);
end