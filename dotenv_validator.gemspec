Gem::Specification.new do |s|
  s.name = "dotenv_validator"
  s.version = "1.0.0"
  s.authors = ["Ariel Juodziukynas <arieljuod@gmail.com>"]
  s.email = "arieljuod@gmail.com"
  s.licenses = ["MIT"]
  s.summary = "Checks required env variables and its format using .env and .env.sample files from Dotenv"
  s.description = "Checks required env variables and its format using .env and .env.sample files from Dotenv"
  s.homepage = "https://github.com/fastruby/dotenv_validator"
  s.files = [
    "lib/dotenv_validator.rb"
  ]
  s.require_paths = ["lib"]

  s.add_dependency "dotenv", ">= 2.7", "< 3.0"
  s.add_dependency "fast_blank", "~> 1.0.0"

  s.add_development_dependency "byebug", ">= 11.1", "< 12.0"
  s.add_development_dependency "codecov", ">= 0.5.0", "< 1.0"
  s.add_development_dependency "climate_control", ">= 1.0", "< 2.0"
  s.add_development_dependency "rake", "~> 13.0", "< 14.0"
  s.add_development_dependency "rspec", ">= 3.0", "< 4.0"
  s.add_development_dependency "simplecov", ">= 0.21", "< 1.0"
  s.add_development_dependency "simplecov-console", "~> 0.9.0"
end
