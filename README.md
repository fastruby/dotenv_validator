# dotenv-checker
This gem check if required env variables are present and its format using the .env and .env.sample files from Dotenv.

# Installation

Add the gem to your gemfile:

```
gem "dotenv-checker", github: "fastruby/dotenv-checker"
```

Call `DotenvChecker.check!` in an initializer:

```
echo "DotenvChecker.check!" > "config/initializers/1-dotenv-checker.rb"
```

> Note the `1-` in the name so it's executed before any other initializer, since initializers are run in alphabetical order.

# Configuring env variable

In your `.env.sample` file, you can add comments to tell DotenvChecker how to validate the variable:

```
MY_REQUIRED_VAR=value #required
THIS_IS_AN_OPTIONAL_INT=123 #format=int
THIS_IS_A_REQUIRED_EMAIL=123 #required,format=email
```

## Formats

- `int` or `integer`
- `float` (note that all integers are floats too)
- `str` or `string` (accepts anything)
- `email` (checks value against `/[\w@]+@[\w@]+\.[\w@]+/`)
- `url` (checks value against `/https?:\/\/.+/`)
- any other value acts as a regexp!

### Regexp format

If you have a complex format, you can use a regexp for validation:

```
MY_WEIRD_ENV_VAR=123_ABC #required,format=\d{3}_\w{3}
```

In the above example, `\d{3}_\w{3}` is converted to a regexp and the value is checked against it.
