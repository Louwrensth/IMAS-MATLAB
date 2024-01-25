magnetics_ids = ids_gen('magnetics');

is_defined = ids_isdefined(magnetics_ids);

assert(is_defined==false, "Issue in ids_isdefined test");

% set the ids_properties.homogeneous_time field
magnetics_ids.ids_properties.homogeneous_time = 1;

is_defined = ids_isdefined(magnetics_ids) %true;

assert(is_defined==true, "Issue in ids_isdefined test");
