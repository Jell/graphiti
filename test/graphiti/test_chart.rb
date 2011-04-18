require 'helper'

module Graphiti
  class TestChart < Test::Unit::TestCase
    context "#initialize" do
      should "set everything properly" do
        chart = Chart.new(
          data: "data",
          type: :diff,
          x_attribute: :x,
          y_attributes: [:y],
          zoom_to: 'url',
          width: 200,
          height: 100,
          labels: ['a','b'],
          colors: ['red', 'blue']

        )
        assert_equal 'data',         chart.data
        assert_equal :diff,          chart.type
        assert_equal :x,             chart.x_attribute
        assert_equal [:y],           chart.y_attributes
        assert_equal 'url',          chart.zoom_to
        assert_equal 200,            chart.width
        assert_equal 100,            chart.height
        assert_equal ['a','b'],      chart.labels
        assert_equal ['red','blue'], chart.colors
      end
      should "set proper default" do
        chart = Chart.new
        assert_equal [],       chart.data
        assert_equal [],       chart.labels
        assert_equal [],       chart.colors
        assert_equal "",       chart.zoom_to
        assert_equal :default, chart.type
        assert_equal Chart::DEFAULT_PIXEL_HEIGHT, chart.height
        assert_equal Chart::DEFAULT_PIXEL_WIDTH,  chart.width
      end
      should "check that the given type is valid" do
        assert_raise RuntimeError do
          Chart.new(type: :blabla)
        end
      end
    end

    context "#series" do
      should "return a serie for each given y_attribute" do
        data = 3.times.map{Point.new(1,2,3)}
        chart = Chart.new data: data, x_attribute: :x, y_attributes: [:y, :z], labels: ["a","b"]
        assert_equal 2, chart.series.length
        assert_equal [data]*2, chart.series.map(&:data)
        assert_equal [:x,:x],  chart.series.map(&:x_attribute)
        assert_equal [:y,:z],  chart.series.map(&:y_attribute)
        assert_equal [?a,?b],  chart.series.map(&:name)
      end
    end

    context "#y_attribute=" do
      should "set y_attributes with only one value" do
        chart = Chart.new
        chart.y_attribute = :y
        assert_equal [:y], chart.y_attributes
      end
    end

    context "#id" do
      should "return a consistant randonm number" do
        chart = Chart.new
        assert_instance_of Fixnum, chart.id
        assert_equal chart.id, chart.id
      end
    end

    context "#to_s" do
      should "return html content" do
        chart = Chart.new
        chart.stubs(:html).returns("html")
        assert_equal "html", chart.to_s
      end
    end

    context "#html" do
      setup do
        @data = 3.times.map{Point.new(Time.at(123456789), 1, 42)}
        @chart = Chart.new(data: @data, x_attribute: :x, y_attributes: [:y,:z], colors: ["#0000dd", "#dd0000"])
      end
      should "set id" do
        assert_match /<div\sid="diagram-\d+"/, @chart.html
      end 
      should "set width and height" do
        assert_match /style="width:#{Chart::DEFAULT_PIXEL_WIDTH}px;height:#{Chart::DEFAULT_PIXEL_HEIGHT}px;"/, @chart.html
      end
    end
  end
end
