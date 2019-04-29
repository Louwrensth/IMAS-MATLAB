function testPutSliceGet(testCase, path)
  idx = testCase.TestData.idx;
  ids_slice = testCase.TestData.IDS_slice.(path);
  ids_put_non_timed(idx,path,ids_slice);
  ids_put_slice(idx,path,ids_slice);
  sdi = ids_get(idx,path);
  comparator(ids_slice,sdi,path);
end