module CmdStan
  module Utils
    private

    def run_command(*args)
      env = {}
      if windows?
        # add tbb to path
        tbblib = ENV["STAN_TBB"] || File.join(CmdStan.path, "stan", "lib", "stan_math", "lib", "tbb")
        env["PATH"] = "#{tbblib};#{ENV["PATH"]}"
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

    def windows?
      Gem.win_platform?
    end
  end
end
