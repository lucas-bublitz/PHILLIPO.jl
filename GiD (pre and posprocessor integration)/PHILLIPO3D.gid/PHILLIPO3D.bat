del %2\%1.post.res
del C:\DEV\PHILLIPO\src\output.post.res
copy %2\%1.dat C:\DEV\PHILLIPO\src\input.json
echo CHAMANDO PHILLIPO...
julia C:\DEV\PHILLIPO\src\phillipo_main.jl 2> %1.log >> %1.log 
copy C:\DEV\PHILLIPO\src\output.post.res %2\%1.post.res
notepad %1.log