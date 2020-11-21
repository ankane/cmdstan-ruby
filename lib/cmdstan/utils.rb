module CmdStan
  module Utils
    private

    def run_command(*args)
      env = {}
      unless mac?
        # add tbb to path
        key = windows? ? "PATH" : "LD_LIBRARY_PATH"
        tbblib = ENV["STAN_TBB"] || File.join(CmdStan.path, "stan", "lib", "stan_math", "lib", "tbb")
        env[key] = "#{tbblib};#{ENV[key]}"
      end

      # use an open3 method since it does escaping (like system)
      # use capture2e so we don't need to worry about deadlocks
      output, status = Open3.capture2e(env, *args)
      if status.exitstatus != 0
        $stderr.puts output
        raise Error, "Command failed"
      end
    end

    def make_command
      windows? ? "mingw32-make" : "make"
    end

    def extension
      windows? ? ".exe" : ""
    end

    def mac?
      RbConfig::CONFIG["host_os"] =~ /darwin/i
    end

    def windows?
      Gem.win_platform?
    end
  end
end
