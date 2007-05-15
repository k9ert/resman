module EventsHelper
  include Resman

  def collection_select_multiple(object, method,
				 collection, value_method, text_method,
				 options = {}, html_options = {})
    real_method = "#{method.to_s.singularize}_ids".to_sym
    collection_select(
      object, 
      real_method,
      collection, value_method, text_method,
      options,
      html_options.merge({
	:multiple => true,
	:name => "#{object}[#{real_method}][]"
      })
    )
  end

  def collection_select_multiple_resource_uses(object, method,
                                            options = {}, html_options = {})
    collection_select_multiple(
      object, method,
      Resman::Resource.find(:all), :id, :name,
      options, html_options
    )
  end

  def render_resource_name resource_use
    if resource_use.collision
      return "<font color=\"red\">#{resource_use.resource.name}</font>/"
    end
    resource_use.resource.name
  end
  
end
