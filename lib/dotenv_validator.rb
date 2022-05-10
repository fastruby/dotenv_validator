# frozen_string_literal: true

require "fast_blank"
require "pathname"
require "dotenv_validator/errors"

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
      variable, config = line.split(" #")
      variable_name, _sample = variable.split("=")
      value = ENV[variable_name]

      if value.nil? || value.blank?
        missing_variables << variable_name if config.to_s.match?(/required/)
        next
      end

      next unless config =~ /format=(.*)/

      valid =
        case Regexp.last_match(1)
        when *integer_options then integer?(value)
        when *float_options then float?(value)
        when *string_options then string?(value)
        when *email_options then email?(value)
        when *url_options then url?(value)
        when *boolean_options then boolean?(value)
        when *uuid_options then uuid?(value)
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
      puts("WARNING - Missing environment variables: #{missing_variables.join(", ")}")
      result = false
    end

    if invalid_format.any?
      puts("WARNING - Environment variables with invalid format: #{invalid_format.join(", ")}")
      result = false
    end

    result
  end

  # It checks the current environment and it raises a runtime exception.
  #
  # @raise [RuntimeError] Raised if a missing variable is found or an invalid format is encountered.
  def self.check!
    missing_variables, invalid_format = analyze_variables

    raise("Missing environment variables: #{missing_variables.join(", ")}") if missing_variables.any?

    raise("Environment variables with invalid format: #{invalid_format.join(", ")}") if invalid_format.any?
  end

  # It checks the value if it is a string or not.
  #
  # @param [String] A string
  # @return [Boolean] True if it is a string value. False otherwise.
  def self.string?(string)
    true if String(string)
  rescue
    false
  end

  # It checks the value if it is a float or not.
  #
  # @param [String] A string
  # @return [Boolean] True if it is a float value. False otherwise.
  def self.float?(string)
    true if Float(string)
  rescue
    false
  end

  # It checks the value if it is an integer or not.
  #
  # @param [String] A string
  # @return [Boolean] True if it is an integer value. False otherwise.
  def self.integer?(string)
    true if Integer(string)
  rescue
    false
  end

  # It checks the value if it is an email or not.
  #
  # @param [String] A string
  # @return [Boolean] True if it is an email value. False otherwise.
  def self.email?(string)
    string.match?(URI::MailTo::EMAIL_REGEXP)
  end

  # It checks the value if it is a URL or not.
  #
  # @param [String] A string
  # @return [Boolean] True if it is an URL value. False otherwise.
  def self.url?(string)
    string.match?(/\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/)
  end

  # It checks the value if it is a boolean or not.
  #
  # @param [String] A string
  # @return [Boolean] True if it is a boolean value. False otherwise.
  def self.boolean?(string)
    string.match?(/(true|false)/)
  end

  # It checks the value if it is a uuid or not.
  #
  # @param [String] A string
  # @return [Boolean] True if it is a UUID value. False otherwise.
  def self.uuid?(string)
    string.match?(/\A[\da-f]{32}\z/i) ||
      string.match?(/\A[\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12}\z/i)
  end

  def self.open_sample_file
    File.open(sample_file)
  rescue Errno::ENOENT
    raise DotenvValidator::SampleFileNotFoundError, "#{sample_file} was not found!"
  end

  def self.sample_file
    File.join(root, ".env.sample")
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

  # Accepted options for the integer type
  # @return [Array]
  def self.integer_options
    %w[int integer Integer]
  end

  # Accepted options for the float type
  # @return [Array]
  def self.float_options
    %w[float Float]
  end

  # Accepted options for the string type
  # @return [Array]
  def self.string_options
    %w[str string String]
  end

  # Accepted options for the email type
  # @return [Array]
  def self.email_options
    %w[email Email]
  end

  # Accepted options for the url type
  # @return [Array]
  def self.url_options
    %w[url Url]
  end

  # Accepted options for the boolean type
  # @return [Array]
  def self.boolean_options
    %w[bool boolean Boolean]
  end

  # Accepted options for the uuid type
  # @return [Array]
  def self.uuid_options
    %w[uuid Uuid]
  end
end
