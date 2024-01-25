ids1 = ids_gen('magnetics');

ids1.ids_properties.homogeneous_time = 1;
ids1.flux_loop{1}.flux.data(1) = 10.0;
ids1.flux_loop{1}.flux.data(2) = 20.0;
ids1.time(1) = 2.0;
ids1.time(2) = 5.0;

serialized_bytes = imas_serialize(ids1, 'magnetics');

ids2 = imas_deserialize(serialized_bytes, 'magnetics');

% Check if both ids are same
ids1_fieldnames=fieldnames(ids1);
ids2_fieldnames=fieldnames(ids2);
intersection=intersect(ids1_fieldnames,ids2_fieldnames);
ids1_check=rmfield(ids1,intersection);
ids2_check=rmfield(ids2,intersection);
result = isempty(ids1_check) & isempty(ids2_check);
assert(result==0, "Issue in serializing");

assert(ids1.time(1) == ids2.time(1), "Issue in serializing");
assert(ids1.time(2) == ids2.time(2), "Issue in serializing");
assert(ids1.ids_properties.homogeneous_time == ids2.ids_properties.homogeneous_time, "Issue in serializing");
assert(ids1.flux_loop{1}.flux.data(1) == ids2.flux_loop{1}.flux.data(1), "Issue in serializing");