program run_perf_f90

  use ids_schemas
  use ids_routines

  character(len = 132) :: IDSname = 'magnetics'
  type (ids_magnetics) :: ids
  integer :: idx
  integer :: shot
  integer :: run
  character(len = 132) :: user
  character(len = 132) :: tokamak
  character(len = 132) :: dataversion

  integer :: status
  integer :: run_new
  integer :: ii
  integer :: count_s, count_rate, count_max
  integer :: count_e
  real :: mean

  call getenv('USER',user)
  tokamak = 'test'
  dataversion = '3'

  shot = 9999;
  
  do run = 1,3

     ! ######################################################
     !                          GET
     ! ######################################################
     call ual_begin_pulse_action(MDSPLUS_BACKEND, shot, run, user, tokamak, dataversion, idx); 
     if (idx < 0) then
        call exit(idx)
     end if

     call ual_open_pulse(idx, OPEN_PULSE, '', status);
     if (status < 0) then
        call exit(status)
     end if

     do ii = 1,2
        call ids_get(idx,IDSname,ids)
     end do

     mean = 0
     do ii = 1,8
        call system_clock(count_s,count_rate,count_max)
        call ids_get(idx,IDSname,ids)
        call system_clock(count_e,count_rate,count_max)
        mean = mean + real(count_e - count_s)/real(count_rate)*1000/8
     end do
     write (*,'(A,A,A,i4,A,i4,A,f12.3)') 'Get ',trim(IDSname),' [run = ',run,', ntime = ',size(ids%time),'] Mean time [ms]:', mean

     call ual_close_pulse(idx, CLOSE_PULSE, '', status)
     if (status < 0) then
        call exit(status)
     end if

     call ual_end_action(idx, status); 
     if (status < 0) then
        call exit(status)
     end if

     ! ######################################################
     !                          PUT
     ! ######################################################
     run_new = run + 9800;
     call ual_begin_pulse_action(MDSPLUS_BACKEND, shot, run_new, user, tokamak, dataversion, idx); 
     if (idx < 0) then
        call exit(idx)
     end if

     call ual_open_pulse(idx, CREATE_PULSE, '', status);
     if (status < 0) then
        call exit(status)
     end if

     do ii = 1,2
        call ids_put(idx,IDSname,ids)
     end do

     mean = 0
     do ii = 1,8
        call system_clock(count_s,count_rate,count_max)
        call ids_put(idx,IDSname,ids)
        call system_clock(count_e,count_rate,count_max)
        mean = mean + real(count_e - count_s)/real(count_rate)*1000/8
     end do
     write (*,'(A,A,A,i4,A,i4,A,f12.3)') 'Put ',trim(IDSname),' [run = ',run_new,', ntime = ',size(ids%time),'] Mean time [ms]:', mean

     call ual_close_pulse(idx, CLOSE_PULSE, '', status)
     if (status < 0) then
        call exit(status)
     end if

     call ual_end_action(idx, status); 
     if (status < 0) then
        call exit(status)
     end if

  end do

end program run_perf_f90
