%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                            data entry parameters                             ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝
%     backend_id: ID of the backend to use. Available options:
%           - 11: :ref:`ASCII backend`
%           - 12: :ref:`MDSplus backend`
%           - 13: :ref:`HDF5 backend`
%           - 14: :ref:`Memory backend`
%           - 15: :ref:`UDA backend`

user        = getenv('USER');
db_name     = 'f4f';
shot        = 10;
run         = 10;
version     = '3';
backend_id  = 13;

%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                          opening existing data entry                         ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝

ctx         = imas_open_env_backend (shot, run, user, db_name, version, backend_id);
ids_summary = ids_get(ctx, 'summary');

%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                                data extraction                               ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝

summary_time       = ids_summary.time;
summary_comment    = ids_summary.ids_properties.comment;
summary_al_version = ids_summary.ids_properties.version_put.access_layer;
summary_ip_value   = ids_summary.global_quantities.ip;

disp(['=== IDS SUMMARY COMMENT: ', summary_comment]);
disp(['=== IDS SUMMARY AL PUT VERSION:', summary_al_version]);
disp('=== IDS SUMMARY global_quantities/ip array:');
disp(summary_ip_value);

%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                              closing data entry                              ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝

imas_close(ctx);

%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                            creating new data entry                           ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝

ctx             = imas_create_env_backend (shot+1, run, user, db_name, version, backend_id);
new_ids_summary = ids_get(ctx, 'summary');

%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                   copying previously read data into new ids                  ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝

new_ids_summary.ids_properties.homogeneous_time         = 0;
new_ids_summary.time                                    = summary_time;
new_ids_summary.ids_properties.comment                  = summary_comment;
new_ids_summary.ids_properties.version_put.access_layer = summary_al_version;
new_ids_summary.global_quantities.ip.value              = summary_ip_value;

%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                               saving data entry                              ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝

ids_put(ctx, 'summary', new_ids_summary);

%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                              closing data entry                              ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝

imas_close(ctx);
