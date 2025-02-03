# Pferd

Pferd is a Ruby gem that generates an **Entity Relationship Diagram (ERD)** of your Ruby on Rails models, automatically **grouping models by their domain**. This is useful when you are in the process of modularising your codebase, and want to visualise various domain configurations without having to move code around.

The diagram (optionally) highlights **domain boundary violations**, giving you insights into possible cross-domain coupling issues.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pferd'
```

And then execute:

```bash
bundle install
```

Or install it directly using:

```bash
gem install pferd
```

## Usage

To generate an ERD, simply run:

```bash
rake pferd:generate
```

## Defining Domains

Pferd groups your models by domain using the `@domain` YARD tag. To specify the domain of a model, add a YARD comment above the model class definition. For example:

```ruby
# @domain payments
class Transaction < ApplicationRecord
  # Model code
end
```

If a model does not have a `@domain` tag, it will be placed in the default domain (`Global` by default).

## Configuration

Pferd comes with configurable options that you can customise. Below is the default configuration:

```ruby
# Establish some default configs
Pferd.configure do |config|
  # Classes without an explicit domain tag should be in this domain
  config.default_domain_name = 'Global'

  # Exclude these classes
  config.ignored_classes = []

  # Exclude classes nested in these modules
  config.ignored_modules = ['ActiveStorage']

  # Load models matching these glob-paths
  config.model_dirs = ['app/models']

  # The name of the generated output file
  config.output_file_name = 'pferd.png'
end
```

### **How to customise:**
You can modify the configuration within an initializer (`config/initializers/pferd.rb`):

```ruby
Pferd.configure do |config|
  config.default_domain_name = 'Core'
  config.ignored_classes = ['SomeTemporaryModel']
  config.ignored_modules = ['ActiveStorage', 'ActionMailbox']
  config.model_dirs = ['app/models', 'engines/*/app/models']
  config.output_file_name = 'custom_erd.png'
end
```

## Domain Boundary Violations

Pferd will analyse your model associations and **highlight where models reference entities from another domain**. Violations will be clearly marked in the ERD using special edge styles (e.g., dashed or highlighted lines).

This feature helps you identify and address cases where models may be overstepping domain boundaries, promoting better separation of concerns within your codebase.

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/your-github/pferd). This project is intended to be a safe, welcoming space for collaboration.

## License

Pferd is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).