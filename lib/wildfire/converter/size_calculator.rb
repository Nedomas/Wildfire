module Wildfire
  module Converter
    class SizeCalculator < Core
      attr_reader :points

      def initialize(points)
        @points = Orderer.to_tl_tr_br_bl(points)
      end

      def max_width
        tl, tr, br, bl = @points

        width_bottom = difference(br, bl)
        width_top = difference(tr, tl)
        [width_top.to_i, width_bottom.to_i].max
      end

      def max_height
        tl, tr, br, bl = @points

        height_right = difference(tr, br)
        height_left = difference(tl, bl)
        [height_right.to_i, height_left.to_i].max
      end

      def difference(point1, point2)
        d = (point2[0] - point1[0])**2 + (point2[1] - point1[1])**2
        Math.sqrt(d)
      end
    end
  end
end
