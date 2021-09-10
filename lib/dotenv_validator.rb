require 'fast_blank'
require 'pathname'

# Knows how to check the environment variables and compares it to .env.sample
# and the comments in every line of your .env.sample file.
module DotenvValidator
  # It analyzes the current environment and it compares it to the documentation
  # present in .env.sample.
  #
  # @return [[String],[String]] An array with two arrays. First array: List of missing variables. Second array: List of variables with invalid format.
  def self.analyze_variables
    return [], [] unless File.exist?(sample_file)

    missing_variables = []
    invalid_format = []

    open_sample_file.each do |line|
      variable, config = line.split(' #')
      variable_name, _sample = variable.split('=')
      value = ENV[variable_name]

      if value.nil? || value.blank?
        missing_variables << variable_name if config.to_s.match?(/required/)
        next
      end

      next unless config =~ /format=(.*)/

      valid =
        case Regexp.last_match(1)
        when 'int', 'integer' then integer?(value)
        when 'float' then float?(value)
        when 'str', 'string' then true
        when 'email' then email?(value)
        when 'url' then url?(value)
        else
          value.match?(Regexp.new(Regexp.last_match(1)))
        end

      invalid_format << variable_name unless valid
    end

    [missing_variables, invalid_format]
  end

  # It checks the current environment and it returns a boolean value.
  #
  # @return [Boolean] True if everything looks good. False otherwise.
  def self.check
    result = true

    missing_variables, invalid_format = analyze_variables
    if missing_variables.any?
      puts("WARNING - Missing environment variables: #{missing_variables.join(', ')}")
      result = false
    end

    if invalid_format.any?
      puts("WARNING - Environment variables with invalid format: #{invalid_format.join(', ')}")
      result = false
    end

    result
  end

  # It checks the current environment and it raises a runtime exception.
  #
  # @raise [RuntimeError] Raised if a missing variable is found or an invalid format is encountered.
  def self.check!
    missing_variables, invalid_format = analyze_variables

    raise("Missing environment variables: #{missing_variables.join(', ')}") if missing_variables.any?

    raise("Environment variables with invalid format: #{invalid_format.join(', ')}") if invalid_format.any?
  end

  # It checks the value to check if it is a float or not.
  #
  # @param [String] A string
  # @return [Boolean] True if it is a float value. False otherwise.
  def self.float?(string)
    true if Float(string)
  rescue StandardError
    false
  end

  # It checks the value to check if it is an integer or not.
  #
  # @param [String] A string
  # @return [Boolean] True if it is an integer value. False otherwise.
  def self.integer?(string)
    true if Integer(string)
  rescue StandardError
    false
  end

  # It checks the value to check if it is an email or not.
  #
  # @param [String] A string
  # @return [Boolean] True if it is an email value. False otherwise.
  def self.email?(string)
    string.match?(/[\w@]+@[\w@]+\.[\w@]+/)
  end

  # It checks the value to check if it is a URL or not.
  #
  # @param [String] A string
  # @return [Boolean] True if it is an URL value. False otherwise.
  def self.url?(string)
    string.match?(%r{https?://.+})
  end

  def self.open_sample_file
    File.open(sample_file)
  end

  def self.sample_file
    File.join(root, '.env.sample')
  end

  # Internal: `Rails.root` is nil in Rails 4.1 before the application is
  # initialized, so this falls back to the `RAILS_ROOT` environment variable,
  # or the current working directory.
  #
  # Taken from Dotenv source code.
  def self.root
    root_or_pwd = Pathname.new(ENV["RAILS_ROOT"] || Dir.pwd)

    if defined?(Rails)
      Rails.root || root_or_pwd
    else
      root_or_pwd
    end
  end
end
