module Wildfire
  module Converter
    class Orderer
      include OpenCV
      POSITIONS = %i(tl tr br bl)

      def initialize(points)
        @points = self.class.to_tl_tr_br_bl(points)
        to_cv_points!
      end

      def to_cv_points!
        @points = @points.map { |p| Cv::Point.new(*p) }
      end

      POSITIONS.each do |position|
        define_method(position) { @points[POSITIONS.index(position)] }
      end

      class << self
        def to_tl_tr_br_bl(points)
          tl = points.sort_by { |p| p[0] + p[1] }.first
          br = points.sort_by { |p| p[0] + p[1] }.last

          other = points - [tl, br]

          tr = other.max { |p| p[0] }
          bl = other.min { |p| p[0] }

          [tl, tr, br, bl]
        end
      end
    end
  end
end
