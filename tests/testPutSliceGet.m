function testPutSliceGet(testCase,path)
	idx = testCase.TestData.idx;
	ids = ids_rand(path,true);
	ids_put(idx,path,ids);
	sdi = ids_get(idx,path);
	comparator(ids,sdi,path);
end