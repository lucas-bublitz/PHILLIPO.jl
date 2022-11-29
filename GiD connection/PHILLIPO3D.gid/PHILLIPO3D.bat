
set julia="C:\Program Files\Julia-1.8.3\bin\julia.exe"

del %1.post.res
del %1.log
call julia %3\link.jl "%1.dat" "%1.post.res" >> %1.log 2>> %1.log 
notepad %1.log