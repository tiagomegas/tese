#
#	Logger shell script
#
#	Upon launching, will replace it's own execution with  
#	the execution of the shell command passed to it as a parameter.
#	It will redirect the command's output (STDOUT and STDERR) to
#	a file located in logs/, with name <PID>.log, where <PID> stands
#	for that process's id.
# 
# 

#!/bin/bash
exec $@ &> logs/$$.log
