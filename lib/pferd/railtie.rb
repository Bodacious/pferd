module Pferd
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/pferd.rake"
    end
  end
end