module Wildfire
  class Manager
    extend Forwardable

    def initialize(*args)
      @instance = Converter::Manager.new(*args)
    end

    def_delegators :@instance, :predicted_page_coords, :cut_page!, :small_full_path
  end
end
