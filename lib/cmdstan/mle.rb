module CmdStan
  class MLE
    include Utils

    # private
    # TODO use runset for args
    def initialize(output_file)
      @output_file = output_file
    end

    def optimized_params
      CSV.foreach(@output_file.path, skip_lines: /^#/, headers: true, converters: :numeric) do |row|
        return row.to_h
      end
    end

    def column_names
      optimized_params.keys
    end
  end
end
