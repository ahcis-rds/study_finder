FROM ruby:3.2

RUN apt-get update -qq && apt-get install -y \
  nodejs \
  postgresql-client \
  xvfb

RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
#COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app

EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
