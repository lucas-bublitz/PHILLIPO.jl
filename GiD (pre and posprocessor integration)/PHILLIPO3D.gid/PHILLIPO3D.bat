del %2\%1.flavia.res
del C:\DEV\PHILLIPO\src\output.flavia.res
copy %2\%1.dat C:\DEV\PHILLIPO\src\input.dat
echo CHAMANDO PHILLIPO...
julia C:\DEV\PHILLIPO\src\phillipo_main.jl 2> %1.log
copy C:\DEV\PHILLIPO\src\output.flavia.res %2\%1.flavia.res
