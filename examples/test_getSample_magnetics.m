uri = 'imas:hdf5?path=./test_db';
ctx = imas_open(uri, 43);
if ctx < 0
    error('Unable to open pulse');
end

m = ids_gen('magnetics');

tmin = 0.3;
tmax = 0.8;
dynamicSize = 10;
staticSize = 3;
m.ids_properties.homogeneous_time = 1;
for c = 1:dynamicSize
    m.time(c) = c*0.1;
end

ids_put(ctx, 'magnetics', m);

imas_close(ctx);

ctx = imas_open(uri, 40);

dtime = [];

m = ids_getSample(ctx,'magnetics', tmin, tmax, dtime, 0);

disp("Check size of magnetics timerange.")
if size(m.time,1) == (tmax-tmin)/0.1 +1
    disp("...Passed.");
else 
    errmsg = ["...Error m.time size not verified.", int2str(size(m.time,1)), " / ", int2str((tmax-tmin)/0.1 +1)];
    disp(errmsg);
end

step = 0.05;
dtime = [step];

m = ids_getSample(ctx,'magnetics', tmin, tmax, dtime, 1);

disp("Check size of magnetics timerange.")
if size(m.time,1) == (tmax-tmin)/step + 1
    disp("...Passed.");
else 
    errmsg = ["...Error m.time size not verified.", int2str(size(m.time,1)), " / ", int2str((tmax-tmin)/step +1)];
    disp(errmsg);
end

imas_close(ctx);