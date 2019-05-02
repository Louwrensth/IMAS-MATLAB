function ids = ids_rand(idsName, ntime, slice, double)
  if nargin < 4,
    double = false;
  end
  
  persistent cache
  
  cacheName_int = [idsName,sprintf('_%d_%1d_%1d',ntime,logical(slice),false)];
  cacheName_dbl = [idsName,sprintf('_%d_%1d_%1d',ntime,logical(slice),true)];
  if ~isfield(cache,cacheName_int) && ~isfield(cache,cacheName_dbl)
    f = ['rand_',idsName];
    cache.(cacheName_int) = feval(f,ntime,slice);
    cache.(cacheName_dbl) = ids_int_to_double(idsName, cache.(cacheName_int));
  end
  if double,
    ids = cache.(cacheName_dbl);
  else
    ids = cache.(cacheName_int);
  end
end
