function testPutSliceGetSlice(testCase, path)
	idx = testCase.TestData.idx;
	ids = ids_rand(path,true);
	ids_put(idx,path,ids);
	time = 1.0;
	interp = 1; % closest sample
	sdi = ids_get_slice(idx,path,time,interp);
	comparator(ids,sdi,path);
end