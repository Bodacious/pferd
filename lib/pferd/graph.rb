module Pferd
  class Graph
    attr_reader :name, :nodes, :edges, :boundaries

    def self.build(&block)
      builder = GraphBuilder.new
      block.call(builder)
      builder.build
    end

    def initialize(name:, nodes:, edges:, boundaries:)
      @name = name
      @nodes = nodes # Array of Node
      @edges = edges # Array of Edge
      @boundaries = boundaries # Hash[String => Array of Node names]
    end

    def node_names
      nodes.map(&:name)
    end

    def find_edge(a, b)
      edges.find { |e| undirected_match?(e, a, b) }
    end

    def has_edge?(...)
      !find_edge(...).nil?
    end

    def boundary_of(name)
      node = nodes.find { _1.name == name }
      boundaries.each do |boundary, members|
        return boundary if members.include?(node)
      end
      nil
    end

    def edge_crosses_boundary?(edge)
      a_boundary = boundary_of(edge.from)
      b_boundary = boundary_of(edge.to)
      a_boundary != b_boundary
    end

    private

    def undirected_match?(edge, a, b)
      (edge.from == a && edge.to == b) || (edge.from == b && edge.to == a)
    end
  end

  class GraphBuilder
    def initialize
      @name = nil
      @nodes = []
      @edges = []
      @boundaries = Hash.new { |h, k| h[k] = [] }
    end

    def name(name)
      @name = name
    end

    def add_node(name, boundary: nil)
      node = Node.new(name)
      @nodes << node
      @boundaries[boundary] << node if boundary
    end

    def add_edge(a, b)
      @edges << Edge.new(a, b)
    end

    def build
      Graph.new(name: @name, nodes: @nodes, edges: @edges, boundaries: @boundaries)
    end
  end

  class Node
    attr_reader :name

    def initialize(name) = @name = name
  end

  class Edge
    attr_reader :from, :to

    def initialize(from, to)
      @from = from
      @to = to
    end
  end
end
