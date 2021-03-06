module parquet_SDE

  use global_parameter
  use math_mod
  use parquet_ini
  use parquet_util
  use parquet_kernel
  use parquet_formfactors
  use parquet_equation
  

  !$use omp_lib

  implicit none


  integer, allocatable :: pickNu_range(:)
  integer, allocatable :: pickNu_K_range1(:)
  integer, allocatable :: pickNu_K_range2(:)

  private

  public :: calc_SDE

contains

  subroutine calc_SDE(ite, Grt)

    integer, intent(in)     :: ite
    !real space & time green's function
    complex(dp), intent(in) :: Grt(Nx * Ngrain, Ny * Ngrain, Nf)

    !holds intermediate result in loops
    complex(dp) sig_inter

    !arguments for vertices and green's functions
    integer :: l3
    !loop indices
    integer :: idxK, idxQ
    !loop variables for IBZ
    integer :: kx, ky, k_0
    integer :: idxL3, idxL3_mnu
    !maps
    type(Indxmap) mapK, mapQ, mapKQ, mapKmQ, map_mK, mapQmK
    type(Indxmap_L) mapL3, mapL3_mnu

    !IBZ stuff
    !loop variable for symmetries
    integer :: sym
    !symmetriezed q-map
    type(Indxmap) mapQ_sym 
    !for getting the whole BZ from IBZ
    logical, dimension(8) :: symmList

    !chi-like product of green's functions needed in l-space schwinger dyson
    !chi-functions in enlarged frequency box
    complex(dp), dimension(:, :), allocatable :: Chi_aux_ph
    complex(dp), dimension(:, :), allocatable :: Chi_aux_pp

    !Sigma_V - sigma calculated on one node - will the be reduced
    !Sigma Reduced - memory adress to hold data from mpi call
    complex(dp), dimension(:), allocatable :: Sigma_V, Sigma_Reduced

    !intermediate result - to be summed with last Green's function
    complex(dp), dimension(:), allocatable :: LChi(:, :)
    complex(dp), dimension(:), allocatable :: PhChi(:, :)
    !complex(dp), dimension(:), allocatable :: PhbarChi(:, :)
    complex(dp), dimension(:), allocatable :: PPChi(:, :)

    ! --- for calc with F ---
    !complex(dp), dimension(:), allocatable :: FphChi(:, :)
    !complex(dp), dimension(:), allocatable :: FppChi(:, :)
    ! ---

    complex(dp) :: Gkq, Gkmq, Gqmk
    !second order contribution in Schwinger dyson equation caculated via FT
    complex(dp), allocatable :: order_2nd(:)

    if (.NOT. allocated(Sigma_V)) allocate (Sigma_V(2 * Nred))

    if (.NOT. allocated(Chi_aux_ph)) allocate (Chi_aux_ph(Nl * (2 * f_range + 1) * Nf, Nb))
    if (.NOT. allocated(Chi_aux_pp)) allocate (Chi_aux_pp(Nl * (2 * f_range + 1) * Nf, Nb))
    if (.NOT. allocated(order_2nd)) allocate(order_2nd(Nx * Ny * Nf))


    if(.not. allocated(LChi)) allocate (LChi(Nz, Nb))
    if(.not. allocated(PhChi)) allocate (PhChi(Nz, Nb))
    if(.not. allocated(PPChi)) allocate (PPChi(Nz, Nb))

    ! --- for calc with F ---
    !if(.not. allocated(FphChi)) allocate (FphChi(Nz, Nb))
    !if(.not. allocated(FppChi)) allocate (FppChi(Nz, Nb))
    ! ---

    !fill array for asymptotics treatment
    call fillpickNu_range()

    !caculate auxillary chis that appear in l-space schwinger dyson
    call calc_chi_aux(chi_aux_ph, chi_aux_pp)

    !calculate intermediate result - Lambda-contribution
    call calc_LChi(chi_aux_ph, LChi)
    call calc_PhChi(chi_aux_ph, PhChi)
    call calc_PPChi(chi_aux_pp, PPChi)

    ! --- for calc with F ---
    !call calc_FphChi(chi_aux_ph, FphChi)
    !call calc_FppChi(chi_aux_pp, FppChi)
    ! ---

    Sigma_V = (0.0d0, 0.0d0)

    !!!$omp parallel private(map_k, sig_inter, map_q, map_q_sym, map_kq, map_qmk, map_kmq, map_mk, Gkq, Gkmq, Gqmk, symm_list, map_l4, map_l3, idx_l4, idx_l3, map_l3_mnu, idx_l3_mnu, idx_k, sig_U, sig_ph, sig_pb, sig_pp)
    
    !!!$omp do collapse(2)
    do k_0 = 1, Nf
    do kx = 1, Nx_IBZ
    do ky = 1, kx

      mapK = indxmap(kx, ky, k_0)

      call index_minusF(mapK, map_mK) !for use later

      sig_inter = 0.0d0

      do idxQ = 1, Nb
        mapQ = Index_Bosonic_IBZ(id * Nb + idxQ) !correct map on any node


        !get all symmetries that are needed to fill whole BZ
        call list_symmetries(mapQ, symmList)                  

        !loop over symmetries
        do sym = 1, Ns

          !leave out the ones that we already took
          if(.not. symmList(sym)) cycle
          !create symmetrized q2 to index formfactors
          call symmetry_operation(sym, mapQ, mapQ_sym)

          !calculation of green's functions
  
          call Index_FaddB(mapK, mapQ_sym, mapKQ)
          Gkq = get_green(mapKQ)
  
          call index_FaddB(map_mK, mapQ_sym, mapQmK)
          Gqmk = get_green(mapQmK)
      
          call index_minusF(mapQmK, mapKmQ)
          Gkmq = get_green(mapKmQ)


          DO l3 = 1, Nl
            mapL3 = Indxmap_L(L3, mapK%iw)
            idxL3 = List_Index_L(mapL3)

            sig_inter = sig_inter + &
                        Gkq * FF_inv(sym, kx, ky, l3) * &
                        LChi(idxL3, idxQ)

            sig_inter = sig_inter + &
                        Gkq * FF_inv(sym, kx, ky, l3) * &
                        PhChi(idxL3, idxQ)

            sig_inter = sig_inter + &
                        Gqmk * FF_inv(sym, kx, ky, l3) * &
                        PPChi(idxL3, idxQ)
 
            ! --- for calc with F ---
            !sig_inter = sig_inter + &
            !            Gkq * FF_inv(sym, kx, ky, l3) * &
            !            FphChi(idxL3, idxQ)
            !sig_inter = sig_inter + &
            !            Gqmk * FF_inv(sym, kx, ky, l3) * &
            !            FppChi(idxL3, idxQ)
            ! ---
 
            !now add TR part
            if (mapQ%iw == 1) cycle
  
            !take negative nu (via copy-pasted rule)
            !negation of l3 is taken care of by signs
            mapL3_mnu = Indxmap_L(mapL3%il, -mapL3%iw + Nf + 1)
            idxL3_mnu = List_Index_L(mapL3_mnu)
 
            sig_inter = sig_inter + &
                        Gkmq * FF_inv(sym, kx, ky, l3) * &
                        signs(l3) * &
                        conjg(LChi(idxL3_mnu, idxQ))

            sig_inter = sig_inter + &
                        Gkmq * FF_inv(sym, kx, ky, l3) * &
                        signs(l3) * &
                        conjg(PhChi(idxL3_mnu, idxQ))

            sig_inter = sig_inter + &
                        conjg(Gkq) * FF_inv(sym, kx, ky, l3) * &
                        signs(l3) * &
                        conjg(PPChi(idxL3_mnu, idxQ))

            ! --- for calc with F ---
            !sig_inter = sig_inter + &
            !            Gkmq * FF_inv(sym, kx, ky, l3) * &
            !            signs(l3) * &
            !            conjg(FphChi(idxL3_mnu, idxQ))
            !sig_inter = sig_inter + &
            !            conjg(Gkq) * FF_inv(sym, kx, ky, l3) * &
            !            signs(l3) * &
            !            conjg(FppChi(idxL3_mnu, idxQ))
            ! ---

  
          end do !l3
        end do !sym
      end do !q

      !index corresponding to k-index -> only needed at this place
      idxK = ( (((kx - 1) * kx))/2 + ky - 1 ) * Nf + k_0

      !add intermediate result to to be reduced sigma_V
      Sigma_V(idxK) = Sigma_V(idxK) - xU/beta/beta/Nc/Nc/2.0d0 * sig_inter

    !outer fermionic loop - k-argument
    end do
    end do
    end do
    !!$omp end do
    !!$omp end parallel


    !sum up sigmas from all tasks
    IF (.NOT. ALLOCATED(Sigma_Reduced)) ALLOCATE (Sigma_Reduced(Nred * 2))

    Sigma_Reduced = (0.0d0, 0.0d0)

    !reduce only IBZ part
    call MPI_AllReduce(Sigma_V, Sigma_Reduced, Nred * 2, MPI_DOUBLE_COMPLEX, MPI_SUM, MPI_COMM_WORLD, rc)

    !now add to sigma
    Sigma = 0.0d0

    !now symmetrize sigma - calculate rest of BZ
    call symmetrize_array(Nf, Sigma_Reduced, Sigma) 

    if(use_U2) then
    
      !caculate 2nd order diagram more accurately via FFT
      call calc_order_2nd(Grt, order_2nd)
  
      !add 2nd order explicitly ...
      Sigma = Sigma + order_2nd

    endif !use_U2

    Deallocate (Sigma_Reduced)


  end subroutine calc_SDE

  ! ---
  ! function to calculate the 2nd order contribution to the schwinger-dyson
  ! equation
  ! ---
  subroutine calc_order_2nd(Grt, order_2nd)

    !real space & time green's function
    complex(dp), intent(in) :: Grt(Nx * Ngrain, Ny * Ngrain, Nf)
    !return value
    complex(dp), dimension(Nx * Ny * Nf), intent(out) :: order_2nd

    !loop variables
    integer :: kx, ky, kxm, kym, kx_c, ky_c, iTau, nu
    
    !index
    integer :: idx_k, idx_mk

    !holds product of 3 green's functions
    complex(dp), allocatable :: GGG(:, :, :)

    !for fitting
    real(dp) :: FD1, FD2

    !string needed for determination of operation - probably
    character(len=30) :: Mtype

    !temporary to hold fourier-transfor to w-space
    complex(dp), allocatable :: ret_temp(:)

    order_2nd = 0.0d0

    if (.NOT. allocated(GGG)) allocate(GGG(Nx * Ngrain, Ny * Ngrain, Nf))
    if (.not. allocated(ret_temp)) allocate(ret_temp(Nf/2))
    ret_temp = 0.0d0
    GGG = 0.0d0
    MType = 'Fermionic'

    do iTau = 1, Nf
      do ky = 1, Ny * Ngrain
        kym = merge(1, Ny * Ngrain - ky + 2, ky == 1)
        do kx = 1, Nx * Ngrain
          kxm = merge(1, Nx * Ngrain - kx + 2, kx == 1)
          !idea : convolution becomes product in FT-space
          GGG(kx, ky, iTau) = Grt(kx, ky, iTau)**2 * Grt(kxm, kym, Nf - iTau + 1) * xU * xU
        end do !kx
      end do !ky
    
      ! now change it to k-t space by using FFT - first momentum arguments
      call fftb2d(Nx * Ngrain, Ny * Ngrain, GGG(1:Nx * Ngrain, 1:Ny * Ngrain, iTau), C_wave_x, C_wave_y)
    end do !iTau
  
    do kx = 1, Nx
      !argument in finer grid
      kx_c = (kx - 1) * Ngrain + 1
      do ky = 1, Ny
        !argument in finer grid
        ky_c = (ky - 1) * Ngrain + 1

        !fit the time component with polynomials
        call FDfit(Nf, dble(GGG(kx_c, ky_c, 1:Nf)), beta/(Nf - 1), FD1, FD2)

        !perform trafo
        call nfourier(MType, Nf - 1, Nf/2, FD1, FD2, dble(GGG(kx_c, ky_c, 1:Nf)), ret_temp)

        !actually fill output array
        do nu = 1, Nf/2
          idx_k  = ((kx - 1) * Ny + ky - 1) * Nf + nu
          idx_mk = ((kx - 1) * Ny + ky - 1) * Nf + Nf - nu + 1
          order_2nd(idx_k)  = order_2nd(idx_k) + conjg(ret_temp(Nf/2 + 1 - nu))
          order_2nd(idx_mk) = order_2nd(idx_mk) + ret_temp(Nf/2 + 1 - nu)
        end do !nu

      end do !ky
    end do !kx

    deallocate(GGG)
    deallocate(ret_temp)

  end subroutine calc_order_2nd



    !-------------------------------------------------------------------

  subroutine calc_chi_aux(Chi_aux_ph, Chi_aux_pp)

    !chis in enlarged box
    complex(dp), intent(out) :: Chi_aux_ph((2 * f_range + 1) * Nf * Nl, Nb)
    complex(dp), intent(out) :: Chi_aux_pp((2 * f_range + 1) * Nf * Nl, Nb)

    !indices in loop
    integer :: idx_q, idx_l4
    !k-momenta - have same frequency as l4
    integer :: kx, ky
    !index maps
    type(Indxmap) map_q, map_k, map_mk, map_kpq, map_qmk
    type(Indxmap_L) map_l4
    !Green's function for a particular argument
    complex(dp) Gk, Gqmk, Gkpq

    !variables for extended frequency loop
    integer :: l4_0, l4 !freq and l-arg

    !loop variables for coarse graining
    integer :: kx_grain, ky_grain

    Chi_aux_ph = 0.0d0
    Chi_aux_pp = 0.0d0

    !$omp parallel private(map_q, map_l4, idx_l4, map_k, map_kpq, map_mk, map_qmk, Gk, Gkpq, Gqmk)

    !$omp do collapse(3)
    DO idx_q = 1, Nb
      !loop over larger frequency box
      DO l4 = 1, Nl
        DO l4_0 = -f_range * Nf + 1, (f_range + 1) * Nf

          map_q = Index_Bosonic_IBZ(id * Nb + idx_q) !correct map on any node
          map_l4 = Indxmap_L(l4, l4_0)
    
          DO kx = 1, Nx
            DO ky = 1, Ny

              
              !set index for array dereferencing
              ! addition at the end ensures that one starts at 1
              idx_l4 = (l4 - 1) * (2 * f_range + 1) * Nf + f_range * Nf + l4_0

              map_k = Indxmap(kx, ky, map_l4%iw)
              call Index_FaddB(map_k, map_q, map_kpq)
!
              !caculate chi_aux_ph

              do kx_grain = 1, Ngrain
                do ky_grain = 1, Ngrain
              
                  Gk = get_green_coarse(kx_grain, ky_grain, map_k)
                  Gkpq = get_green_coarse(kx_grain, ky_grain, map_kpq)
      
                  Chi_aux_ph(idx_l4, idx_q) = Chi_aux_ph(idx_l4, idx_q) + &
                                                Gk * Gkpq * &
                                                FF(map_k%ix, map_k%iy, map_l4%il) * &
                                                1.0d0/(Ngrain * Ngrain)
  
                end do !kx_grain
              end do!ky_grain

              !calculate chi_aux_pp
  
              call index_minusF(map_k, map_mk) 
              call index_FaddB(map_mk, map_q, map_qmk) 
              
              do kx_grain = 1, Ngrain
                do ky_grain = 1, Ngrain
              
                  Gk = get_green_coarse(kx_grain, ky_grain, map_k)
                  Gqmk = get_green_coarse(Ngrain - kx_grain + 1, Ngrain - ky_grain + 1, map_qmk)
      
                  Chi_aux_pp(idx_l4, idx_q) = Chi_aux_pp(idx_l4, idx_q) + &
                                                Gk * Gqmk * &
                                                FF(map_k%ix, map_k%iy, map_l4%il) * &
                                                1.0d0/(Ngrain * Ngrain)
  
                end do !kx_grain
              end do!ky_grain

            END DO!kx
          END DO!ky
        END DO !l4_0
      END DO!l4
    END DO!q
    !$omp end do

    !$omp end parallel

  end subroutine calc_chi_aux



  subroutine calc_LChi(chi_aux_ph, LChi)

    complex(dp), dimension((2 * f_range + 1) * Nf * Nl, Nb), intent(in) :: chi_aux_ph
    complex(dp), dimension(NZ, Nb), intent(out) :: LChi

    !loop variables
    integer :: idxL3, idxL4, idxQ
    integer :: l4, l4_0
    type(Indxmap) :: mapQ

    LChi = 0.0d0

    do idxQ = 1, Nb
      mapQ = index_bosonic_IBZ(id * Nb + idxQ)
      do idxL3 = 1, Nz
        do l4 = 1, Nl
          do l4_0 = -f_range * Nf + 1, (f_range + 1) * Nf

            idxL4 = (l4 - 1) * (2 * f_range + 1) * Nf + f_range * Nf + l4_0

            !only L = 0 contribution in this case
            if(idxL3 .LE. Nf .and. l4 == 1) then
              if(l4_0 < Nf + 1 .and. l4_0 > 0) then

                LChi(idxL3, idxQ) = LChi(idxL3, idxQ) + &
                    L_d(idxL3, l4_0, mapQ%iw) * &
                    1.0d0/(FF(1, 1, 1) * FF(1, 1, 1)) * &
                    Chi_aux_PH(idxL4, idxQ)

                LChi(idxL3, idxQ) = LChi(idxL3, idxQ) - &
                    L_m(idxL3, l4_0, mapQ%iw) * &
                    1.0d0/(FF(1, 1, 1) * FF(1, 1, 1)) * &
                    Chi_aux_PH(idxL4, idxQ)

                if(use_U2) then

                  LChi(idxL3, idxQ) = LChi(idxL3, idxQ) - &
                      2.0d0 * xU * &
                      1.0d0/(FF(1, 1, 1) * FF(1, 1, 1)) * &
                      Chi_aux_PH(idxL4, idxQ)
                end if !use_U2

              else

                if(.not. use_U2) then
                  LChi(idxL3, idxQ) = LChi(idxL3, idxQ) + &
                      2.0d0 * xU * 1.0d0/(FF(1, 1, 1) * FF(1, 1, 1)) * &
                      Chi_aux_PH(idxL4, idxQ)
                end if !.not. use_U2

              end if !l4_0 inside box
            end if !L = 0

          end do !l4_0
        end do !l4
      end do !idxL3
    end do !idxQ

  end subroutine calc_LChi



  subroutine calc_PhChi(chi_aux_ph, PhChi)

    complex(dp), dimension((2 * f_range + 1) * Nf * Nl, Nb), intent(in) :: chi_aux_ph
    complex(dp), dimension(NZ, Nb), intent(out) :: PhChi

    !loop variables
    integer :: idxL3, idxL4, idxQ
    integer :: l4, l4_0

    PhChi = 0.0d0

    do idxQ = 1, Nb
      do idxL3 = 1, Nz
        do l4 = 1, Nl
          do l4_0 = -f_range * Nf + 1, (f_range + 1) * Nf

            ! --- for calc with F ---
            !if(l4_0 < Nf + 1 .and. l4_0 > 0) cycle
            ! ---
  
            idxL4 = (l4 - 1) * (2 * f_range + 1) * Nf + f_range * Nf + l4_0

            PhChi(idxL3, idxQ) = PhChi(idxL3, idxQ) + &
                G_d_LL(idxL3, (l4 - 1) * Nf + pickNu_range(l4_0 + f_range * Nf), idxQ) * &
                Chi_aux_PH(idxL4, idxQ)

            PhChi(idxL3, idxQ) = PhChi(idxL3, idxQ) - 3.0d0 * &
                G_m_LL(idxL3, (l4 - 1) * Nf + pickNu_range(l4_0 + f_range * Nf), idxQ) * &
                Chi_aux_PH(idxL4, idxQ)

          end do !l4_0
        end do !l4
      end do !idxL3
    end do !idxQ

  end subroutine calc_PhChi


  subroutine calc_PPChi(chi_aux_pp, PPChi)

    complex(dp), dimension((2 * f_range + 1) * Nf * Nl, Nb), intent(in) :: chi_aux_pp
    complex(dp), dimension(NZ, Nb), intent(out) :: PPChi

    !loop variables
    integer :: idxL3, idxL4, idxQ
    integer :: l4, l4_0

    PPChi = 0.0d0

    do idxQ = 1, Nb
      do idxL3 = 1, Nz
        do l4 = 1, Nl
          do l4_0 = -f_range * Nf + 1, (f_range + 1) * Nf

            ! --- for calc with F ---
            !if(l4_0 < Nf + 1 .and. l4_0 > 0) cycle
            ! ---

            idxL4 = (l4 - 1) * (2 * f_range + 1) * Nf + f_range * Nf + l4_0

            PPChi(idxL3, idxQ) = PPChi(idxL3, idxQ) + &
                G_s_LL(idxL3, (l4 - 1) * Nf + pickNu_range(l4_0 + f_range * Nf), idxQ) * &
                Chi_aux_PP(idxL4, idxQ)

            PPChi(idxL3, idxQ) = PPChi(idxL3, idxQ) + &
                G_t_LL(idxL3, (l4 - 1) * Nf + pickNu_range(l4_0 + f_range * Nf), idxQ) * &
                Chi_aux_PP(idxL4, idxQ)

          end do !l4_0
        end do !l4
      end do !idxL3
    end do !idxQ

  end subroutine calc_PPChi



  ! --- for calc with F ---
  !subroutine calc_FphChi(chi_aux_ph, FChi)

  !  complex(dp), dimension((2 * f_range + 1) * Nf * Nl, Nb), intent(in) :: chi_aux_ph
  !  complex(dp), dimension(NZ, Nb), intent(out) :: FChi

  !  !loop variables
  !  integer :: idxL3, idxL4, idxQ
  !  integer :: idx_smallbox

  !  FChi = 0.0d0

  !  do idxQ = 1, Nb
  !    do idxL3 = 1, Nz
  !      do idxL4 = 1, Nz

  !        idx_smallbox = (mod(idxL4 - 1, Nl)) * Nf + int((idxL4 - 1) / Nl) + f_range * Nf + 1

  !        FChi(idxL3, idxQ) = FChi(idxL3, idxQ) + 1.0d0/3.0d0 * &
  !            F_d_LL(idxL3, idxL4, idxQ) * &
  !            Chi_aux_PH(idx_smallbox, idxQ)

  !        FChi(idxL3, idxQ) = FChi(idxL3, idxQ) - 1.0d0 * &
  !            F_m_LL(idxL3, idxL4, idxQ) * &
  !            Chi_aux_PH(idx_smallbox, idxQ)

  !      end do !idxL4
  !    end do !idxL3
  !  end do !idxQ

  !end subroutine calc_FphChi
  !! ---


  !! --- for calc with F ---
  !subroutine calc_FppChi(chi_aux_pp, FChi)

  !  complex(dp), dimension((2 * f_range + 1) * Nf * Nl, Nb), intent(in) :: chi_aux_pp
  !  complex(dp), dimension(NZ, Nb), intent(out) :: FChi

  !  !loop variables
  !  integer :: idxL3, idxL4, idxQ
  !  integer :: idx_smallbox

  !  FChi = 0.0d0

  !  do idxQ = 1, Nb
  !    do idxL3 = 1, Nz
  !      do idxL4 = 1, Nz

  !        idx_smallbox = (mod(idxL4 - 1, Nl)) * Nf + int((idxL4 - 1) / Nl) + f_range * Nf + 1


  !        FChi(idxL3, idxQ) = FChi(idxL3, idxQ) + &
  !            F_s_LL(idxL3, idxL4, idxQ) * 1.0d0/3.0d0 * &
  !            Chi_aux_PP(idx_smallbox, idxQ)

  !        FChi(idxL3, idxQ) = FChi(idxL3, idxQ) + &
  !            F_t_LL(idxL3, idxL4, idxQ) * 1.0d0/3.0d0 * &
  !            Chi_aux_PP(idx_smallbox, idxQ)


  !      end do !idxL4
  !    end do !idxL3
  !  end do !idxQ

  !end subroutine calc_FppChi
  !! ---



  subroutine fillpickNu_range()

    integer :: nu

    !take Nf + 2*Nf on both sides - should be enough to cover bo - should be
    !enough to cover boxx
    if(.not. allocated(pickNu_range)) allocate(pickNu_range((2 * f_range + 1) * Nf))
    if(.not. allocated(pickNu_K_range1)) allocate(pickNu_K_range1((2 * f_range + 1) * Nf))
    if(.not. allocated(pickNu_K_range2)) allocate(pickNu_K_range2((2 * f_range + 1) * Nf))

    do nu = 1, (2 * f_range + 1) * Nf
  
      if(nu .le. f_range * Nf) then
        pickNu_range(nu) = 1
        pickNu_K_range1(nu) = Nf
        pickNu_K_range2(nu) = 1
      else if(f_range * Nf < nu .and. nu < (f_range + 1) * Nf + 1) then
        pickNu_range(nu) = nu - f_range * Nf
        pickNu_K_range1(nu) = nu - f_range * Nf
        pickNu_K_range2(nu) = nu - f_range * Nf
      else 
        pickNu_range(nu) = Nf
        pickNu_K_range1(nu) = Nf
        pickNu_K_range2(nu) = 1
      end if !nu

    end do !nu
  end subroutine fillpickNu_range




end module parquet_SDE
