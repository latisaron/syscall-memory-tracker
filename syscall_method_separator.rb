require 'pry'

$_internal_R9MDSAK837I_tracking_started = nil
class SyscallMemorySeparator
  `rm -f /tmp/syscall_mem_separator/null`
  def self.setup_separator(included_paths, platform_specs)
    check_args(included_paths, platform_specs)
    initialize_platform_specifications(platform_specs)
    start_tracking_process

    @tp = TracePoint.new(:call, :return) do |tp|
      return unless included_paths.any?{|path| tp.path.include?(path)}

      dummy_write_syscall_for_delimitation(
        if tp.event == :call
          "I-RB-SYSCALL-DELIM : START : #{tp.path} : #{tp.method_id}"
        elsif tp.event == :return
          "I-RB-SYSCALL-DELIM : END : #{tp.path} : #{tp.method_id}"
        end
      )
      end
    end
  end

  def self.start
    raise(StandardError, 'Tracepoint specifics not initialized.') if @tp.nil?
    @tp.enable
  end

private
  def self.check_args(included_paths, platform_specs)
    if included_paths.nil? ||
      !included_paths.is_a?(Array) ||
      !included_paths.all?{|x| x.is_a?(String) && File.directory?(x) && File.exist?(x)}
      raise(StandardError, 'Argument should be an array of absolute path strings.')
    else
      nil
    end

    if platform_specs.is_a?(PlatformSpecifications)
      nil
    else
      raise(StandardError, 'platform_specs should be an instance of PlatformSpecifications.')
    end
  end

  def initialize_platform_specifications(platform_specs)
    @syscall_tracking_lib = platform_specs.syscall_tracking_lib
    @pid_argument = platform_specs.pid_argument
    @syscalls = platform_specs.syscalls
  end

  def dummy_write_syscall_for_delimitation(txt)
    File.open('/tmp/syscall_mem_separator/null', 'w') do |f|
      f.write(txt)
    end
  end

  def start_tracking_process
    `#{@syscall_tracking_lib} #{@pid_argument} #{Process.pid}`
  end
end

class PlatformSpecifications
  DEFAULT_PLATFORM = 'linux'
  private_constant :DEFAULT_PLATFORM
  
  DEFAULT_TRACKING_LIB = 'strace'
  private_constant :DEFAULT_TRACKING_LIB
  
  DEFAULT_SYSCALLS = %w[brk]
  private_constant :DEFAULT_SYSCALLS

  DEFAULT_PID_ARGUMENT = '-p'
  private_constant :DEFAULT_PID_ARGUMENT

  attr_reader :syscall_tracking_lib
  attr_reader :pid_argument
  attr_reader :syscalls

  def initialize(syscall_tracking_lib = DEFAULT_TRACKING_LIB, pid_argument = DEFAULT_PID_ARGUMENT, syscalls = DEFAULT_SYSCALLS)
    @syscall_tracking_lib = syscall_tracking_lib
    @pid_argument = pid_argument
    @syscalls = syscalls
  end
end