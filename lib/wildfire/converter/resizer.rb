module Wildfire
  module Converter
    class Resizer < Core
      def initialize(original, small_height: 500.0)
        @original = original
        @small_height = small_height
      end

      def to_small
        new_sized_mat = temp_mat
        Cv.resize(@original, new_sized_mat, small_size)
        new_sized_mat
      end

      def small_size
        new_size = @original.size.dup
        new_size.height = @small_height
        new_size.width = new_size.height * to_small_ratio
        new_size
      end

      def to_small_ratio
        @original.size.width / @original.size.height.to_f
      end

      def to_big_ratio
        @original.size.height / @small_height
      end

      def big_point(coords)
        coords.map { |coord| (coord * to_big_ratio).to_i }
      end

      def to_big_coords(rect)
        rect.map { |coords| big_point(coords) }
      end
    end
  end
end
