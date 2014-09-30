module Wildfire
  class ScreenDivider
    def initialize(*args)
      @screen_cutter = Converter::ScreenDivider.new(*args)
      @screen_cutter.cut_screens!
    end

    def paths
      @screen_cutter.screen_paths
    end
  end
end
