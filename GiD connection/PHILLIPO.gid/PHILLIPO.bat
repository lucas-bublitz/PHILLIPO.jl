
set path = C:\DEV\PHILLIPO\src\

del %2\%1.post.res
del %path%output.post.res
copy %2\%1.dat %path%\input.json
echo CHAMANDO PHILLIPO...
julia  %path%\phillipo_main.jl 2> %1.log >> %1.log 
copy %path%\output.post.res %2\%1.post.res
notepad %1.log