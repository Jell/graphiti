module Graphiti
  class Chart
    attr_accessor :data, :x_attribute, :y_attributes, :type,
                  :zoom_to,:width, :height, :labels, :colors

    DEFAULT_PIXEL_WIDTH = 400
    DEFAULT_PIXEL_HEIGHT = 300
    def initialize (args = {})
      args.each do |key, value|
        send("#{key}=", value) if respond_to? "#{key}="
      end
      self.type    ||= :default
      self.width   ||= DEFAULT_PIXEL_WIDTH
      self.height  ||= DEFAULT_PIXEL_HEIGHT
      self.labels  ||= []
      self.colors  ||= []
      self.data    ||= []
      self.zoom_to ||= ""
      raise "wrong type, accepted: #{Serie::AVAILABLE_TYPES}" unless Serie::AVAILABLE_TYPES.include? type
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
    
    def y_attribute=(value)
      self.y_attributes = [value]
    end

    def id
      @id ||= rand(1e10)
    end

    def to_s
      test_string.respond_to?(:html_safe) ? html.html_safe : html
    end

    JS_TIME_TO_DATE_STRING = <<-JS
      var timeToDateString = function(time){
        var date = new Date(time);
        var year = date.getFullYear();
        var month = date.getMonth()+1;
        var day = date.getDate();
        var hour = date.getHours();
        var minute = date.getMinutes();
        var second = date.getSeconds();
        if(month<10)  {month='0'+month;}
        if(day<10)    {day='0'+day;}
        if(hour<10)   {hour='0'+hour;}
        if(minute<10) {minute='0'+minute;}
        if(second<10) {second='0'+second;}
        return ""+year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;
      };
      from_x = timeToDateString(from_x);
      to_x   = timeToDateString(to_x);
    JS

    def html
      html = <<-HTML
<div id="diagram-#{id}" style="width:#{width}px;height:#{height}px;">
  <script type="text/javascript">
  //<![CDATA[

  var options = {
    xaxis: {
      #{'mode: "time"' if series.first.time_serie?}
    },
    series: {
      lines: { show: true, lineWidth: 2},
      points: { show: false, fill: true, radius: 2 },
      shadowSize: 4
    },
    colors: #{colors},
    selection: { mode: "xy" }
  };

  var placeholder = $("#diagram-#{id}");

  $.plot(placeholder, [#{series.map(&:json_data).join(",")}], options);

  placeholder.bind("plotselected", function (event, ranges) {

    var from_x = parseFloat(ranges.xaxis.from);
    var to_x   = parseFloat(ranges.xaxis.to);
    var from_y = parseFloat(ranges.yaxis.from);
    var to_y   = parseFloat(ranges.yaxis.to);

    #{JS_TIME_TO_DATE_STRING if series.first.time_serie?}

    var url = "#{zoom_to + (zoom_to.include?('?') ? ?& : ??)}" +
                         "from_x=" + from_x + "&" +
                         "to_x="   + to_x   + "&" +
                         "from_y=" + from_y + "&" +
                         "to_y="   + to_y;
    location = url;
  });

  //]]>
  </script>
</div>
      HTML
    end

    private

    def test_string
      ""
    end
  end
end
