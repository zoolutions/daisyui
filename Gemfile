# frozen_string_literal: true

source "https://rubygems.org"
gemspec

group :development do
  gem "async", require: false # runs conformance-kit's fiber example (locked for Ruby 3.2)
  gem "conformance-kit", "~> 0.3", require: false # concurrency conformance gates (zoolutions/phlex-reactive#363)
  gem "debug"
  gem "gem-release"
  gem "rake"
  gem "rspec"
  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-rake"
  gem "rubocop-rspec"
  gem "rubocop-thread_safety", ">= 0.8", require: false # conformance-kit's config/rubocop.yml
  gem "super_diff"
end
