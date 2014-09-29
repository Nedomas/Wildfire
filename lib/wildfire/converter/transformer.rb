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

          approxed_curve = temp_mat
          Cv.approx_polydp(mat, approxed_curve, accuracy, true)
          approxed_curve
        end

        def grey(mat)
          grey_mat = temp_mat
          Cv.cvt_color(mat, grey_mat, CV_BGR2GRAY)
          grey_mat
        end

        def blur(mat)
          blur_mat = temp_mat
          Cv.gaussian_blur(mat, blur_mat, Cv::Size.new(5, 5), 0)
          blur_mat
        end

        def median_blur(mat)
          blur_mat = temp_mat
          Cv.median_blur(mat, blur_mat, 3)
          blur_mat
        end

        def erode(mat)
          eroded_mat = temp_mat
          kernel = temp_mat
          Cv.erode(mat, eroded_mat, kernel)
          eroded_mat
        end

        def dilate(mat)
          dilated_mat = temp_mat
          kernel = temp_mat
          Cv.dilate(mat, dilated_mat, kernel)
          dilated_mat
        end

        def canny(mat)
          cannied = temp_mat
          Cv.canny(mat, cannied, 100, 50)
          cannied
        end

        def substract(mat1, mat2)
          result = temp_mat
          Cv.subtract(mat1, mat2, result)
          result
        end

        def binary(mat)
          binaried = temp_mat
          Cv.threshold(mat, binaried, 1, 1, Cv::THRESH_OTSU)
          # Cv.threshold(mat, binaried, Cv::THRESH_BINARY)
          binaried
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
          rotate(transpose(warped), 3)
        end

        def cv_point_array(array)
          mat = Cv::Mat.new(array)
          mat.convert_to(mat, Cv::CV_32FC2)
          mat
        end

        def warp(mat, perspective, new_size)
          warped = temp_mat
          Cv.warp_perspective(mat, warped, perspective, new_size,
            Cv::INTER_LINEAR | Cv::WARP_INVERSE_MAP)
          quick_save(warped)
          warped
        end

        def transpose(mat)
          transposed = temp_mat
          Cv.transpose(mat, transposed)
          transposed
        end

        def flip(mat)
          flipped = temp_mat
          Cv.flip(mat, flipped, 0)
          flipped
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
