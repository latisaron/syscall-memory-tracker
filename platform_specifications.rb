# example for strace used exclusively for mem calls
# PlatformSpecifications.new(arguments: "-o your_preffered-log-location.txt -e trace=brk -p #{Process.pid}")

class PlatformSpecifications  
  DEFAULT_TRACKING_LIB = 'strace'
  private_constant :DEFAULT_TRACKING_LIB
  
  DEFAULT_SYSCALLS = %w[brk]
  private_constant :DEFAULT_SYSCALLS

  DEFAULT_ARGUMENTS = "-p #{Process.pid}"
  private_constant :DEFAULT_ARGUMENTS

  attr_reader :syscall_tracking_lib
  attr_reader :arguments
  attr_reader :syscalls

  def initialize(syscall_tracking_lib: DEFAULT_TRACKING_LIB, arguments: DEFAULT_ARGUMENTS, syscalls: DEFAULT_SYSCALLS)
    @syscall_tracking_lib = syscall_tracking_lib
    @arguments = arguments
    @syscalls = syscalls
  end
end
