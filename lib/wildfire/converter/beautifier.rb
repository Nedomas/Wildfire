module Wildfire
  module Converter
    class Beautifier < Core
      def initialize(full_path)
        @full_path = full_path

        unless File.exist?(@full_path)
          raise "The file #{@full_path} does not exits"
        end
      end

      def beutiful
        Transformer.apply(full,
          %i(
            grey
            adaptive_threshold
          )
        )
      end

      def beautiful_path
        save(name, beutiful)
      end

      def name
        *_, filename = @full_path.split('/')
        "bw_#{filename}"
      end

      private

      def full
        Cv.imread(@full_path)
      end
    end
  end
end
