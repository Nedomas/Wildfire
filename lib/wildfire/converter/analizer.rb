module Wildfire
  module Converter
    class Analizer < Core
      def initialize(big_cvmat)
        @big_cvmat = big_cvmat
        @resizer = Resizer.new(@big_cvmat)
      end

      def shaped_points
        page_contour.to_a.map { |p| @resizer.big_point(p) }
      end

      def shaped_rect(rect)
        top = rect.tl
        bottom = rect.br

        Cv::Rect.new(top.x * @resizer.to_big_ratio,
          top.y * @resizer.to_big_ratio,
          (bottom.x - top.x) * @resizer.to_big_ratio,
          (bottom.y - top.y) * @resizer.to_big_ratio)
      end

      def page_contour
        result = Transformer.approximate(longest_contour)
        Orderer.to_tl_tr_br_bl(result.to_a)
      end

      def longest_contour
        sorted_by_length = contours.to_a.sort_by do |contour|
          Cv.arc_length(contour, false)
        end

        sorted_by_length.last
      end

      def contours
        greyed = Transformer.grey(@resizer.to_small)
        blurred = Transformer.blur(greyed)
        cannied = Transformer.canny(blurred)

        input_and_output = cannied.dup
        execute_contour_find(input_and_output)
      end

      def execute_contour_find(mat)
        contour_mat = temp_mat
        output_array_of_arrays_contours = Std::Vector::Cv_Mat.new

        Cv.find_contours(mat, output_array_of_arrays_contours, contour_mat,
          CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE)

        output_array_of_arrays_contours
      end
    end
  end
end
