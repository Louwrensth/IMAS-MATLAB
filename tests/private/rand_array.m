function a = rand_array(type, ndim, dynamic, slice)
  s = 2.^(randi([0, 4], [1,ndim]));
  if (dynamic) s(end) = 3; end
  if (ndim == 1) s(2) = 1; end
  if (strcmp(type,'float'))
    a = randn(s);
  elseif (strcmp(type,'integer'))
    a = int32(randi([-2^30, 2^30],s));
  elseif (strcmp(type,'string'))
    assert(ndim == 1,'Only 1D array of strings are supported');
    a = arrayfun(@(i) sprintf('label%d',i),1:s(1),'UniformOutput',false);
  end
  if (dynamic && slice)
    if (strcmp(type,'string') && ndim == 1)
      a = a(1,:);
    else
      s = cell(1,ndim);
      s(1:ndim-1) = {':'};
      s(ndim)     = {1};
      a = subsref(a,substruct('()',s));
    end
  end
  
  
  