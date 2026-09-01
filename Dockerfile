FROM ruby:3.4.9

RUN apt-get update -qq && apt-get install -y \
  nodejs \
  npm \
  postgresql-client \
  xvfb

RUN npm install -g yarn

RUN mkdir /app
WORKDIR /app

# Install Ruby deps
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

# Install JS deps (before full COPY so layer is cached independently)
COPY package.json yarn.lock /app/
RUN yarn install

COPY . /app

EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
