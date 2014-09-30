require 'pry'
require 'pry-stack_explorer'
require 'require_all'
require 'ropencv'
require 'memoist'
require 'os'

require_relative 'wildfire/manager'
require_relative 'wildfire/screen_cutter'
require_relative 'wildfire/screen_divider'
require_rel 'wildfire/converter'
require_rel 'wildfire/algorithms'

module Wildfire
  class Runner
    class << self
      def cut_a4(source_image_path)
        manager = Manager.new(source_image_path)
        manager.cut_page!(manager.predicted_page_coords)
      end

      def cut_printed_screens(source_image_path)
        a4_path = cut_a4(source_image_path)
        screen_cutter = Converter::ScreenCutter.new(a4_path)
        screen_cutter.cut_screens!

        screen_cutter.screen_paths
      end

      def cut_painted_screens(source_image_path)
        a4_path = cut_a4(source_image_path)

        screen_cutter = Converter::ScreenDivider.new(a4_path)
        screen_cutter.cut_screens!

        screen_cutter.screen_paths
      end
    end
  end
end
