module CmdStan
  class MCMC
    include Utils

    attr_reader :column_names, :draws

    # private
    # TODO use runset for args
    def initialize(output_files)
      @output_files = output_files
      validate_csv_files
    end

    def sample
      sample = []
      @output_files.each_with_index do |output_file, chain|
        i = 0
        CSV.foreach(output_file.path, skip_lines: /^#/, headers: true) do |row|
          (sample[i] ||= [])[chain] = row.to_h.values.map(&:to_f)
          i += 1
        end
        raise "Bug detected" if i != draws
      end
      sample
    end

    def summary
      csv_file = Tempfile.new
      run_command "#{CmdStan.path}/bin/stansummary#{extension}", "--csv_file=#{csv_file.path}", *@output_files.map(&:path)

      result = {}
      CSV.foreach(csv_file.path, headers: true, converters: :numeric) do |row|
        value = row.to_h
        name = value.delete("name")
        result[name] = value if name == "lp__" || !name.end_with?("__")
      end
      result
    end

    private

    def validate_csv_files
      # TODO ensure consistent files
      output_file = @output_files.first

      File.foreach(output_file.path) do |line|
        matches = /num_samples = (\d+)/.match(line)
        if matches
          @draws = matches[1].to_i
          break
        end
      end

      CSV.foreach(output_file.path, skip_lines: /^#/, headers: true) do |row|
        @column_names = row.to_h.keys
        break
      end
    end
  end
end
