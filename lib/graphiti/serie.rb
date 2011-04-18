module Graphiti
  class Serie
    attr_accessor :name, :data, :type, :x_attribute, :y_attribute

    AVAILABLE_TYPES = [:default, :diff, :rate, :average]
    def initialize (args = {})
      args.each do |key, value|
        send("#{key}=", value) if respond_to? "#{key}="
      end
      self.data   ||= []
      self.type   ||= AVAILABLE_TYPES.first
      raise "wrong type, accepted: #{AVAILABLE_TYPES}" unless AVAILABLE_TYPES.include? type
    end

    def points
      return @points if @points
      x_data = data.map(&:"#{x_attribute}")
      x_data = x_data.map{ |entry| Graphiti.to_js_time(entry) } if time_serie?
      x_data.shift unless type == :default

      y_data = data.map(&:"#{y_attribute}") if [:diff, :default].include? type
      if type == :diff
        y_data = y_data.each_cons(2).map { |first, second| second - first }
      end
      if type == :rate
        y_data = data.each_cons(2).map do |first, second|
          numerator   = second.send(y_attribute) - first.send(y_attribute)
          denominator = second.send(x_attribute) - first.send(x_attribute)
          denominator > 0 ? numerator.to_f / denominator.to_f : nil
        end
      end
      if type == :average
        y_data = data.each_cons(2).map do |first, second|
          numerator   = second.send(y_attribute.first)  - first.send(y_attribute.first)
          denominator = second.send(y_attribute.last) - first.send(y_attribute.last)
          denominator > 0 ? numerator.to_f / denominator.to_f : nil
        end
      end

      decimation_rate = x_data.length / Chart::DEFAULT_PIXEL_WIDTH
      decimation_rate = 1 if decimation_rate < 1

      x_data_sampled = x_data.each_slice(decimation_rate).map {|x| x.compact!; x.empty? ? nil : x.reduce(:+) / x.size}
      y_data_sampled = y_data.each_slice(decimation_rate).map {|y| y.compact!; y.empty? ? nil : y.reduce(:+) / y.size}

      @points = [x_data_sampled, y_data_sampled].transpose.select{|x, y| x && y}
    end

    def time_serie?
      return false unless data.first
      data.first.send(x_attribute).is_a? Time
    end

    def json_data
      "{label: \"#{name}\", data: #{points}}"
    end

  end
end
