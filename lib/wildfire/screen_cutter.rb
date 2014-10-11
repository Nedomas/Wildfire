module Wildfire
  class ScreenCutter
    def initialize(*args)
      @screen_cutter = Converter::ScreenCutter.new(*args)
      @screen_cutter.cut_screens!
    end

    def paths
      @screen_cutter.screen_paths
    end

    def beautiful_paths
      @screen_cutter.screen_paths.map do |path|
        beautifier = Converter::Beautifier.new(path)
        beautifier.beautiful_path
      end
    end
  end
end
