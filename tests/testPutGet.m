function testPutGet(testCase, path)
  idx = testCase.TestData.idx;
  ids = testCase.TestData.IDS.(path);
  ids_put(idx,path,ids);
  sdi = ids_get(idx,path,0);
  comparator(ids,sdi,path);
end