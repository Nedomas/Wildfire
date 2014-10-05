module Wildfire
  module Converter
    class Core
      include OpenCV
      RED = Cv::Scalar.new(255, 0, 0)

      def temp_mat
        Cv.imread('/tmp/paper_god.jpg')
      end

      def quick_save(mat)
        Cv.imwrite("#{Dir.home}/quick_photo.jpg", mat)
      end

      def save(filename, image)
        path = generate_path(filename)
        Cv.imwrite(path, image)
        path
      end

      def generate_path(name)
        nodes = @full_path.split('/')[0...-1] + [name]
        nodes.join('/')
      end

      class << self
        def return_temp_mat
          mat = temp_mat
          yield(mat)
          mat
        end
      end
    end
  end
end
