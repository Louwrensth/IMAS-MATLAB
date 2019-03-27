function testPutGet(testCase,path)
	idx = testCase.TestData.idx;
	ids = ids_rand(path,false);
	ids_put(idx,path,ids);
	sdi = ids_get(idx,path,0);
	comparator(ids,sdi,path);
end