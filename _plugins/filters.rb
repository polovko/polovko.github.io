module Jekyll
  module PostFilters

    # Used on the blog index to split posts on the <!--more--> marker
    def excerpt(input)
      if input.index(/<!--\s*more\s*-->/i)
        input.split(/<!--\s*more\s*-->/i)[0]
      else
        input
      end
    end

    # Checks for excerpts (helpful for template conditionals)
    def has_excerpt(input)
      input =~ /<!--\s*more\s*-->/i ? true : false
    end
  end
end

Liquid::Template.register_filter(Jekyll::PostFilters)
