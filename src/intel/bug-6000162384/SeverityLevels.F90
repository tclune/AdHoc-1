!------------------------------------------------------------------------------
! NASA/GSFC, CISTO, Code 606, Advanced Software Technology Group
!------------------------------------------------------------------------------
!
!*MODULE: PFL_SeverityLevels_mod
!
!> @brief Specify severity levels used to logging messages.
!
!> @author ASTG staff
!> @date 01 Jan 2015 - Initial Version  
!------------------------------------------------------------------------------
module PFL_SeverityLevels_mod
   use PFL_StringIntegerMap_mod, only: StringIntegerMap => map
   implicit none
   private

   public :: NOTSET
   public :: DEBUG
   public :: INFO
   public :: WARNING
   public :: ERROR
   public :: CRITICAL

   public :: name_to_level

   public :: initialize_severity_levels
   public :: finalize_severity_levels

   enum, bind(c)
      enumerator :: &
           & NOTSET   =  0, &
           & DEBUG    = 10, &
           & INFO     = 20, &
           & WARNING  = 30, &
           & ERROR    = 40, &
           & CRITICAL = 50
   end enum

   ! (Harmless?) Singletons?
   type (StringIntegerMap), save :: name_to_level_

contains

   
   !---------------------------------------------------------------------------  
   ! FUNCTION: 
   ! name_to_level
   !
   ! DESCRIPTION:
   ! Convert a level name to a numeric severity level
   !---------------------------------------------------------------------------
   function name_to_level(name) result(level)
      use PFL_StringIntegerMap_mod, only: mapiterator
      integer :: level
      character(len=*), intent(in) :: name

      type (mapiterator) :: iter

      iter = name_to_level_%find(name)
      if (iter == name_to_level_%end()) then
         level = NOTSET
         call throw('PFL::SeverityLevels::name_to_level - unknown level name. Please use a valid name.')
         return
      end if

      level = iter%value()

   end function name_to_level

   subroutine initialize_severity_levels()
      call name_to_level_%insert('NOTSET', NOTSET)
      call name_to_level_%insert('INFO', INFO)
      call name_to_level_%insert('DEBUG', DEBUG)
      call name_to_level_%insert('WARNING', WARNING)
      call name_to_level_%insert('ERROR', ERROR)
      call name_to_level_%insert('CRITICAL', CRITICAL)

   end subroutine initialize_severity_levels

   subroutine finalize_severity_levels()
      call name_to_level_%clear()
   end subroutine finalize_severity_levels

end module PFL_SeverityLevels_mod
