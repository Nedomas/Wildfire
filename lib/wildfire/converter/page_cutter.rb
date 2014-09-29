module Wildfire
  module Converter
    class PageCutter < Core
      attr_reader :page

      def initialize(big_cvmat)
        @big_cvmat = big_cvmat
        @analizer = Analizer.new(@big_cvmat)
        @resizer = Resizer.new(@big_cvmat)
      end

      def small_coords
        @analizer.page_contour
      end

      def cut_page(coords)
        @page = Transformer.four_point_transform(@big_cvmat,
          @resizer.to_big_coords(coords))
      end
    end
  end
end
