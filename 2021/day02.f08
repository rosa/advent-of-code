program day02AoC

! --- Day 2: Dive! ---
   implicit none

   integer :: value, horizontal, depth, aim
   character(len=32) :: filename
   character(len=8)  :: instruction

   value = 0
   horizontal = 0
   depth = 0
   aim = 0

   call get_command_argument(1, filename)
   open (unit=42,file=filename)

18 read (42,*,end=30) instruction, value

   if (instruction == "forward") then
      horizontal = horizontal + value
      depth = depth + value*aim
   else if (instruction == "up") then
      aim = aim - value
   else if (instruction == "down") then
      aim = aim + value
   end if
   go to 18

30 close(42)
   print *, horizontal * aim
   print *, horizontal * depth

end program day02AoC


! gfortran day02.f08 -o day02
! ./day02 inputs/input02.txt
!      1714680
!   1963088820
