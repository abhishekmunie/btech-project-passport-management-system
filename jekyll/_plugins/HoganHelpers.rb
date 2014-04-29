module Jekyll
  class SetParameter < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @parameter = text
    end

    def render(context)
      "<%= (request.getParameter(\""<<@parameter<<"\") != null) ? request.getParameter(\""<<@parameter<<"\") : \"\" %>"
    end
  end
end

Liquid::Template.register_tag('set_parameter', Jekyll::SetParameter)

module Jekyll
  class SetParameterNamed < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @parameter = text
    end

    def render(context)
      "name=\""<<@parameter<<"\"  <%= (request.getParameter(\""<<@parameter<<"\") != null) ? (\"value=\\\"\"+request.getParameter(\""<<@parameter<<"\")+\"\\\"\") : \"\" %>"
    end
  end
end

Liquid::Template.register_tag('set_parameter_named', Jekyll::SetParameterNamed)

module Jekyll
  class SetParameterWhenAutofill < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @parameter = text
    end

    def render(context)
      "<%= (request.getParameter(\"autoFillUsingParameter\") != null && request.getParameter(\""<<@parameter<<"\") != null) ? request.getParameter(\""<<@parameter<<"\") : \"\" %>"
    end
  end
end

Liquid::Template.register_tag('set_parameter_when_autofill', Jekyll::SetParameterWhenAutofill)

module Jekyll
  class SetParameterNamedWhenAutofill < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @parameter = text
    end

    def render(context)
      "name=\""<<@parameter<<"\"  <%= (request.getParameter(\"autoFillUsingParameter\") != null && request.getParameter(\""<<@parameter<<"\") != null) ? (\"value=\\\"\"+request.getParameter(\""<<@parameter<<"\")+\"\\\"\") : \"\" %>"
    end
  end
end

Liquid::Template.register_tag('set_parameter_named_when_autofill', Jekyll::SetParameterNamedWhenAutofill)


module Jekyll
  class SetAttributeWhenAutofill < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @attribute = text
    end

    def render(context)
      "{{#locals.autoFillUsingLocals}}{{#locals."<<@attribute<<"}}value=\"{{locals."<<@attribute<<"}}\"{{/locals."<<@attribute<<"}}{{/locals.autoFillUsingLocals}}"
    end
  end
end

Liquid::Template.register_tag('set_attribute_when_autofill', Jekyll::SetAttributeWhenAutofill)

module Jekyll
  class SetAttributeNamedWhenAutofill < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @attribute = text
    end

    def render(context)
      "name=\""<<@attribute<<"\" {{#locals.autoFillUsingLocals}}{{#locals."<<@attribute<<"}}value=\"{{locals."<<@attribute<<"}}\"{{/locals."<<@attribute<<"}}{{/locals.autoFillUsingLocals}}"
    end
  end
end

Liquid::Template.register_tag('set_attribute_named_when_autofill', Jekyll::SetAttributeNamedWhenAutofill)