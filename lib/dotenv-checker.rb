module DotenvChecker
  def self.analyze_variables
    missing_variables = []
    invalid_format = []

    sample = Rails.root.join(".env.sample")

    return [missing_variables, invalid_variables] unless File.exist?(sample)


    File.open(sample).each do |line|
      variable, config = line.split(" #")
      variable_name, _sample = variable.split("=")
      value = ENV[variable_name]

      if value.blank?
        missing_variables << variable_name if config.to_s.match?(/required/)
        next
      end
  
      if config =~ /format=(.*)/
        valid =
          case $1
          when "int", "integer" then integer?(value)
          when "float" then float?(value)
          when "str", "string" then false
          when "email" then email?(value)
          when "url" then url?(value)
          else
            value.match?(Regexp.new($1))
          end
  
        invalid_format << variable_name unless valid
      end
    end

    [missing_variables, invalid_format]
  end

  def self.check
    missing_variables, invalid_format = analyze_variables
    if missing_variables.any?
      puts("WARNING - Missing environment variables: #{missing_variables.join(", ")}")
    end

    if invalid_format.any?
      puts("WARNING - Environment variables with invalid format: #{invalid_format.join(", ")}")
    end

  end

  def self.check!
    missing_variables, invalid_format = analyze_variables

    if missing_variables.any?
      raise("Missing environment variables: #{missing_variables.join(", ")}")
    end

    if invalid_format.any?
      raise("Environment variables with invalid format: #{invalid_format.join(", ")}")
    end
  end

  def self.float?(string)
    true if Float(string)
  rescue
    false
  end
  
  def self.integer?(string)
    true if Integer(string)
  rescue
    false
  end

  def self.email?(string)
    string.match?(/[\w@]+@[\w@]+\.[\w@]+/)
  end
  
  def self.url?(string)
    string.match?(/https?:\/\/.+/)
  end
end
