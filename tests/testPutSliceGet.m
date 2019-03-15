function testPutSliceGet(testCase,path)
	idx = testCase.TestData.idx;
	ids = ids_rand(path,true);
	ids_put_non_timed(idx,path,0,ids);
	ids_put_slice(idx,path,0,ids);
	sdi = ids_get(idx,path,0);
	comparator(ids,sdi,path);
end