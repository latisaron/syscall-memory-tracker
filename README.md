If you want to test the above, for now, I'd recommend working on a Linux environment, using strace.

Open up an irb, copy the code, instantiate the class, and start it.

Write some methods and see the logs.

TODO list:
- only output relevant memory-related logs from the trace programs.
- see what happens in the case of forked processes, this should also be forked, and it should generate a new file altogether, based on the process ID.
- process the outcoming data from the trace program into a tree with the number of malloc calls.
