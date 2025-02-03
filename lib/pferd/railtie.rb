module Pferd
  class Railtie < Rails::Railtie
    rake_tasks do
      require "tasks/pferd.rake"
    end
  end
end