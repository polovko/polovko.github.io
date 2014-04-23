module Jekyll

  class TagsTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      if markup.empty?
        raise SyntaxError.new("Error in tag 'tags' - Valid syntax: tags t1 t2 t3")
      else
        @tags = markup.split
      end

      super
    end

    def render(context)
      @tags.map {|t| "<span class='label'>##{t}</span> "}.join
    end
  end
end

Liquid::Template.register_tag('tags', Jekyll::TagsTag)
