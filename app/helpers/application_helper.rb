module ApplicationHelper
  def markdown(text)
    return "" if text.blank?

    options = {
      filter_html:     true, # Sécurité : évite l'injection de scripts
      hard_wrap:       true, # Respecte les retours à la ligne
      link_attributes: { rel: 'nofollow', target: "_blank" }
    }

    extensions = {
      autolink:           true,
      superscript:        true,
      fenced_code_blocks: true # Pour bien afficher les blocs de code avec ```
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(text).html_safe
  end
end
