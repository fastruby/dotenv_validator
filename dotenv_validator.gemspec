require_relative 'lib/dotenv_validator/version'

Gem::Specification.new do |s|
  s.name = 'dotenv_validator'
  s.version = DotenvValidator::VERSION
  s.authors = ['Ariel Juodziukynas',
               'Ernesto Tagwerker',
               'Francois Buys',
               'Luis Sagastume',
               'Robert Dormer']
  s.email = ['arieljuod@gmail.com',
             'ernesto+github@ombulabs.com',
             'francois@ombulabs.com',
             'luis@ombulabs.com',
             'robert@ombulabs.com']
  s.licenses = ['MIT']
  s.summary = 'Checks required env variables and its format using .env.sample'
  s.description = 'Checks required env variables and its format using dotenv and .env.sample files. Sample files include validation documentation which is interpreted and used to validate your environment.'
  s.homepage = 'https://github.com/fastruby/dotenv_validator'
  s.files = [
    'lib/dotenv_validator/version.rb',
    'lib/dotenv_validator.rb'
  ]
  s.require_paths = ['lib']

  s.add_dependency 'fast_blank', '~> 1.0.0'

  s.add_development_dependency 'byebug', '>= 11.1', '< 12.0'
  s.add_development_dependency 'climate_control', '>= 1.0', '< 2.0'
  s.add_development_dependency 'codecov', '>= 0.5.0', '< 1.0'
  s.add_development_dependency 'rake', '~> 13.0', '< 14.0'
  s.add_development_dependency 'rspec', '>= 3.0', '< 4.0'
  s.add_development_dependency 'simplecov', '>= 0.21', '< 1.0'
  s.add_development_dependency 'simplecov-console', '~> 0.9.0'
end
