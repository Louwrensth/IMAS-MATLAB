program run_perf_f90
  
  use ids_schemas
  use ids_routines

  use IDS_names_mod, only : IDS_names, nIDS

  implicit none

  integer :: argc
  character(len = 132), allocatable :: argv(:)
  integer :: length
  integer :: status
  logical :: bool

  integer :: iIDS
  character(len = 132) :: IDSname
  integer :: idxr
  integer :: idxw
  integer :: shot
  integer :: run
  character(len = 132) :: user
  character(len = 132) :: tokamak
  character(len = 132) :: dataversion
  character(STRMAXLEN) :: uri
  type(C_PTR) :: cptr
  integer :: ntime

  integer :: run_new
  integer :: ii
  real    :: timer
  real    :: timew
  real    :: meanr
  real    :: meanw

  call getenv('USER',user)
  tokamak = 'test'
  dataversion = '3'

  shot = 9999;

  argc = command_argument_count()
  if (argc.gt.0) then 
     allocate(argv(argc))
     do ii = 1,argc
        call get_command_argument(ii,argv(ii), length, status)
        call check_IDS_name(argv(ii), bool)
        if (.not.bool) then
           write(*,*) 'ERROR: name ',trim(argv(ii)),' did not match any known IDS'
           call exit(-1)
        end if
     end do
  else
     argc = nIDS
     allocate(argv(nIDS))
     do ii = 1,nIDS
        argv(ii) = IDS_names(ii)
     end do
  end if
  
  do run = 1,3

     ! ######################################################
     !                          GET
     ! ######################################################
     call al_build_uri_from_legacy_parameters(MDSPLUS_BACKEND, shot, run, user, tokamak, dataversion, uri, options, status);

     call al_begin_dataentry_action(uri, OPEN_PULSE, idxr, status);
     if (status < 0) then
        call exit(status)
     end if

     run_new = run + 9800;
     call al_build_uri_from_legacy_parameters(MDSPLUS_BACKEND, shot, run_new, user, tokamak, dataversion, uri, options, status);

     call al_begin_dataentry_action(uri, CREATE_PULSE, idxw, status);
     if (status < 0) then
        call exit(status)
     end if

     do iIDS = 1,argc

        IDSname = argv(iIDS);

        do ii = 1,2
           call test(IDSname,idxr,idxw,timer,timew, ntime)
        end do

        meanr = 0
        meanw = 0
        do ii = 1,8
           call test(IDSname,idxr,idxw,timer,timew, ntime)
           meanr = meanr + timer/8
           meanw = meanw + timew/8
        end do

        write (*,'(A,A25,A,i4,A,i4,A,f12.3)') 'Get ',trim(IDSname),' [run = ',run    ,', ntime = ',ntime,'] Mean time [ms]:', meanr
        write (*,'(A,A25,A,i4,A,i4,A,f12.3)') 'Put ',trim(IDSname),' [run = ',run_new,', ntime = ',ntime,'] Mean time [ms]:', meanw

     end do

     call al_close_pulse(idxr, CLOSE_PULSE, status)
     if (status < 0) then
        call exit(status)
     end if

     call al_end_action(idxr, status); 
     if (status < 0) then
        call exit(status)
     end if

     call al_close_pulse(idxw, CLOSE_PULSE, status)
     if (status < 0) then
        call exit(status)
     end if

     call al_end_action(idxw, status); 
     if (status < 0) then
        call exit(status)
     end if
     
  end do

end program run_perf_f90
