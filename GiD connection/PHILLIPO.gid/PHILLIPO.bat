del %1.post.res
del %1.log
call julia -t auto %3\link.jl "%1.dat" "%1.post.res" >> %1.log 2>> %1.log 
notepad %1.log