require 'pry'

class SyscallMemorySeparator
  def self.setup_separator(included_paths, platform_specs)
    `rm -f /tmp/syscall_mem_separator/null`
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

  def self.initialize_platform_specifications(platform_specs)
    @syscall_tracking_lib = platform_specs.syscall_tracking_lib
    @arguments = platform_specs.arguments
    @syscalls = platform_specs.syscalls
  end

  def self.dummy_write_syscall_for_delimitation(txt)
    File.open('/tmp/syscall_mem_separator/null', 'w') do |f|
      f.write(txt)
    end
  end

  def self.start_tracking_process
    fork do
      `#{@syscall_tracking_lib} #{@arguments}`
    end
  end
end

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
