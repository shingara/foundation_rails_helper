require 'action_view/helpers'

module FoundationRailsHelper
  class FormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::TagHelper
    def error_for(attribute)
      content_tag(:small, object.errors[attribute].join(', '), :class => :error) unless object.errors[attribute].blank?
    end
  
    %w(file_field email_field text_field text_area).each do |method_name|
      define_method(method_name) do |*args|
        attribute = args[0]
        options   = args[1] || {}
        field(attribute, options) do |options|
          super(attribute, options) 
        end  
      end
    end
  
    def check_box(attribute, options = {}) 
      l = label(attribute, options)
      c = super(attribute, options)
      l.gsub(/(for=\"\w*\"\>)/, "\\1#{c} ").html_safe
    end
    
    def radio_button(attribute, tag_value, options = {})
      options[:for] ||= "#{object.class.to_s.downcase}_#{attribute}_#{tag_value}"
      l = label(attribute, options)
      c = super(attribute, tag_value, options)
      l.gsub(/(for=\"\w*\"\>)/, "\\1#{c} ").html_safe
    end
    
    def password_field(attribute, options = {})
      field attribute, options do |options|
        super(attribute, options.merge(:autocomplete => :off))
      end
    end
    
    def datetime_select(attribute, options = {})
      field attribute, options do |options|
        super(attribute, {}, options.merge(:autocomplete => :off))
      end
    end
  
    def date_select(attribute, options = {})
      field attribute, options do |options|
        super(attribute, {}, options.merge(:autocomplete => :off))
      end
    end
  
    def select(attribute, choices, options = {}, html_options = {})
      field attribute, options do |options|
        html_options[:autocomplete] ||= :off
        super(attribute, choices, options, html_options)
      end
    end
    
    def autocomplete(attribute, url, options = {})
      field attribute, options do |options|
        autocomplete_field(attribute, url, options.merge(:update_elements => options[:update_elements],
                                                         :min_length => 0,
                                                         :value => object.send(attribute))) 
      end                                          
    end

    def submit(value=nil, options={})
      options[:class] ||= "nice small radius blue button"
      super(value, options)
    end
    
  private
    def custom_label(attribute, text = nil)
      has_error = !object.errors[attribute].blank?
      label(attribute, text, :class => has_error ? :red : '')
    end
  
    def error_and_hint(attribute)
      html = ""
      html += content_tag(:span, options[:hint], :class => :hint) if options[:hint]
      html += error_for(attribute) || ""
      html.html_safe
    end
  
    def field(attribute, options, &block)
      html = custom_label(attribute, options[:label]) 
      options[:class] ||= "medium"
      options[:class] = "#{options[:class]} input-text"
      html += yield(options)
      html += error_and_hint(attribute)
    end
  end
end
