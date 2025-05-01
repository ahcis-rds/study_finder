# StudyFinder Architecture

StudyFinder is a Ruby on Rails application. This repository includes a
Dockerfile and docker-compose.yml which define a local development/evaluation
instance of the application. This uses Rails' included Puma server, PostgreSQL,
and ElasticSearch. 

Ruby on Rails is a standard web application platform which is supported in a
wide variety of contexts. Rails applications can be run on your own on-site
hardware with an application server such as Puma or Phusion Passenger, or in a
Rails environment on cloud services like Azure or AWS, or many other options.
Rails applications are most commonly run on Linux-like operating systems, but
Windows Server is also an option. 

As delivered, the application is intentionally environment-agnostic. Because
Ruby on Rails is supported in essentially all common application / hosting
environments, and each site has their own existing environment and practices,
StudyFinder does *not* document any specific hosting details. These are up to
each adopter. If you're not familiar with running a Ruby on Rails application,
it's best to start with documentation and/or support for your existing
environment; for example, if you run other web applications on Azure using e.g.
Django and Python, you will find that Microsoft has documentation, examples,
tools, and support for doing the equivalent with Ruby on Rails. 

## Dependencies

StudyFinder has three major dependencies: 
1. Ruby, and Rails. 
1. PostgreSQL or another supported database. 
1. Elasticsearch. 

As distributed, StudyFinder uses PostgreSQL; however, you can use any RDBMS or
other data store that is supported by Ruby on Rails. PostgreSQL, MySQL, and
SQLite have first-class support from Rails core. Oracle, SQLServer, MongoDB,
and more are supported via community gems. Configuring a Rails application to
use these databases is documented publicly and beyond the scope of
StudyFinder's documentation. 

ElasticSearch is an industry standard, open-source search solution which is also
publicly documented. StudyFinder's README outlines the basics to get the
included search functionality working; for more details or to customize search
for your site and data sources, refer to the ElasticSearch documentation. 

## Integrations

By default, StudyFinder imports study data from clinicaltrials.gov for a given
site. It is also common to create custom integrations to pull study data from a
site's Clinical Trial Management System (such as OnCore), or IRB system.
StudyFinder offers an API to insert study data, which can be used by custom
integrations. Because the details of such systems vary greatly from site to
site, the implementation details of any integration are left to each site to
implement as necessary. 

## Security

This information is intended to share which technologies are used, and
what has been done by us to reduce, but not eliminate, the risk of IT security
incidents. StudyFinder is intended to capture publicly viewable and searchable
study information. It is NOT intended to handle sensitive data, including
HIPAA-covered private health information. StudyFinder adheres to Ruby on Rails
defaults for standard security for web applications per se; it uses secure
HTTPS connections, has protection against cross-site scripting attacks, etc.
Additionally, StudyFinder code is designed to protect against application-level
attacks such as SQL Injection. 

StudyFinder implements secure LDAP authentication in order for system
administrators to log in to the app and access admin functions; there is no
provision for "accounts" for the broader audience of potential study
participants. This is an intentional design decision in order to reduce the
likelihood of any PHI leaking into the application database, logs, etc. 

Broader security of the system, as with the larger architecture around the
application, is the responsibility of the adopter. For example, securing the
network between StudyFinder any any sensitive data sources that you decide to
integrate is your responsibility and outside the scope of the StudyFinder
application per se. 

## Accessibility

StudyFinder targets compliance with the ADA Title II rules published April 24,
2024. The application is regularly scanned using a variety of common web
accessibility evaluation tools, and updates made based on the results. 

