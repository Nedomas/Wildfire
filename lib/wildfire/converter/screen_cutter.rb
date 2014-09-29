module Wildfire
  module Converter
    class ScreenCutter < Core
      COORDS = {
        tl: [30, 47],
        tr: [150, 47],
        bl: [25, 280],
        br: [150, 280],
      }.freeze

      attr_reader :screen_paths

      def initialize(full_path)
        @full_path = full_path
        @analizer = Analizer.new(full)
        @resizer = Resizer.new(full)
      end

      def screens
        COORDS.map do |which, coords|
          rect_args = @resizer.to_big_coords([coords + [95, 160]]).flatten
          rect = Cv::Rect.new(*rect_args)
          full.block(rect)
        end
      end

      def cut_screens!
        @screen_paths = screens.map.with_index do |screen, i|
          save("screen_#{i}.jpg", screen)
        end
      end

      private

      def full
        Cv.imread(@full_path)
      end
    end
  end
end
