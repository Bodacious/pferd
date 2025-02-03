# frozen_string_literal: true

require_relative "pferd/version"
require_relative "pferd/entity"
require "ostruct"
module Pferd
  class Error < StandardError; end

  module_function

  # just use an OpenStruct for flexible config until we know what configs we need
  def configuration
    @configuration ||= OpenStruct.new
  end

  def configure
    yield(configuration)
  end

  # Establish some default configs
  configure do |config|
    # Classes without an explicit domain tag should be in this domain
    config.default_domain_name = "Global"
    # Exclude these classes
    config.ignored_classes = []
    # Exclude classes nested in these modules
    config.ignored_modules = ["ActiveStorage"]
    # Load models from these directories
    config.model_dirs = ["app/models"]
    # The name of the generated output file
    config.output_file_name = "pferd.png"
    # Highlight boundary violations
    config.highlight_boundary_violations = true
  end
end
# Load this last so that the Rake file has access to the above config.
load "pferd/lib/tasks/pferd.rake"
