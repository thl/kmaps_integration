module TopicalMapCategoriesHelper

  def category_selector_includes
    [javascript_include_tag('jquery.autocomplete', 'jquery.checktree', 'model-searcher'), stylesheet_link_tag('jquery.autocomplete', 'jquery.checktree')].join("\n")
  end

  def category_selector_includes_old
    [javascript_include_tag('thickbox-compressed', 'category_selector'), stylesheet_link_tag('thickbox', 'category_selector')].join("\n")
  end
  
  def category_searcher(includes = true, options = {})
    return_str = includes ? category_selector_includes : ''
    selected_object = "''"
    category_id = options[:category_id]
    field_name = options[:field_name]

    searcher_options = ''
    if options[:options]
      searcher_options = ', '+options[:options].collect{|option, value| "#{option}: #{escape_javascript(value)}" }.join(', ')
    end
    field_label = options[:field_label] || ''
    return_str += "
      <script type=\"text/javascript\">
        jQuery(document).ready(function(){
        	ModelSearcher.init('tmb_category_selector', '#{Category.find(category_id).get_url(:list_with_features, :format => 'json')}', '#{Category.find(category_id).get_url(:all_with_features, :format => 'json')}', {
        		fieldName: '#{field_name}',
        		fieldLabel: '#{field_label}',
        		selectedObjects: [#{selected_object}]#{searcher_options},
        		proxy: '#{ActionController::Base.relative_url_root}/thl/utils/proxy/'
        	});
        });
      </script>"
    # Need the ability to manually add in the span so we can place the <script/> elsewhere in the DOM
    if !options[:exclude_span]
      return_str += '<span id="tmb_category_selector"></span>'
    end
    return_str
  end
  
  def category_selector(main_category, instance_variable_name, field_name, includes = true, options = {})
    return_str = includes ? category_selector_includes : ''
    selected_category = instance_variable_get("@#{instance_variable_name.to_s}").send(field_name)
    selected_object = selected_category.nil? ? "''" : "{id: '#{escape_javascript(selected_category.id)}', name: '#{escape_javascript(selected_category.title)}'}"
    category_id = main_category.id
    field_name = instance_variable_name.to_s+'['+field_name.to_s+'_id]'
    searcher_options = ''
    if !options.empty?
      searcher_options = ', '+options.collect{|option, value| "#{option}: #{escape_javascript(value)}" }.join(', ')
    end
    return_str += "
      <script type=\"text/javascript\">
        jQuery(document).ready(function(){
        	ModelSearcher.init('tmb_category_selector', '#{main_category.get_url(:list, :format => 'json')}', '#{main_category.get_url(:all, :format => 'json')}', {
        		fieldName: '#{field_name}',
        		fieldLabel: '',
        		selectedObjects: [#{selected_object}]#{searcher_options},
        		proxy: '#{ActionController::Base.relative_url_root}/thl/utils/proxy/'
        	});
        });
      </script>"
    return_str += '<span id="tmb_category_selector"></span>'
  end
  
  
  def category_selector_old(main_category, instance_variable_name, field_name, includes = true)
    tag_prefix = "#{instance_variable_name}_#{field_name}"
    selected_category = instance_variable_get("@#{instance_variable_name.to_s}").send(field_name)
    return_str = includes ? category_selector_includes : ''
    return_str += "<span id=\"#{tag_prefix}_name\">"
    options = { :modal => true } #:height => 300, :width => 300}
    if selected_category.nil?
      return_str += '<i>None selected</i>'
    else
      return_str += selected_category.title
      options[:selected_category_id] = selected_category.id
    end
    category_url = category_children_path(main_category, options)
    return_str += "</span>\n("
    return_str += link_to("select #{h(main_category.title)}", category_url, :class => 'thickbox', :id => tag_prefix, :title => '') +
                  ")\n" +
                  hidden_field(instance_variable_name, "#{field_name}_id")
    return_str
  end
    
  def loading_kmaps_animation_script(id)
    "$(\'##{id}_div\').css(\'background\', \'url(/images/loadingAnimation2.gif) no-repeat center right\')"
  end
end