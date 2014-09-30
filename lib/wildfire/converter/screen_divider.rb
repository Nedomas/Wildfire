module Wildfire
  module Converter
    class ScreenDivider < Core
      attr_reader :screen_paths

      def initialize(full_path)
        @full_path = full_path
      end

      def sizes
        [(full.cols / 2), (full.rows / 2)]
      end

      def coords
        {
          screen_1: [0, 0],
          screen_2: [(full.cols / 2), 0],
          screen_3: [0, (full.rows / 2)],
          screen_4: [(full.cols / 2), (full.rows / 2)]
        }
      end

      def screens
        coords.map do |_which, coord|
          rect = Cv::Rect.new(*[coord, sizes].flatten)
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
