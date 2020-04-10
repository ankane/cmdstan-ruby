module CmdStan
  module Utils
    private

    def run_command(*args)
      system *args
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
