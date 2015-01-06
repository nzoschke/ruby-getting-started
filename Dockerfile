FROM heroku/cedar:14

ENV RUBY_VERSION      2.2.0
ENV RUBY_ABI_VERSION  2.2.0
ENV BUNDLER_VERSION   1.6.3

ENV GEM_PATH        /app/vendor/bundle/ruby/$RUBY_ABI_VERSION
ENV PATH            /app/bin:/app/vendor/ruby-$RUBY_VERSION/bin:$GEM_PATH/gems/bundler-$BUNDLER_VERSION/bin:$PATH
ENV LANG            en_US.UTF-8
ENV BUNDLE_GEMFILE  /app/Gemfile

RUN mkdir -p /app /app/.profile.d /app/bin
WORKDIR /app

# Install Heroku Ruby package
RUN mkdir -p vendor/ruby-$RUBY_VERSION \
  && curl -s https://s3-external-1.amazonaws.com/heroku-buildpack-ruby/cedar-14/ruby-$RUBY_VERSION.tgz \
  | tar xvz -C vendor/ruby-$RUBY_VERSION

# Install Heroku Bundler package
RUN mkdir -p $GEM_PATH \
  && curl -s https://s3-external-1.amazonaws.com/heroku-buildpack-ruby/bundler-$BUNDLER_VERSION.tgz \
  | tar xvz -C $GEM_PATH


# Install Node package for Rails
RUN curl http://nodejs.org/dist/v0.10.30/node-v0.10.30-linux-x64.tar.gz \
  | tar vxz -C /app/bin --strip-components=2 node-v0.10.30-linux-x64/bin/node


# Bundle dependencies
COPY Gemfile /app/
RUN bundle install --path vendor/bundle --binstubs /app/bin -j4

# Add app code
COPY . /app/


# TODO: Why isn't rake installed until a second bundle install?
RUN bundle install
RUN bundle exec rake assets:precompile
