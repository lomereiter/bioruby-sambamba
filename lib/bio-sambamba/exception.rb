module Bio

  module SambambaStderrParser
    private
    def raise_exception_if_stderr_is_not_empty(perr)
      msg = perr.read
      raise msg unless msg.empty?
    end
  end

  module FileExistenceChecker
    def check_file_existence filename
      raise "file #{filename} does not exist" unless File.exists? filename
    end
  end
end
