module CmdStan
  module Utils
    private

    def run_command(*args)
      # use popen3 since it does escaping (like system)
      Open3.popen3(*args) do |i, o, e, t|
        if t.value.exitstatus != 0
          $stderr.puts o.read
          $stderr.puts e.read
          raise Error, "Command failed"
        end
      end
    end
  end
end
