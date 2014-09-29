module Wildfire
  module Converter
    class Orderer
      class << self
        def to_tl_tr_br_bl(points)
          bottom_left = points.sort { |p| p[0] + p[1] }.last
          top_right = points.sort { |p| p[0] + p[1] }.first
          other = points - [top_right, bottom_left]

          bottom_right = other.sort { |p| p[0] - p[1] }.first
          top_left = other.sort { |p| p[0] - p[1] }.last

          [top_left, top_right, bottom_right, bottom_left]
        end
      end
    end
  end
end
