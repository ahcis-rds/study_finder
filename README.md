# StudyFinder
The goal for StudyFinder is to provide a flexible and configurable application to pull studies from clinicaltrials.gov and augment the data from alternate datasources such as a clinical trials management system.  StudyFinder also has a basic theming component which allows for even further customizations.

## Installation
You will need the following requirements to get StudyFinder up and running locally.

- Ruby 1.9.3+

- Rails 4.0+

- A configured database w/ connection.  Doesn't really matter which type (Postgres, Oracle, MySQL)

- ElasticSearch 1.0 or higher. 
  [Official Instructions](https://www.elastic.co/guide/en/elasticsearch/guide/current/_installing_elasticsearch.html)
  [Mac Installation instructions](http://red-badger.com/blog/2013/11/08/getting-started-with-elasticsearch/)

- ElasticSearch synonyms file: (In trial.rb there is a configuration path to the synonyms file that is needed for elasticsearch to work properly.  Please copy /config/analysis/synonym.txt to the location below and rename the file accordingly.)

```ruby
  synonyms_path: '/etc/elasticsearch/trials_synonym.txt'.to_s
```

# System Setup
Once everything is configured above, the following steps will need to be taken.

- Setup the database connection in database.yml for local development

```yaml
local:
  adapter: postgresql
  host: localhost
  database: studyfinder
  username: studyfinder
  password: studyfinder
  pool: 5
  timeout: 5000
```

- Add a line to secrets.yml for the local environment

```yaml
local:
  secret_key_base: SOME_SECRET_KEY
```

- Add config/application.yml for application specific variables with the following format.

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

- Migrate the local database

```
$ rake db:migrate RAILS_ENV=local
```

- Configure seed the data for your school.  In the seeds.rb file there is "system" hash where you will want to change some of the data that is specific to your institution. You will be able to change this information later in the administration section, however it's good to do it before downloading any trials from clinicaltrials.gov.

- Updating the seeds file
The seeds file is responsible for seeding the database and will need to be updated to reflect the system data for your specific installation.  Also note that the seeds file will create an initial admin user and should be changed to someone within your organization designated to managing the system.

- Seed the database with initial data

```
$ rake db:seed RAILS_ENV=local
```

- Load all trials.  (Note: Dangerous business here!!  This will delete and reload data from every StudyFinder table.  Essentially starting from scratch. Use at your own risk!)

```
$ rake studyfinder:ctgov:reload_all RAILS_ENV=local
```

- Once the trials are loaded initially, the "load" task updates them each night with the last "x" amount of days worth of trials from ctgov.  (Note: The "days_previous" variable is configurable in lib/tasks/ctgov.rake)

```
$ rake studyfinder:ctgov:load RAILS_ENV=local
```

- Trials should automatically add/update themselves into the elasticsearch index.  If for some reason all the trials need to be re-indexed the following will do that.

```
$ rake studyfinder:trials:reindex RAILS_ENV=local
```

