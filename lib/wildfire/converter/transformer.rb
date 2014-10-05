module Wildfire
  module Converter
    class Transformer < Core
      class << self
        include OpenCV
        RED = Cv::Scalar.new(255, 0, 0)

        # just duping
        def temp_mat
          Cv.imread('/tmp/paper_god.jpg')
        end

        def quick_save(mat)
          Cv.imwrite('/home/domas/quick_photo.jpg', mat)
        end

        def approximate(mat)
          accuracy = 0.02 * Cv.arc_length(mat, false)

          return_temp_mat do |approxed_curve|
            Cv.approx_polydp(mat, approxed_curve, accuracy, true)
          end
        end

        def select_rects(contours)
          contours.select { |contour| contour.count == 4 }
        end

        def grey(mat)
          return_temp_mat do |grey_mat|
            Cv.cvt_color(mat, grey_mat, CV_BGR2GRAY)
          end
        end

        def hsv(mat)
          return_temp_mat do |hsv_mat|
            Cv.cvt_color(mat, hsv_mat, CV_BGR2HSV)
          end
        end

        def blur(mat)
          return_temp_mat do |blur_mat|
            Cv.gaussian_blur(mat, blur_mat, Cv::Size.new(3, 3), 0)
          end
        end

        def median_blur(mat)
          return_temp_mat do |blur_mat|
            Cv.median_blur(mat, blur_mat, 3)
          end
        end

        def erode(mat)
          return_temp_mat do |eroded_mat|
            kernel = temp_mat
            Cv.erode(mat, eroded_mat, kernel)
          end
        end

        def dilate(mat)
          dilated_mat = temp_mat
          kernel = temp_mat
          Cv.dilate(mat, dilated_mat, kernel)
          dilated_mat
        end

        def canny(mat)
          return_temp_mat do |cannied|
            Cv.canny(mat, cannied, 100, 200)
          end
        end

        def substract(mat1, mat2)
          return_temp_mat do |result|
            Cv.subtract(mat1, mat2, result)
          end
        end

        def binary(mat, *args)
          args = [1, 1000, Cv::THRESH_OTSU] if args.empty?

          return_temp_mat do |binaried|
            Cv.threshold(mat, binaried, *args)
          end
        end

        def thin(mat)
          Algorithms::GuoHallThinning.new(mat).perform
        end

        def execute_contour_find(mat)
          contour_mat = temp_mat
          output_array_of_arrays_contours = Std::Vector::Cv_Mat.new

          Cv.find_contours(mat, output_array_of_arrays_contours, contour_mat,
            CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE)

          output_array_of_arrays_contours
        end

        def select_long(contours_array)
          filter_half(contours_array) do |contour|
            Cv.arc_length(contour, false)
          end
        end

        def select_big(contours_array)
          filter_half(contours_array) do |contour|
            Cv.contour_area(contour)
          end
        end

        def cluster_lines(lines)
          result = []

          lines.to_a.each do |line|
            result << line unless result.any? { |existing| similar?(existing, line) }
          end

          result
        end

        def similar?(line1, line2)
          rho1, theta1 = line1
          rho2, theta2 = line2
          close?(theta1, theta2, similarity: 0.6) && close?(rho1, rho2)
        end

        def by_white(contours, mat)
          contours.sort_by do |contour|
            warped = Transformer.four_point_transform(mat, contours)

            color = Std::Vector::Cv_Mat.new
            Cv.split(warped, color)
            color = color.to_a

            color[0] = color[0] * 0.299
            color[1] = color[1] * 0.587
            color[2] = color[2] * 0.114

            lum = color[0] + color[1] + color[2]
            sum = lum.to_a.flatten.inject(:+)

            # summ = Cv::Scalar.new(sum)
            sum / (mat.rows * mat.cols).to_f
#             binding.pry
#
#
#             binding.pry
#             coords = Orderer.new(contour.to_a)
#             height = coords.br.y - coords.tl.y
#             width = coords.br.x - coords.tl.x
#             next if height == 0 or width == 0
#
#             rect = Cv::Rect.new(coords.tl.x, coords.tl.y, height, width)
#             binding.pry if height <= 0 or width <= 0 or coords.tl.x <= 0 or coords.tl.y <= 0
#             binding.pry if height + coords.tl.y >= mat.rows
#             binding.pry if width + coords.tl.x >= mat.cols
#             binding.pry
#             roi = mat.block(rect) rescue binding.pry
#
#             mask = Cv::Mat.zeros(roi.rows, roi.cols, Cv::CV_8U)
#             mean = Cv.mean(roi, mask)
#
#             binding.pry if mean.to_a.inject(:+) > 0
#             0
          end
        end

        def close?(member1, member2, similarity: 0.9)
          return true if member1 == member2
          return false if member1 == 0

          divide_by = member1 > member2 ? member1 : member2

          (member1 - member2).abs / divide_by <= similarity
        end

        def sort_by_rectangularity(contours_array)
          without_zeros = contours_array.select do |contour|
            Cv.contour_area(contour) > 0
          end

          without_zeros.sort_by do |contour|
            min_rect = Cv.min_area_rect(contour)
            min_rect_size = min_rect.size.width * min_rect.size.height

            min_rect_size - Cv.contour_area(contour)
          end
        end

        def select_biggest_bounding_rect(contours_array)

          binding.pry
        end

        def filter_half(source)
          sorted = source.sort_by do |contour|
            yield(contour)
          end

          sorted[(source.size * 1 / 10)..-1]
        end

        def draw_contours(mat, contours)
          Cv.draw_contours(mat, contours, -1, RED)
          mat
        end

        def find_largest_rect_contour(mat)
          sorted_by_area = execute_contour_find(mat).to_a.sort_by do |contour|
            Cv.min_area_rect(contour).size.area
            # binding.pry
            # (Cv.bounding_rect(contour).size.area / 2) + Cv.arc_length(contour, false)
          end

          sorted_by_area[-6..-1].each do |c|
            p Cv.min_area_rect(c).size.area
          end

          binding.pry
          sorted_by_area.last
        end

        def hough_lines(mat)
          lines = temp_mat
          Cv.hough_lines(mat, lines, 1, Math::PI / 180, 20)
          lines.reshape(1, lines.cols)
        end

        def hough_to_cartesian(lines)
          lines.map do |(rho, theta)|
            next unless rho and theta

            a = Math.cos(theta)
            b = Math.sin(theta)
            x0 = a * rho
            y0 = b * rho

            [[x0 + 1000 * -b, y0 + 1000 * a], [x0 - 1000 * -b, y0 - 1000 * a]]
          end
        end

        def to_rectangles(lines)
          cartesian_lines = hough_to_cartesian(lines)

          intersect_points = []

          cartesian_lines.each do |line1|
            other = cartesian_lines - [line1]

            other.each do |line2|
              point = intersect_point(line1, line2)
              next unless point

              intersect_points << point
            end
          end

          binding.pry

          rects = []

          intersect_points.each do |p1|
            other1 = intersect_points - [p1]

            other1.each do |p2|
              other2 = other1 - [p2]

              other2.each do |p3|
                other3 = other2 - [p3]

                other3.each do |p4|
                  rects << [p1, p2, p3, p4]
                end
              end
            end
          end

          binding.pry
        end

        def intersect_point(line1, line2)
          x1, y1, x2, y2 = line1.flatten
          x3, y3, x4, y4 = line2.flatten

          d = ((x1 - x2) * (y3 - y4)) - ((y1 - y2) * (x3 - x4))
          return if (-1..1).include?(d.to_i)

          point = Cv::Point.new
          point.x = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / d
          point.y = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) *
            (x3 * y4 - y3 * x4)) / d

          point
        end

        def draw_hough_lines!(mat, lines)
          hough_to_cartesian(lines.to_a).each do |p1coords, p2coords|
            p1 = Cv::Point.new(*p1coords)
            p2 = Cv::Point.new(*p2coords)

#             line2 = lines.to_a[i + 1]

            Cv.line(mat, p1, p2, RED, 1)
          end

          mat
        end

        def draw_points!(mat, points)
          points.each do |point|
            p = Cv::Point.new(*point)

            Cv.circle(mat, p, 3, RED, 2)
          end

          mat
        end

        def four_point_transform(mat, points)
          calculator = Converter::SizeCalculator.new(points)

          destination = [
            [0, 0],
            [calculator.max_width - 1, 0],
            [calculator.max_width - 1, calculator.max_height - 1],
            [0, calculator.max_height - 1],
          ]

          input = cv_point_array(destination)
          output = cv_point_array(calculator.points.map { |p| [p[0], p[1]] })
          perspective = Cv.get_perspective_transform(input, output)

          new_size = Cv::Size.new(calculator.max_width, calculator.max_height)
          warp(mat, perspective, new_size)
        end

        def cv_point_array(array)
          mat = Cv::Mat.new(array)
          mat.convert_to(mat, Cv::CV_32FC2)
          mat
        end

        def warp(mat, perspective, new_size)
          return_temp_mat do |warped|
            Cv.warp_perspective(mat, warped, perspective, new_size,
              Cv::INTER_LINEAR | Cv::WARP_INVERSE_MAP)
          end
        end

        def transpose(mat)
          return_temp_mat do |transposed|
            Cv.transpose(mat, transposed)
          end
        end

        def flip(mat)
          return_temp_mat do |flipped|
            Cv.flip(mat, flipped, 0)
          end
        end

        def rotate(mat, repetitions)
          result = mat

          repetitions.times do
            result = one_rotation(result)
          end

          result
        end

        def one_rotation(mat)
          flip(transpose(mat))
        end

        def apply(mat, transformations)
          if transformations.empty?
            mat
          else
            current_method = transformations.shift
            transformed = send(current_method, mat)

            apply(transformed, transformations)
          end
        end
      end
    end
  end
end
