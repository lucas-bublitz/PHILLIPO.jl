del %1.post.res
del %1.log
del %1.error.log
call julia -t auto %3\link.jl "%1.dat" "%1.post.res" >> %1.log 2>> %1.error.log 
type %1.error.log >> %1.log
notepad %1.log