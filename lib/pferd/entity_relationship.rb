# frozen_string_literal: true

require_relative "entity_relationship"
module Pferd
  EntityRelationship = Data.define(:name, :domain, :boundary_violation)
end
