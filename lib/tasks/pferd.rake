# frozen_string_literal: true

require "rake"
require "yard"
require "pferd"
require "graphviz"

namespace :pferd do
  # Load the models specified in config and generate their Docs
  # (this is required to get the domain tag from the doc metadata)
  YARD::Rake::YardocTask.new do |t|
    t.files = Pferd.configuration.model_dirs.map { |dir| Rails.root.join(dir, "**", "*.rb").to_s }
    t.options = ["--tag", 'domain:"App domain"', '--output-dir', './tmp/pferd-yard']
  end

  desc "Generate an ERD that shows models grouped by domain"
  task draw_relationships: %i[environment pferd:yard] do
    # Load the Yard registry
    YARD::Registry.load!
    MODEL_DOMAINS = {}
    default_tag = Struct.new(:text).new(Pferd.configuration.default_domain_name)
    # Populate MODEL_DOMAINS with model names and their domains
    YARD::Registry.all(:class).each do |klass_info|
      class_name = [klass_info.namespace, klass_info.name].join("::") if klass_info.namespace.present?
      domain_tag = klass_info.tags.find { |tag| tag.tag_name == "domain" } || default_tag
      MODEL_DOMAINS[class_name] = domain_tag.text
    end
    # Load all models
    Rails.application.eager_load!

    entities = ApplicationRecord.descendants.map do |model|
      next unless MODEL_DOMAINS.key?(model.name)

      entity = Pferd::Entity.new(model.name, Set.new, MODEL_DOMAINS[model.name])
      associations = (
        model.reflect_on_all_associations(:has_many) |
        model.reflect_on_all_associations(:has_one) | model.reflect_on_all_associations(:has_and_belongs_to_many)
      )
      associations.each do |assoc|
        next if Pferd.configuration.ignored_classes.include?(assoc.klass.name)
        next if Pferd.configuration.ignored_modules.any? do |module_name|
          assoc.klass.name.start_with?(module_name)
        end
        # TODO: Figure out what to do with polymorphic relations
        next if assoc.polymorphic?

        entity.add_relationship(name: assoc.klass.name, domain: MODEL_DOMAINS[assoc.klass.name])
      end.compact
      entity
    end.compact

    g = GraphViz.new(:G, type: :digraph)
    node_map = Hash.new { |hash, key| hash[key] = g.add_graph("cluster_#{key}", label: key) }

    # Create subgraphs and nodes by domains
    # Note: This has to be done as a complete loop before the next step, because we'll
    # get an exception if we try to define edges before all of the nodes are defined.
    entities.each do |entity|
      subgraph = node_map[entity.domain]
      subgraph.add_nodes(entity.name)
    end
    ##
    # See above comment
    # rubocop:disable Style/CombinableLoops
    entities.each do |entity|
      entity.associations.each do |relationship|
        color = if Pferd.configuration.highlight_boundary_violations && relationship.boundary_violation
                  "red"
                else
                  "black"
                end
        g.add_edges(entity.name, relationship.name, color: color, style: "dashed")
      end
    end
    # rubocop:enable Style/CombinableLoops

    # Generate output as PNG file
    g.output(png: Pferd.configuration.output_file_name)
    puts "Done #{Pferd.configuration.output_file_name}"
  end
  task default: :draw_relationships
end
