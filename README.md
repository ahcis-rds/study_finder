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

1. Run `USER=username docker-compose run web rake db:setup` to initialize your
database and search index. 

    The username value will be used to create an initial admin user; you should set it to the username you will use with LDAP authentication.

    By default, this loads studies from clinicaltrials.gov based on searching for the location 'University of Minnesota'. To change this for initial setup, edit this line in /app/db/seeds.rb:

    ```
    system = {
        ...
        search_term: 'University of Minnesota',
        ...
    }
    ```
    (Once the site is up, this is availble as a setting in the front-end admin interface.)
1. Run `docker-compose up -d` to start a development server.
1. Visit `http://localhost:3000/` to view the application.

## Deployment

Running Study Finder on a web server requires:

- Ruby 2.4+
- A configured database w/ connection.  Doesn't really matter which type (Postgres, Oracle, MySQL)
- ElasticSearch 1.0 to 2.x. (Note: 5.x is currently not supported due to breaking changes in the api)
  [Official Instructions](https://www.elastic.co/guide/en/elasticsearch/guide/current/_installing_elasticsearch.html)
  [Mac Installation instructions](http://red-badger.com/blog/2013/11/08/getting-started-with-elasticsearch/)
- ElasticSearch synonyms file. In /app/models/trial.rb there is a configuration path to the synonyms file that is needed for elasticsearch to work properly. Please copy /config/analysis/synonyms.txt to the location below **on the ElasticSearch server/container**:

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

## Themes

StudyFinder offers a CSS-based theme system. You will find example files in /app/assets/stylesheets/theme. A very basic knowledge of CSS is enough to adapt the examples for branded color schemes, etc. Users experienced in CSS/SASS can achieve a great deal of customization here without touching any of the Ruby/Rails code. 

StudyFinder uses Bootstrap 4, so Bootstrap mixins, classes, etc. are also available to and can be customized by your theme. 

Some of the examples include references to images. E.g., the 'brand' class defines the logo image that appears at the upper left of every page:

```
.brand {
    background: image-url("logo.png");
    ...
}
```

Any images referenced in your theme CSS should be located in /app/assets/images. 

Themes are the recommended method for customizing the appearance of the site. Users with Ruby/Rails experience can change the template files for infinite customization, but as with any open-source project, local changes to the code make pulling updates much more difficult. 

## Other Site Customization

Many aspects of your site can be customized from the site itself, via the admin interface. To access the admin interface, LDAP authentication must be configured. Click "Sign In" at the bottom of the home page, and then you will see an "Admin" link on the navbar. The first option, "System Administration", allows you to manage what fields do and don't appear on some screens, set label text, define the location search term for data loads from clinicaltrials.gov, and much more. 

## Trademark

"StudyFinder" is a registered trademark of the University of Minnesota. Your instance of StudyFinder should retain the official StudyFinder logo that appears at the upper right of each page. This is an SVG image and **can** be styled with your institution's colors. By default it uses the main and secondary colors that are specified in the theme CSS file: 

```
$school_main_color: #7a0019;
$school_secondary_color: #ffd75f;
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
