module Graphiti
  class Serie
    attr_accessor :name, :data, :type, :x_attribute, :y_attribute

    def initialize (args = {})
      args.each do |key, value|
        send("#{key}=", value) if respond_to? "#{key}="
      end
      self.data   ||= []
    end

    def points

      x_data = data.map(&:"#{x_attribute}")
      x_data = x_data.map{ |entry| to_js_time(entry) } if x_data.first.is_a?(Time)
      x_data.shift unless type == :default

      y_data = data.map(&:"#{y_attribute}") unless type == :rate
      if type == :diff
        y_data = y_data.each_cons(2).map { |first, second| second - first }
      end
      if type == :rate
        y_data = data.each_cons(2).map do |first, second|
          numerator   = second.send(y_attribute) - first.send(y_attribute)
          denominator = second.send(x_attribute) - first.send(x_attribute)
          denominator > 0 ? numerator.to_f / denominator : nil
        end
      end

      decimation_rate = x_data.length / Chart::DEFAULT_PIXEL_WIDTH
      decimation_rate = 1 if decimation_rate < 1

      x_data_sampled = x_data.each_slice(decimation_rate).map {|x| x.compact!; x.empty? ? nil : x.reduce(:+) / x.size}
      y_data_sampled = y_data.each_slice(decimation_rate).map {|y| y.compact!; y.reduce(:+) / y.size}

      [x_data_sampled, y_data_sampled].transpose
    end

    def json_data
      "{label: \"#{name}\", data: #{points}}"
    end

    def to_js_time(time)
      1000 * time.to_f
    end

    def to_unix_time(time)
      Time.at(time.to_i / 1000)
    end

  end
end
