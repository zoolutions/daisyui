# frozen_string_literal: true

# Registry of the reference docs (guides). Each entry maps a URL slug to its
# title, sidebar group, and the Phlex page class that renders it (hand-authored —
# the docs are self-contained Phlex). DocsController renders `view_class`; only
# docs whose page class exists are linked in the sidebar, so there are never dead
# links while the remaining pages are being authored.
class Doc
  REGISTRY = [
    { slug: "installation", title: "Installation", group: "Guide", view: "Installation" },
    { slug: "getting-started", title: "Getting started", group: "Guide", view: "GettingStarted" },
    { slug: "theming", title: "Theming", group: "Guide", view: "Theming" },
    { slug: "class-merging", title: "Class merging", group: "Guide", view: "ClassMerging" },
  ].freeze

  attr_reader :slug, :title, :group, :view_name

  def initialize(slug:, title:, group:, view:)
    @slug = slug
    @title = title
    @group = group
    @view_name = view
  end

  def self.all
    REGISTRY.map { new(**it) }
  end

  def self.from_slug(slug)
    all.find { it.slug == slug }
  end

  def self.grouped
    all.group_by(&:group)
  end

  # { group => [DocsKit::NavItem] } for the authored guides — the Registry v2
  # shape docs-kit's AI surfaces (/llms.txt, /llms-full.txt, search) consume via
  # config.nav_registries. Unwritten pages (no view_class) are dropped.
  def self.nav_items
    all.select(&:view_class).group_by(&:group).transform_values do |docs|
      docs.map { |doc| DocsKit::NavItem.new(href: doc.href, label: doc.title) }
    end
  end

  # The hand-authored Phlex page class for this doc (nil if not yet written).
  def view_class
    "Views::Docs::Pages::#{view_name}".safe_constantize
  end

  # The guide's URL path — consumed by docs-kit's search index and the .md-twin
  # links in /llms.txt.
  def href = "/docs/#{slug}"
end
