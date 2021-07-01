require "fast_blank"

module DotenvValidator
  def self.analyze_variables
    return [], [] unless File.exist?(sample_file)

    missing_variables = []
    invalid_format = []

    open_sample_file.each do |line|
      variable, config = line.split(" #")
      variable_name, _sample = variable.split("=")
      value = ENV[variable_name]

      if value.nil? || value.blank?
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
    result = true

    missing_variables, invalid_format = analyze_variables
    if missing_variables.any?
      puts("WARNING - Missing environment variables: #{missing_variables.join(", ")}")
      result = false
    end

    if invalid_format.any?
      puts("WARNING - Environment variables with invalid format: #{invalid_format.join(", ")}")
      result = false
    end

    result
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

  def self.open_sample_file
    File.open(sample_file)
  end

  def self.sample_file
    File.join(File.expand_path(File.dirname(__FILE__)), ".env.sample")
  end
end
