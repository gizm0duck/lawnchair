require 'action_view'
module Lawnchair
  module View
    module Helper
      def lawnchair_cache(key, &block)
        rendered_value = Lawnchair.cache(key, :raw => true) do
          capture(&block)
        end
        concat(rendered_value)
      end
    end
  end
end

ActionView::Base.send(:include, Lawnchair::View::Helper)