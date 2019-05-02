function t = rand_time(ntime, slice)
  t=[1:ntime].';
  if slice, t=t(1);end
