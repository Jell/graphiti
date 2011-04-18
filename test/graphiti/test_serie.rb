require 'helper'

module Graphiti
  class TestSerie < Test::Unit::TestCase
    context "#initialize" do
      should "set everything properly" do
        serie = Serie.new(name: "name", data: "data", type: :diff, x_attribute: :x, y_attribute: :y)
        assert_equal 'name', serie.name
        assert_equal 'data', serie.data
        assert_equal :diff,  serie.type
        assert_equal :x,     serie.x_attribute
        assert_equal :y,     serie.y_attribute
      end
      should "set proper default" do
        serie = Serie.new
        assert_equal [],       serie.data
        assert_equal :default, serie.type
      end
      should "check that the given type is valid" do
        assert_raise RuntimeError do
          Serie.new(type: :blabla)
        end
      end
    end

    context "#points" do
      setup do
        @serie = Serie.new(x_attribute: :x, y_attribute: :y)
      end
      context "when type is default" do
        should "return an array of points with values from attributes" do
          data = 3.times.map{ |i| Point.new(i, i**2)}
          @serie.data = data
          assert_equal [[0,0],[1,1],[2,4]], @serie.points
        end
      end
      context "when type is diff" do
        should "return an array of points with diff between consecutive points" do
          data = 3.times.map{|i| Point.new(i, i**2)}
          @serie.data = data
          @serie.type = :diff
          assert_equal [[1,1],[2,3]], @serie.points
        end
      end
      context "when type is rate" do
        should "return a rate from the data" do
          data = 4.times.map{|i| Point.new(i, 2*i)}
          @serie.data = data
          @serie.type = :rate
          assert_equal [[1,2.0],[2,2.0],[3,2.0]], @serie.points
        end
        should "remove points that have nil denominator" do
          data = 4.times.map{|i| Point.new(1, 2*i)}
          @serie.data = data
          @serie.type = :rate
          assert_equal [], @serie.points
        end
      end
      context "when type is average" do
        should "return an average between two attributes between two points" do
          data = 4.times.map{|i| Point.new(i, 6*i, 3*i)}
          @serie.data = data
          @serie.type = :average
          @serie.y_attribute = [:y, :z]
          assert_equal [[1,2.0],[2,2.0],[3,2.0]], @serie.points
        end
        should "remove points that have nil denominator" do
          data = 4.times.map{|i| Point.new(i, 2*i, 1)}
          @serie.data = data
          @serie.type = :average
          @serie.y_attribute = [:y, :z]
          assert_equal [], @serie.points
        end
      end
      context "when time serie" do
        should "map x data to js time" do
          data = 3.times.map{Point.new(Time.at(123456789), 42) }
          @serie.data = data
          assert_equal [[123456789000, 42]]*3, @serie.points
        end
      end
      context "when there is more data that pixels on the graph" do
        should "decimate data" do
          data = [Point.new(1, 2)] * Chart::DEFAULT_PIXEL_WIDTH * 2
          @serie.data = data
          assert_equal Chart::DEFAULT_PIXEL_WIDTH, @serie.points.length
          assert_equal [[1,2]] * Chart::DEFAULT_PIXEL_WIDTH, @serie.points
        end
      end
    end

    context "#time_serie?" do
      should "return true if x_attribute is a Time" do
        data = 3.times.map{ Point.new(Time.now, 42) }
        serie = Serie.new(data: data, x_attribute: :x, y_attribute: :y)
        assert serie.time_serie?
      end
      should "return false if x_attribute is not a Time" do
        data = 3.times.map{|i| Point.new(i, 42) }
        serie = Serie.new(data: data, x_attribute: :x, y_attribute: :y)
        assert ! serie.time_serie?
      end
    end

    context "#json_data" do
      should "return a formated json with name and points" do
        data = 3.times.map{|i| Point.new(i, i**2) }
        serie = Serie.new(name: "name", data: data, x_attribute: :x, y_attribute: :y)
        assert_equal "{label: \"name\", data: [[0, 0], [1, 1], [2, 4]]}", serie.json_data
      end
    end
  end
end
