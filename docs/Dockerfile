# syntax = docker/dockerfile:1

# Build context must be the repository root (not docs/) so that the
# path gem dependency `gem "daisyui", path: ".."` resolves correctly.
# The gem source is placed at /gem and docs app at /gem/docs (= /rails)
# so that `path: ".."` from /gem/docs/Gemfile resolves to /gem.

ARG RUBY_VERSION=4.0.2
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /gem/docs

ENV BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    LITESTACK_DATA_PATH="/data" \
    RAILS_ENV="production"

RUN gem update --system --no-document && \
    gem install -N bundler


# Throw-away build stage to reduce size of final image
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential curl git libvips libyaml-dev pkg-config unzip

# Install Bun
ARG BUN_VERSION=1.3.11
ENV BUN_INSTALL=/usr/local/bun
ENV PATH=/usr/local/bun/bin:$PATH
RUN curl -fsSL https://bun.sh/install | bash -s -- "bun-v${BUN_VERSION}"

# Copy the gem source first (path: ".." dependency from docs/Gemfile)
COPY --link lib/ /gem/lib/
COPY --link exe/ /gem/exe/
# The Stimulus controllers and the importmap that pins them.
COPY --link app/ /gem/app/
COPY --link config/ /gem/config/
COPY --link daisyui.gemspec /gem/daisyui.gemspec
COPY --link Gemfile /gem/Gemfile

# Install application gems
COPY --link docs/Gemfile docs/Gemfile.lock ./
RUN bundle install && \
    bundle exec bootsnap precompile --gemfile && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Install node modules
COPY --link docs/package.json docs/bun.lock ./
RUN bun install --frozen-lockfile

# Copy application code
COPY --link docs/ .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY.
# Drop node_modules + the bun toolchain afterwards — only the built CSS is kept,
# so the final stage's COPY of /gem never carries the JS deps. tmp/cache stays:
# it holds the bootsnap cache precompiled above.
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile && \
    rm -rf node_modules /usr/local/bun


# Final stage for app image
FROM base

# Kamal verifies this label on deploy (must match `service:` in deploy.yml).
# The image is built by the workflow's buildx, not `kamal build`, so we set it
# here rather than relying on Kamal's --label injection.
LABEL service="daisyui"

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libsqlite3-0 libvips && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /gem /gem

# Run and own only the runtime files as a non-root user for security.
# log/ storage/ tmp/ are gitignored (no .keep), so they aren't present after
# COPY — create them before chowning so the build doesn't fail.
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p /data /gem/docs/db /gem/docs/log /gem/docs/storage /gem/docs/tmp && \
    chown -R 1000:1000 /gem/docs/db /gem/docs/log /gem/docs/storage /gem/docs/tmp /data
USER 1000:1000

ENV DATABASE_URL="sqlite3:///data/production.sqlite3"

ENTRYPOINT ["/gem/docs/bin/docker-entrypoint"]

EXPOSE 3000
VOLUME /data
# Thruster fronts Puma (HTTP caching + compression + X-Sendfile). It listens on
# HTTP_PORT and proxies to Puma on TARGET_PORT (it sets PORT for the child, which
# config/puma.rb reads). HTTP_PORT MUST be the port traffic is routed to (Kamal's
# `app_port: 3000` in config/deploy.yml, the EXPOSE above) — Thruster's default
# is 80, which the non-root user can't reliably bind AND which kamal-proxy would
# never route to, silently bypassing Thruster straight into Puma.
ENV HTTP_PORT="3000" \
    TARGET_PORT="3001"
CMD ["./bin/thrust", "./bin/rails", "server"]
