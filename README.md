# StudyFinder [![Build Status](https://github.com/ahcis-rds/study_finder/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/ahcis-rds/study_finder/actions/workflows/ci.yml?query=branch%3Amaster)

StudyFinder is a flexible and configurable application that pulls studies from
clinicaltrials.gov and augments the data from alternate data sources such as
clinical trial management or electronic IRB systems. StudyFinder has a theme
support which allows for branding and other customizations.

Contact the StudyFinder team at studyfinder@umn.edu if you:
- Are interested in using StudyFinder at your institution, or
- Have any questions about StudyFinder, or
- Want to learn more about updates or enhancements of the tool.

## Architecture

Please see the [StudyFinder architecture overview](architecture.md) for details regarding the scope of StudyFinder and
its documentation, dependencies, application environment, and security. 

## Upgrade notes for 2.3
This version largely consists of dependency updates, including Rails 8.1. 

There are two changes that may cause breakage for sites with specific kinds of deploy processes, or who have implemented custom Javascript.

1. The asset pipeline has been modernized, with assets now handled by Rails' [jsbundling-rails](https://github.com/rails/jsbundling-rails) and [cssbundling-rails](https://github.com/rails/cssbundling-rails). Dart Sass replaces the old `sass-rails` gem for Sass preprocessing. This has two major implications: 
  - In deployed environments you need to be sure that `build:js` and `build:css` are invoked by your deploy/CI process. This is required for assets changes to be recognized, including changes to themes. In development, changes to CSS/SASS files (including themes) are picked up on the fly.
  - Using ERB templating directives in SCSS/CSS files will no longer work. If you have custom SCSS files that use ERB templating directives, those will need to be refactored. 
2. jQuery has been removed as a dependency. Javascript code has been updated to use modern Rails Stimulus controllers and vanilla JS. System tests have been added (via rspec) to increase test coverage on the JS side. This is not a breaking change for a stock installation, but if your site has JS customizations that rely on jQuery *they will break and need to be updated*. 

Additionally, support for Google "Universal Analytics" (or "Google Analytics 3") has been removed. This isn't a breaking change, as Google turned off Universal Analytics on July 1, 2024. Google Analytics 4 is still supported with no changes necessary to your configuration. 

## Development

The easiest way to get started with a development environment is to use `docker compose`:

1. Run `USER=username docker compose run web rake db:setup` to initialize your
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
1. Run `docker compose up -d` to start a development server.
1. Visit `http://localhost:3000/` to view the application.

### Running specs in Docker (including JS system specs)

Run tests from a one-off `web` container after starting dependencies:

```sh
docker compose up -d selenium postgres elasticsearch
docker compose run --rm web bundle exec rspec
```

Notes:
- `SELENIUM_URL` is set to `http://selenium:4444` in `docker-compose.yml`.
- Do not set `CAPYBARA_APP_HOST` to a compose service name (for example `web`) when running one-off test containers; system specs auto-resolve a routable container address in `spec/support/capybara.rb`.

## Deployment

Running Study Finder on a web server requires:

- Ruby 3.2 or higher (3.4 or higher preferred)
- A configured database that the StudyFinder server can connect to (PostgreSQL configured out of the box; MySQL, SQLServer, Oracle, and more supported by Rails with the appropriate configuration changes)
- An LDAP server that can be used to authenticate StudyFinder users for admin access.  
- ElasticSearch 8.x [Official Instructions](https://www.elastic.co/guide/en/elasticsearch/reference/current/install-elasticsearch.html)
- ElasticSearch (synonyms file)[#elasticsearch-synonyms]
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

StudyFinder offers CSS-based theming. You will find example files in /app/assets/stylesheets/theme. A very basic knowledge of CSS is enough to adapt the examples for branded color schemes, etc. Users experienced in CSS/SASS can achieve a great deal of customization here without touching any of the Rails templates or code. 

To use a theme, create e.g. `app/assets/stylesheets/theme/my-org.scss` with your CSS. Then make sure your build/CI/deploy pipeline makes an environment variable `THEME='my-org'` available when cssbundling is invoked. For the development environment, you may choose to set the environment variable for the theme in `application.yml`, or `docker-compose.yml` if you're using the included Docker container configuration.

StudyFinder uses Bootstrap 5, so Bootstrap mixins, classes, etc. are also available to and can be customized by your theme. [Bootstrap Documentation](https://getbootstrap.com/docs/5/getting-started/introduction/)

Some of the examples include references to images. E.g., the 'brand' class defines the logo image that appears at the upper left of every page:

```
.brand {
    background: url("logo.png");
    ...
}
```

Any images referenced in your theme CSS should be located in /app/assets/images. 

Themes are the recommended method for customizing the appearance of the site. Users with Ruby on Rails experience can change the template files for infinite customization, but as with any open-source project, local changes to the code make pulling updates more difficult. 

Theme files and the theme setting itself (via environment variable) are recognized and processed at build time via a script in `package.json`, per the current Rails defaults with jsbundling/cssbundling. The scripts in `package.json` write out an 'active' theme import in `app/assets/stylesheets/theme/_active.scss` based on the value of the environment variable `$THEME`.

## Other Site Customization

Many aspects of your site can be customized from the site itself, via the admin interface. To access the admin interface, LDAP authentication must be configured (see `config/application.yml.example`). 

Click "Sign In" at the bottom of the home page, and then you will see an "Admin" link on the navbar. The first option, "System Administration", allows you to manage what fields do and don't appear on some screens, set label text, define the location search term for data loads from clinicaltrials.gov, and much more. 

## ElasticSearch synonyms

ELasticSearch powers the StudyFinder site search, autocomplete, etc. The default trial search configuration uses a query-time synonym_graph filter. It supports multi-term synonyms, e.g. 'caloric restrictions' and 'low calorie diet'. When trials are indexed, ElasticSearch creates the search analyzer for this. You *do not* have to re-index trials if the synonyms are updated, because it is a query-time filter. 

The default location for synonyms is in an array defined in 'lib/modules/trial_synonyms.rb'. Updates to the synonyms can be picked up by restarting the Rails service. This default allows you to manage synonyms in the same repository as StudyFinder itself, which can be useful if for example you don't directly control the ElasticSearch instance and can't access it to manage things like a native synonyms file.

But alternately, you can use a native ElasticSearch synonyms file. Just uncomment this configuration option:

```ruby
  config.synonyms_path = '/usr/share/elasticsearch/config/analysis/synonyms.txt'
```

This file path refers to the ElasticSearch server, *not* the Rails application. In deployed environments, you will need to copy your synonyms file to this location when you update them. This isn't necessary in the development Docker container; just put your file in 'config/analysis/'. Docker compose mounts 'config/analysis' to the above path in the ElasticSearch  container. This allows easier access for modifying synonyms during development, as you can work with them directly in 'config/analysis/synonyms.txt' within the Rails app structure.

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
