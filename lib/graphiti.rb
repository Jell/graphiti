require 'graphiti/chart'
require 'graphiti/serie'

module Graphiti
  class << self
    def to_js_time(time)
      (time.to_time.to_f * 1000).to_i
    end

    def to_unix_time(time)
      Time.at(time.to_i / 1000)
    end
  end
end
