module Mold
  module ActionViewExtensions
    module FormHelper

      @@default_error_proc = nil

      FIELD_ERROR_PROC = proc { |html_tag, _| html_tag }

      def with_custom_field_error_proc(&block)
        @@default_field_error_proc = ::ActionView::Base.field_error_proc
        ::ActionView::Base.field_error_proc = FIELD_ERROR_PROC
        result = yield
        ::ActionView::Base.field_error_proc = @@default_field_error_proc
        result
      end

      %w[form_for fields_for].each do |helper|
        class_eval <<-METHOD, __FILE__, __LINE__
          def mold_#{helper}(record_or_name_or_array, *args, &block)
            options = args.extract_options!
            options[:builder] = Mold::FormBuilder
            css_class = case record_or_name_or_array
              when String, Symbol then record_or_name_or_array.to_s
              when Array then dom_class(record_or_name_or_array.last)
              else dom_class(record_or_name_or_array)
            end
            options[:html] ||= {}
            options[:html][:class] = "mold_form \#{css_class} \#{options[:html][:class]}".strip

            with_custom_field_error_proc do
              #{helper}(record_or_name_or_array, *(args << options), &block)
            end
          end
        METHOD
      end
    end
  end
end

::ActionView::Base.send :include, Mold::ActionViewExtensions::FormHelper

