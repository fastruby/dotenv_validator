# Dotenv Validator

[![Gem Version](https://badge.fury.io/rb/dotenv_validator.svg)](https://badge.fury.io/rb/dotenv_validator) [![Matrix Testing + Lint](https://github.com/fastruby/dotenv_validator/actions/workflows/main.yml/badge.svg)](https://github.com/fastruby/dotenv_validator/actions/workflows/main.yml) [![codecov](https://codecov.io/gh/fastruby/dotenv_validator/branch/main/graph/badge.svg)](https://codecov.io/gh/fastruby/dotenv_validator) [![Docs](http://img.shields.io/badge/yard-docs-blue.svg)](https://www.rubydoc.info/gems/dotenv_validator/) [![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v1.4%20adopted-ff69b4.svg)](CODE_OF_CONDUCT.md)

This gem validates `.env` variables. You can configure validation rules by
adding the appropriate comments to the `.env.sample` file.

# Installation

Add the gem to your Gemfile:

```
gem "dotenv_validator"
```

Call `DotenvValidator.check!` in an initializer:

```
echo "DotenvValidator.check!" > "config/initializers/1_dotenv_validator.rb"
```

> Note the `1_` in the name so it's executed before any other initializer, since initializers are run in alphabetical order.

> You can use `DotenvValidator.check` without the `!` to show warnings instead of raising an exception.

## Updating

Simply run:

```
bundle update dotenv_validator
```

# Configuring env variable

In your `.env.sample` file, you can add comments to tell DotenvValidator how to validate the variable:

```
MY_REQUIRED_VAR=value #required
THIS_IS_AN_OPTIONAL_INT=123 #format=int
THIS_IS_A_REQUIRED_EMAIL=123 #required,format=email
```

## Formats

- `int` or `integer` or `Integer`
- `float` or `Float` (note that all integers are floats too)
- `str` or `string` or `String` (accepts anything)
- `email` (checks value against `/[\w@]+@[\w@]+\.[\w@]+/`)
- `url` (checks value against `/https?:\/\/.+/`)
- `bool` or `boolean` or `Boolean` (checks value against `true` or `false`, case sensitive)
- `uuid` or `UUID` (checks value against `/\A[\da-f]{32}\z/i` or `/\A[\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12}\z/i`)
- any other value acts as a regexp!

### Regexp format

If you have a complex format, you can use a regexp for validation:

```
MY_WEIRD_ENV_VAR=123_ABC #required,format=\d{3}_\w{3}
```

In the above example, `\d{3}_\w{3}` is converted to a regexp and the value is checked against it.

## If you use `docker-compose`, read this

Docker Compose automatically reads `.env` files present in the project's root when running `docker-compose up`. What this means is that, if you use `dotenv_validator` in an app you run using Docker Compose, you might get exceptions or warnings about your variables being in the wrong format even though they're right. The reason is that, when running `docker-compose up`, docker-compose parses the `.env` file before the Rails application starts. It reads each line as is with a really simple parser (no quotes, comments and trailing spaces handling).

Then, since `docker-compose` already set the environment variables, the Dotenv gem won't override them. It parses the file as we'd expect, but it won't change env variables that are already set.

For more information check this [page](https://docs.docker.com/compose/environment-variables/#set-environment-variables-in-containers) from their docs.

The workaround is to rename your `.env` file when using docker. [Here](https://github.com/bkeepers/dotenv#what-other-env-files-can-i-use) you'll find all naming options acceptable for dotenv and that Docker will not automatically parse.

If renaming is not an option, then you need to remove any comments or trailing whitespaces from your `.env` file:
```
SMTP_PORT=25         #format=int
```
needs to become:
```
SMTP_PORT=25
```

### TL;DR
Rename your `.env` file according to this [table](https://github.com/bkeepers/dotenv#what-other-env-files-can-i-use)

or

Remove all comments and trailing whitespaces

## Contributing

Want to make your first contribution to this project? Get started with some of [our good first issues](https://github.com/fastruby/dotenv_validator/contribute)!

Bug reports and pull requests are welcome on GitHub at [https://github.com/fastruby/dotenv_validator](https://github.com/fastruby/dotenv_validator). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

When Submitting a Pull Request:

* If your PR closes any open GitHub issues, please include `Closes #XXXX` in your comment

* Please include a summary of the change and which issue is fixed or which feature is introduced.

* If changes to the behavior are made, clearly describe what changes.

* If changes to the UI are made, please include screenshots of the before and after.

## Sponsorship

![FastRuby.io | Rails Upgrade Services](fastruby-logo.png)

`dotenv_validator` is maintained and funded by [FastRuby.io](https://fastruby.io). The names and logos for FastRuby.io are trademarks of The Lean Software Boutique LLC.
