@ECHO ON
del %2\%1.flavia.res
del C:\DEV\TCC\phillipo\output.flavia.res
copy %2\%1.dat C:\DEV\TCC\phillipo\input.dat
C:\Users\lucas\AppData\Local\Programs\Julia-1.7.3\bin\julia.exe C:\DEV\TCC\phillipo\phillipo_main.jl
copy C:\DEV\TCC\phillipo\output.favia.res %2\%1.flavia.res
