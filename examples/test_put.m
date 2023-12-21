ctx = imas_open_env('ids',12,1,'imas','test','3');
if ctx < 0
    error('Unable to open pulse');
end

m = ids_gen('magnetics');

m.ids_properties.homogeneous_time = 1;
m.flux_loop{1}.flux.data(1) = 10.0;
m.flux_loop{1}.flux.data(2) = 20.0;
m.time(1) = 2.0;
m.time(2) = 5.0;

ids_put(ctx, 'magnetics', m);

imas_close(ctx);
