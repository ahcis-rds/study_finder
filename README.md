# StudyFinder
[![Build Status](https://travis-ci.org/ahcis-rds/study_finder.svg?branch=master)](https://travis-ci.org/ahcis-rds/study_finder)

StudyFinder is a flexible and configurable application that pulls studies from
clinicaltrials.gov and augments the data from alternate datasources such as a
clinical trials management system. StudyFinder also has a basic theming
component which allows for even further customizations.

Contact the StudyFinder team at studyfinder@umn.edu if you:
- Are interested in using StudyFinder at your institution, or
- Have any questions about StudyFinder, or
- Want to learn more about updates or enhancements of the tool.

## Development

The easiest way to get started with a development environment is to use `docker-compose`:

1. Run `docker-compose run web rake db:create db:migrate db:seed` to initialize your
database and search index.
1. Run `docker-compose up -d` to start a development server.
1. Visit `http://localhost:3000/` to view the application.

## Deployment

Running Study Finder on a web server requires:

- Ruby 2.4+
- A configured database w/ connection.  Doesn't really matter which type (Postgres, Oracle, MySQL)
- ElasticSearch 1.0 to 2.x. (Note: 5.x is currently not supported due to breaking changes in the api)
  [Official Instructions](https://www.elastic.co/guide/en/elasticsearch/guide/current/_installing_elasticsearch.html)
  [Mac Installation instructions](http://red-badger.com/blog/2013/11/08/getting-started-with-elasticsearch/)
- ElasticSearch synonyms file: (In trial.rb there is a configuration path to the synonyms file that is needed for elasticsearch to work properly.  Please copy /config/analysis/synonym.txt to the location below and rename the file accordingly.)

```ruby
  synonyms_path: '/usr/share/elasticsearch/config/analysis/synonyms.txt'.to_s
```
- Add config/application.yml for application specific variables with the following format:

```yaml
host: 'ldap.umn.edu'
port: 636
base: 'o=University of Minnesota,c=US'
encryption: :simple_tls
departmental_cn: 'USERNAME'
departmental_pw: 'PASSWORD'
theme: 'umn'
es_host: 'elastic.umn.edu'

```

## Loading trials

- Load all trials.  (Note: Dangerous business here!!  This will delete and reload data from every StudyFinder table.  Essentially starting from scratch. Use at your own risk!)

```
$ rake studyfinder:ctgov:reload_all
```

- Once the trials are loaded initially, the "load" task updates them each night with the last "x" amount of days worth of trials from ctgov.  (Note: The number of days previous variable is available as a parameter)

```
# defaults to 4 days previous
$ rake studyfinder:ctgov:load

# specify the number of days previous as a parameters (10 days in this example)
$ rake studyfinder:ctgov:load[10]
```

- Trials should automatically add/update themselves into the elasticsearch index.  If for some reason all the trials need to be re-indexed the following will do that.

```
$ rake studyfinder:trials:reindex
```

## Embed Widget

The search screen within StudyFinder has the ability to be embedded into other websites. To do this add the following snippet to any other sites wanting to embed the search capability of StudyFinder.

```html
<iframe src="https://studyfinder.url/embed" width="100%" height="350" frameborder="0"></iframe>
```

## Adding Captcha to email forms (optional)

If you would like to add a captcha to the contact forms, follow the steps below.

1. Go to https://www.google.com/recaptcha/admin and obtain a reCAPTCHA API key.
2. Put the site key and secret key into the application.yml file as variables.
```
  RECAPTCHA_SITE_KEY: 'site_key_from_google'
  RECAPTCHA_SECRET_KEY: 'secret_key_from_google'
```
3. Go to the admin section and turn on the "Add Captcha to email forms" option and save.
4. Verify that captcha is now setup on forms.
