require 'graphiti/chart'
require 'graphiti/serie'

module Graphiti

  def to_js_time(time)
    1000 * time.to_f
  end

  def to_unix_time(time)
    Time.at(time.to_i / 1000)
  end

end
