module Wildfire
  class ScreenCutter
    def initialize(*args)
      @screen_cutter = Converter::ScreenCutter.new(*args)
      @screen_cutter.cut_screens!
    end

    def paths
      @screen_cutter.screen_paths
    end
  end
end
