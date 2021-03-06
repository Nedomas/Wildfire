module Wildfire
  module Converter
    class Manager < Core
      attr_reader :screens

      def initialize(full_path)
        @full_path = full_path

        unless File.exist?(@full_path)
          raise "The file #{@full_path} does not exits"
        end

        @page_cutter = PageCutter.new(full)
        @screens = []
      end

      def predicted_page_coords
        @page_cutter.small_coords
      end

      def cut_page!(coords)
        page = @page_cutter.cut_page(coords)
        save('big_page.jpg', page)
      end

      def small_full_path
        save('small_full.jpg', small)
      end

      def converted_path
        generate_path('converted.jpg')
      end

      private

      def serialize_points(points)
        points.to_a.map { |p| serialize_point(p) }
      end

      def serialize_point(point)
        { x: point.first, y: point.last }
      end

      def full
        rotate_correctly!
        Cv.imread(@full_path)
      end

      def rotate_correctly!
        `#{gem_path}/bin/jhead-#{operating_system} -autorot #{@full_path}`
      end

      def gem_path
        File.dirname(__FILE__).split('/')[0..-4].join('/')
      end

      def operating_system
        if OS.linux?
          'linux'
        elsif OS.osx?
          'osx'
        else
          puts OS.report
          raise 'Wildfire does not support your operating system'
        end
      end

      def small
        Resizer.new(full).to_small
      end
    end
  end
end
