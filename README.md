# Backup Publisher [![Build Status](https://travis-ci.org/rubytoolbox/backup_publisher.svg?branch=master)](https://travis-ci.org/rubytoolbox/backup_publisher)

**A small tool to make Ruby Toolbox production database dumps available**

## Goals

* Make database snapshots easily available to researchers and contributors of 
  the Ruby Toolbox
* Host backups independent of the Ruby Toolbox production infrastructure
* Provide an overview of available snapshots both for browsers as well as in 
  machine-readable format (a.k.a. JSON) for scripted consumption
* Host the main entry points via HTTPS from a domain under Ruby Toolbox control
* Avoid polluting the [main app's](https://github.com/rubytoolbox/rubytoolbox)
  repo with backup handling code
* Avoid building actual backup-making-code

## How does it work?

1. [Query available backups from the Heroku Postgres API](lib/backup_publisher/heroku_client.rb)
2. [Sync the available backups](lib/backup_publisher/publisher.rb) to an [AWS S3 bucket](lib/backup_publisher/storage.rb)
3. [Build an HTML and JSON index of available recent backups](lib/backup_publisher/indexer.rb)
4. [Deploy the index as a static site to Netlify](lib/backup_publisher/deployer.rb)

## Configuration

### Heroku API

Obviously, access to the API for the app you want to query Heroku Postgres Backups must be provided:

 * `PG_HEROKU_APP`: Name of the Heroku app to pull database backups for
 * `PG_HEROKU_USER`: E-Mail address for the user account
 * `PG_HEROKU_API_KEY`: API key for said user account

### AWS S3

To mirror database dumps, AWS S3 is used. You need to set up and configure an 
IAM role and corresponding API keys as well as the actual S3 bucket via the 
AWS API or web console yourself, then provide these via:

 * `AWS_ACCESS_KEY_ID` 
 * `AWS_SECRET_ACCESS_KEY`
 * `AWS_REGION`
 * `AWS_BUCKET`

### Netlify

To deploy the actual listings of available backup, 
[Netlify](https://www.netlify.com/) is used. You need to create and configure 
the site to deploy to using their API or web interface as well as creating a
personal OAuth2 access token in your account settings page.

 * `NETLIFY_TOKEN`: Your OAuth2 access token
 * `NETLIFY_SITE`: Name of the Netlify site you want to deploy the index to

## Deployment

In the Ruby Toolbox's case, this app is hosted on Heroku. Follow the basic 
process to get it deployed:

 * Create an app in your preferred region
 * Add the git remote
 * `heroku config:set` all the required configuration options
 * `git push heroku master`

Do not worry about Heroku complaining about the absent Procfile, this app does 
not have any permanently running processes.

Instead, add the Heroku Scheduler add-on and configure an hourly task to run `rake process`.

## Code of Conduct

Everyone participating in this project's development, issue trackers and other channels is expected to follow our [Code of Conduct](./CODE_OF_CONDUCT.md)

## License

This project is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
