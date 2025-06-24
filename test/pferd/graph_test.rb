require 'test_helper'
require 'pferd/graph'

module Pferd
  class GraphTest < Minitest::Test
    def test_graph_with_boundaries_and_crossing_edges
      graph = Pferd::Graph.build do |g|
        g.name("Example")
        g.add_node("A", boundary: "X")
        g.add_node("B", boundary: "X")
        g.add_node("C", boundary: "Y")
        g.add_node("D") # no boundary
        g.add_edge("A", "B")
        g.add_edge("A", "C")
        g.add_edge("C", "D")
      end

      assert_equal ["A", "B", "C", "D"], graph.node_names.sort
      assert graph.has_edge?("A", "B")
      assert graph.has_edge?("B", "A")
      assert graph.has_edge?("A", "C")
      assert graph.has_edge?("C", "D")

      assert_equal "X", graph.boundary_of("A")
      assert_equal "X", graph.boundary_of("B")
      assert_equal "Y", graph.boundary_of("C")
      assert_nil graph.boundary_of("D")

      ab = graph.find_edge("A", "B")
      ac = graph.find_edge("A", "C")
      cd = graph.find_edge("C", "D")

      refute graph.edge_crosses_boundary?(ab)
      assert graph.edge_crosses_boundary?(ac)
      assert graph.edge_crosses_boundary?(cd)
    end
  end
end
