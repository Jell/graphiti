module Graphiti
  class Chart
    attr_accessor :name, :data, :x_attribute, :y_attributes, :type,
                  :zoom_to,:width, :height, :labels, :colors

    DEFAULT_PIXEL_WIDTH = 400
    DEFAULT_PIXEL_HEIGHT = 300
    def initialize (args = {})
      args.each do |key, value|
        send("#{key}=", value) if respond_to? "#{key}="
      end
      self.type   ||= :default
      self.width  ||= DEFAULT_PIXEL_WIDTH
      self.height ||= DEFAULT_PIXEL_HEIGHT
      self.labels ||= []
      self.colors ||= []
    end

    def series
      @series ||= y_attributes.each_with_index.map do |y_attribute, index|
        Serie.new(
          name: labels[index] || y_attribute,
          data: data,
          type: type,
          x_attribute: x_attribute,
          y_attribute: y_attribute,
        )
      end
    end

    def html
      html = <<-HTML
    <div id="diagram-#{name}" style="width:#{width}px;height:#{height}px;"></div>
    <script type="text/javascript">
      var options = {
          xaxis: {
            mode: "time"
          },
          series: {
            lines: { show: true, lineWidth: 2},
            points: { show: false, fill: true, radius: 2 },
            shadowSize: 4
          },
          colors: #{colors},
          selection: { mode: "xy" }
        };
      var placeholder = $("#diagram-#{name}");
      $.plot(placeholder, [#{series.map(&:json_data).join(",")}], options);

      placeholder.bind("plotselected", function (event, ranges) {
        var points = #{series.map(&:points).reduce(:+)};
        x_selected = [];
        y_selected = [];
        for(var i = 0; i < points.length; i++) {
          var x = points[i][0];
          var y = points[i][1];
          if(x >= parseFloat(ranges.xaxis.from) && x <= parseFloat(ranges.xaxis.to) &&
             y >= parseFloat(ranges.yaxis.from) && y <= parseFloat(ranges.yaxis.to)) {
            x_selected.push(parseFloat(x)#{"/1000" if series.first.time_serie?});
            y_selected.push(parseFloat(y))
          }
        }
        var url = "#{zoom_to}?from_x=" + Math.min.apply( Math, x_selected ) +
                            "&to_x=" + Math.max.apply( Math, x_selected ) +
                            "&from_y=" + Math.min.apply( Math, y_selected ) +
                            "&to_y=" + Math.max.apply( Math, y_selected );
        location = url;
      });

    </script>
      HTML
    end

  end
end
