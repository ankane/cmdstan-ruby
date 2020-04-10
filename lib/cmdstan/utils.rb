module CmdStan
  module Utils
    private

    def run_command(*args)
      # use an open3 method since it does escaping (like system)
      # use capture2e so we don't need to worry about deadlocks
      output, status = Open3.capture2e(*args)
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
