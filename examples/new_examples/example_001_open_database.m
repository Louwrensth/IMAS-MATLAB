%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                            create_db_entry_legacy                            ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝
% This example focuses on creating DBEntry using legacy mode method

user             = getenv('USER');
db_name          = 'test';
pulse            = 1;
run              = 10;
dd_major_version = '3';
backend_id       = 13;

%     backend_id: ID of the backend to use. Available options:
%           - 11: :ref:`ASCII backend`
%           - 12: :ref:`MDSplus backend`
%           - 13: :ref:`HDF5 backend`
%           - 14: :ref:`Memory backend`
%           - 15: :ref:`UDA backend`

% create data entry object (using legacy method, deprecated from AL5)
% this time we are creating completly new entry

ctx = imas_create_env(db_name, pulse, run, 0, 0, user, db_name, dd_major_version);

% to open existing entry use imas_open_env (name, shot, run, user, tokamak, dd_major_version)

% You can access IDSes in here - take a look at sample code dealing with IDSes for details

imas_close(ctx);

%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                            open_db_entry_uri                                 ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝
%  This example focuses on opening DBEntry using URI 

user             = getenv('USER');
db_name          = 'test';
pulse            = '1';
run              = '10';
dd_major_version = '3';
backend          = 'hdf5';
mode             = 43;

%   mode:   Low level IMAS pulse file access mode. Available options:
%
%           - 40: ``OPEN_PULSE`` (default).
%             Opens the access to the data only if the Data Entry exists,
%             returns error otherwise.
%           - 41: ``FORCE_OPEN_PULSE``.
%             Opens access to the data, creates the Data Entry if it does not
%             exists yet.
%           - 42: ``CREATE_PULSE``.
%             Creates a new empty Data Entry (returns error if Data Entry
%             already exists) and opens it at the same time.
%           - 43: ``FORCE_CREATE_PULSE``.
%             Creates an empty Data Entry (overwrites if Data Entry already
%             exists) and opens it at the same time.

uri = strcat('imas:',backend,'?user=',user,';shot=',pulse,';run=',run,';database=',db_name,';version=',dd_major_version);

% Available backends are:
%           - ascii - only for debugging purposes
%           - mdsplus
%           - hdf5
%           - memory - data is lost after entry is closed
%           - uda

ctx = imas_open(uri, mode);

% You can access IDSes in here - take a look at sample code dealing with IDSes for details

imas_close(ctx);

%    ╔══════════════════════════════════════════════════════════════════════════════╗
%    ║                            create_db_entry_uri_with_paths                    ║
%    ╚══════════════════════════════════════════════════════════════════════════════╝
% This example focuses on opening DBEntry using explicit path

mode        = 43;

%   mode:   Low level IMAS pulse file access mode. Available options:
%
%           - 40: ``OPEN_PULSE`` (default).
%             Opens the access to the data only if the Data Entry exists,
%             returns error otherwise.
%           - 41: ``FORCE_OPEN_PULSE``.
%             Opens access to the data, creates the Data Entry if it does not
%             exists yet.
%           - 42: ``CREATE_PULSE``.
%             Creates a new empty Data Entry (returns error if Data Entry
%             already exists) and opens it at the same time.
%           - 43: ``FORCE_CREATE_PULSE``.
%             Creates an empty Data Entry (overwrites if Data Entry already
%             exists) and opens it at the same time.

status = imas_open('imas:mdsplus?path=./testdb_mdsplus',mode);
% ls testdb_mdsplus
% -> ids_001.characteristics  ids_001.datafile  ids_001.tree
% Structure of this directory does not depends on entry content. All IDS data are stored in printed files

status = imas_open('imas:hdf5?path=./testdb_hdf5',mode);
% ls ./testdb_hdf5 
% -> master.h5
% Structure of this directory depends on entry content. Every IDS with data will be stored in <ids_name>.h5 file

status = imas_open('imas:ascii?path=./testdb_ascii',mode);
% ls ./testdb_ascii
% -> {empty}
% Structure of this directory depends on entry content. Every IDS with data will be stored in <ids_name>.ids file
