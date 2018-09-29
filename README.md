# Backup Publisher [![Build Status](https://travis-ci.org/rubytoolbox/backup_publisher.svg?branch=master)](https://travis-ci.org/rubytoolbox/backup_publisher)

*A small tool to sync Heroku Postgres backups to S3, build a static html and json index of available ones and deploy it to Netlify*

## Goals

* Make database snapshots easily available to researchers and contributors of 
  the Ruby Toolbox
* Host backups independent of the Ruby Toolbox production infrastructure
* Provide an overview of available snapshots both for browsers as well as in 
  machine-readable format (a.k.a. JSON)
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

## Deployment
