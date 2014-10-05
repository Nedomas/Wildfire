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
        cannied = Transformer.apply(@resizer.to_small,
          %i(
            blur
            dilate
            canny
          )
        )

        lines = Transformer.hough_lines(cannied)
        clustered_lines = Transformer.cluster_lines(lines)
        # edges = Transformer.draw_hough_lines!(@resizer.to_small, clustered_lines)
        # quick_save edges
        # binding.pry

        contours = []

        clustered_lines.each do |line1|
          other1 = clustered_lines - [line1]

          other1.each do |line2|
            other2 = clustered_lines - [line2]

            other2.each do |line3|
              other3 = clustered_lines - [line3]

              other3.each do |line4|
                blank_mat = Cv::Mat.zeros(@resizer.to_small.rows, @resizer.to_small.cols,
                  Cv::CV_8U)

                line_array = [line1, line2, line3, line4]
                mat = Transformer.draw_hough_lines!(blank_mat, line_array)
                contours << Transformer.execute_contour_find(mat).to_a
              end
            end
          end
        end

        contours.flatten!

        approximated = contours.to_a.map do |contour|
          Transformer.approximate(contour)
        end

        rects = Transformer.select_rects(approximated)
        big_contours = Transformer.select_big(rects)
        # sorted_by_white = Transformer.by_white(big_contours, @resizer.to_small)

        corners = big_contours.last

        # points = Transformer.draw_points!(@resizer.to_small, corners.to_a)
        # quick_save points

        corners.to_a
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
        Transformer.execute_contour_find(input_and_output)
      end
    end
  end
end
