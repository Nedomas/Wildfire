module Wildfire
  module Algorithms
    class GuoHallThinning < Converter::Core
      def initialize(mat)
        @mat = mat
      end

      def perform
        divided_mat = @mat / 255

        prev = Cv::Mat.zeros(divided_mat.rows, divided_mat.cols, Cv::CV_8UC1)
        diff = temp_mat

        begin
          thinning_iteration(divided_mat, 0)
          thinning_iteration(divided_mat, 1)
          Cv.absdiff(divided_mat, prev, diff)
          prev = divided_mat
          puts "single count #{Cv.count_non_zero(diff)}"
        end while Cv.count_non_zero(diff) > 0

        divided_mat * 255
      end

      private

      def thinning_iteration(mat, iterations)
        marker = Cv::Mat.zeros(mat.rows, mat.cols, Cv::CV_8UC1)

        mat.rows.times do |row|
          mat.cols.times do |col|
            next unless row.between?(1, mat.rows - 2)
            next unless col.between?(1, mat.cols - 2)
            p2 = mat.at(row - 1, col)
            p3 = mat.at(row - 1, col + 1)
            p4 = mat.at(row, col + 1)
            p5 = mat.at(row + 1, col + 1)
            p6 = mat.at(row + 1, col)
            p7 = mat.at(row + 1, col - 1)
            p8 = mat.at(row, col - 1)
            p9 = mat.at(row - 1, col - 1)

            c = (~p2 & (p3 | p4)) + (~p4 & (p5 | p6)) +
              (~p6 & (p7 | p8)) + (~p8 & (p9 | p2))
            n1 = (p9 | p2) + (p3 | p4) + (p5 | p6) + (p7 | p8)
            n2 = (p2 | p3) + (p4 | p5) + (p6 | p7) + (p8 | p9)
            n = n1 < n2 ? n1 : n2
            m = iterations == 0 ? ((p6 | p7 | ~p9) & p8) : ((p2 | p3 | ~p5) & p4)

            if (c == 1 && (n >= 2 && n <= 3) & m == 0)
              marker.set(row, col, 1)
            end

          end
        end

        invert(marker, 1)
      end

      def invert(mat, bit)
        Cv::Mat.ones(mat.size, mat.type) * bit - mat
      end
    end
  end
end
