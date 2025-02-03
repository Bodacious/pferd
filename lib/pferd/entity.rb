# frozen_string_literal: true
require_relative 'entity_relationship'
module Pferd
  class Entity
    attr_accessor :klass_name, :associations, :domain
    alias name klass_name

    def initialize(klass_name, associations, domain)
      @klass_name = klass_name
      @associations = Set.new
      @domain = domain
    end

    def add_relationship(name: , domain: )
      boundary_violation = self.domain != domain
      associations.add(
        EntityRelationship.new(name:, domain:, boundary_violation: boundary_violation)
      )
    end
    def to_h
      { entity: klass_name, domain: domain, associations: associations.map(&:to_h) }
    end
  end
end