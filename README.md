# StudyFinder [![Build Status](https://github.com/ahcis-rds/study_finder/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/ahcis-rds/study_finder/actions/workflows/ci.yml?query=branch%3Amaster)

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

1. Run `docker-compose run web rake db:setup` to initialize your
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
- ElasticSearch synonyms: the default cofiguration stores these in an array in 'lib/modules/trial_synonyms.rb'. See [ElasticSearch synonyms](#elasticsearch-synonyms) for more details.

- Add config/application.yml for application specific variables with the following format:

```yaml
host: 'ldap.umn.edu'
port: 636
base: 'o=University of Minnesota,c=US'
encryption: :simple_tls
departmental_cn: 'USERNAME'
departmental_pw: 'PASSWORD'
theme: 'umn'
ELASTICSEARCH_URL: 'elastic.umn.edu'
wkhtmltopdf_binary_path: 'PATH'
DEFAULT_URL_HOST: 'yourstudyfinder.example.com' # Used in email links/URLs

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

## ElasticSearch synonyms

The default trial search configuration uses a query-time synonym_graph filter. It supports multi-term synonyms, e.g. 'caloric restrictions' and 'low calorie diet'. When trials are indexed, ElasticSearch creates the search analyzer for this. You *do not* have to re-index trials if the synonyms are updated, because it is a query-time filter. 

The default location for synonyms is in an array defined in 'lib/modules/trial_synonyms.rb'. Updates to the synonyms can be picked up by restarting the Rails service. 

### Synonyms File

If you need to use a synonym list that is very large, there is also support for keeping synonyms in a file on the ElasticSearch server. The default configuration keeps two copies of the synonyms in memory, whereas the file configuration only keeps one copy in memory. Even many thousands of synonyms only take up a few MB, so in practice this generally won't matter enough for the extra work of the separate file to be worth it. 

To use a synonyms file, use the configuration option:

```ruby
  config.synonyms_path = '/usr/share/elasticsearch/config/analysis/synonyms.txt'
```

Remember this file is on the ElasticSearch server, *not* part of the Rails application. In deployed environments, you will need to copy your synonyms file to this location. This isn't necessary in the development docker container, which mounts 'config/analysis' within the Rails app to the above path in the ElasticSearch docker container. This allows easier access for modifying synonyms during development, as you can work with them directly in 'config/analysis/synonyms.txt' within the Rails app structure.

To pick up changes to the synonym file in ElasticSearch 7.3 and above, use the API to reload the search analyzers and clear the cache (note the last part of the index name is the Rails environment):

```
$ curl -X POST "host:9200/study_finder-trials-development/_reload_search_analyzers?pretty"
$ curl -X POST "host:9200/study_finder-trials-development/_cache/clear?request=true&pretty"
```

For older versions, or if you run into issues, restarting the ElasticSearch service will also reload the analyzers. 

If you change the name or location of the synonyms file, rebuilding the index as described in [Loading trials](#loading-trials) is required in order to reflect that change. 

### Preprocessing Synonyms

The following rake tasks convert json output specific to the University of Minnesota's enviroment into either a synonyms module file, or a Solr-formatted synonyms file.

Module (array) version:
```
$ rake studyfider:synonyms:to_module
```

Synonyms file version:

```
$ rake studyfider:synonyms:to_txt
```

The default input file name for input is 'synonyms.json' but can be set with an argument:

```
$ rake studyfider:synonyms:to_module[test-synonyms]
```

The input file should exist in 'config/analysis', and the output file will also be written there. The module version will always write a file called 'trial_synonyms.rb', because the file name of course must match the name of the class within the module, whereas the synonyms file version will write 'synonyms.txt' by default, or the file argument if supplied.

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
