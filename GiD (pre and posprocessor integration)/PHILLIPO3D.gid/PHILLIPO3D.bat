del %2\%1.flavia.res
del C:\DEV\PHILLIPO\src\output.flavia.res
copy %2\%1.dat C:\DEV\PHILLIPO\src\input.dat
echo CHAMANDO PHILLIPO...
C:\Users\Skynet\AppData\Local\Programs\Julia-1.7.3\bin\julia.exe C:\DEV\PHILLIPO\src\phillipo_main.jl > %1.log
copy C:\DEV\PHILLIPO\src\output.flavia.res %2\%1.flavia.res
