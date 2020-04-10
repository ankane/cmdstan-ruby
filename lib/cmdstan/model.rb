module CmdStan
  class Model
    include Utils

    attr_reader :exe_file, :name, :stan_file

    def initialize(stan_file: nil, exe_file: nil, compile: true)
      # convert to absolute path
      stan_file = File.expand_path(stan_file) if stan_file

      @stan_file = stan_file
      @exe_file = exe_file || stan_file.sub(/.stan\z/, extension)
      @name = File.basename(@exe_file, extension)

      if compile && !exe_file
        self.compile
      end
    end

    def compile
      Dir.chdir(CmdStan.path) do
        run_command make_command, @exe_file
      end
    end

    def code
      File.read(stan_file)
    end

    def sample(data:, chains: nil, seed: nil, inits: nil, warmup_iters: nil, sampling_iters: nil)
      data_file = Tempfile.new(["cmdstan", ".json"])
      data_file.write(data.to_json)
      data_file.close

      chain ||= 4

      output_files = []
      chains.times do |chain|
        output_file = Tempfile.new(["cmdstan", ".csv"])

        args = [@exe_file, "id=#{chain + 1}"]

        # random
        args += ["random", "seed=#{seed.to_i}"] if seed

        # data
        args += ["data", "file=#{data_file.path}"]
        if inits
          init_file = Tempfile.new(["cmdstan", ".json"])
          init_file.write(inits.to_json)
          init_file.close
          args << "init=#{init_file.path}"
        end

        # output
        args += ["output", "file=#{output_file.path}"]

        # method
        args += ["method=sample"]
        args << "num_warmup=#{warmup_iters.to_i}" if warmup_iters
        args << "num_samples=#{sampling_iters.to_i}" if sampling_iters
        args += ["algorithm=hmc", "adapt", "engaged=1"]

        run_command *args

        output_files << output_file
      end

      MCMC.new(output_files)
    end

    def optimize(data:, seed: nil, inits: nil, algorithm: nil, iter: nil)
      data_file = Tempfile.new(["cmdstan", ".json"])
      data_file.write(data.to_json)
      data_file.close

      output_file = Tempfile.new(["cmdstan", ".csv"])
      diagnostic_file = Tempfile.new(["cmdstan", ".csv"])

      args = [@exe_file]

      # random
      args += ["random", "seed=#{seed.to_i}"] if seed

      # data
      args += ["data", "file=#{data_file.path}"]
      if inits
        init_file = Tempfile.new(["cmdstan", ".json"])
        init_file.write(inits.to_json)
        init_file.close
        args << "init=#{init_file.path}"
      end

      # output
      args += ["output", "file=#{output_file.path}", "diagnostic_file=#{diagnostic_file.path}"]

      # method
      args << "method=optimize"
      args << "algorithm=#{algorithm.to_s.downcase}" if algorithm
      args << "iter=#{iter.to_i}" if iter

      run_command *args

      MLE.new(output_file)
    end
  end
end
