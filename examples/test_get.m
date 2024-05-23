uri = 'imas:mdsplus?path=./test_db';
ctx = imas_open(uri, 40);
if ctx < 0
    error('Unable to open pulse');
end

m = ids_get(ctx, 'magnetics');

disp(m.ids_properties);
disp(m.time);
disp(m.flux_loop{1}.flux.data);