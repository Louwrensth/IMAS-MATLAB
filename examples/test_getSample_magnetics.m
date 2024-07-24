uri = 'imas:mdsplus?path=./test_db';
ctx = imas_open(uri, 43);
if ctx < 0
    error('Unable to open pulse');
end

m = ids_gen('magnetics');

dynamicSize = 10;
staticSize = 3;
m.ids_properties.homogeneous_time = 1;
for c = 1:dynamicSize
    m.time(c) = c*0.1;
    for r = 1:staticSize
        m.flux_loop{r}.flux.data(c) = r*100.0+c;
    end
end

ids_put(ctx, 'magnetics', m);

imas_close(ctx);

ctx = imas_open(uri, 43);

dtime = [];

m = ids_getSample(ctx,'magnetics', 0.3, 0.8, dtime, 0, 0);

fprintf('size(m) is %s\n', int2str(size(m)));

imas_close(ctx);
