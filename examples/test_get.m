ctx = imas_open_env('ids',12,1,getenv('USER'),'test','3');
if ctx < 0
    error('Unable to open pulse');
end

m = ids_get(ctx, 'magnetics');

disp(m.ids_properties);
disp(m.time);
disp(m.flux_loop{1}.flux.data);