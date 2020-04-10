module CmdStan
  module Utils
    private

    def run_command(*args)
      puts "run_command"
      p args
      env = {}
      if windows?
        tbblib = ENV["STAN_TBB"] || File.join(CmdStan.path, "stan", "lib", "stan_math", "lib", "tbb")
        env["PATH"] = "#{tbblib};#{ENV["PATH"]}"
      end
      success = system(env, *args)
      raise Error, "Command failed" unless success
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
