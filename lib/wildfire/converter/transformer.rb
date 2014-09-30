module Wildfire
  module Converter
    class Transformer < Core
      class << self
        include OpenCV

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

        def grey(mat)
          return_temp_mat do |grey_mat|
            Cv.cvt_color(mat, grey_mat, CV_BGR2GRAY)
          end
        end

        def blur(mat)
          return_temp_mat do |blur_mat|
            Cv.gaussian_blur(mat, blur_mat, Cv::Size.new(5, 5), 0)
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
            Cv.canny(mat, cannied, 100, 50)
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
          warped = warp(mat, perspective, new_size)
          # rotate(transpose(warped), 3)
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
      end
    end
  end
end
