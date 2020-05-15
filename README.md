# README

This is just a sandbox project used while learning ruby/rails. Do not trust this code too much...

# TravisCI

[![Build Status](https://travis-ci.com/cfroehli/tutor_scheduler.svg?branch=master)](https://travis-ci.com/cfroehli/tutor_scheduler)
[![Maintainability](https://api.codeclimate.com/v1/badges/fb03e1f419e99246b69c/maintainability)](https://codeclimate.com/github/cfroehli/tutor_scheduler/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/fb03e1f419e99246b69c/test_coverage)](https://codeclimate.com/github/cfroehli/tutor_scheduler/test_coverage)

# Coverage

  * Simplecov doesnt play well with spring
    ~~~bash
      export COVERAGE=true
      export DISABLE_SPRING=true
    ~~~

# Notes about running system tests

  * selenium containers config in docker compose
    ~~~yaml
    selenium-hub:
       image: selenium/hub:latest
       container_name: selenium-hub
       networks:
         selenium:
           aliases:
             - selenium-server
       ports:
         - 4444:4444
       environment:
         GRID_MAX_SESSION: 10

     selenium-chrome:
       image: selenium/node-chrome:latest
       depends_on:
         - selenium-hub
       networks:
         - selenium
       environment:
         HUB_HOST: selenium-hub
         NODE_MAX_INSTANCES: 10
         NODE_MAX_SESSION: 10

     selenium-chrome-standalone:
       image: selenium/standalone-chrome-debug:latest
       ports:
         - 4444:4444
         - 5900:5900
       networks:
         selenium:
           aliases:
             - selenium-server
     ~~~

   * single container with vncserver
     ~~~bash
       export USE_SELENIUM_CONTAINERS=true
       # edit spec/support/capybara.rb => using: :chrome instead of :headless_chrome
       docker-compose up -d selenium-chrome-standalone
       vncviewer {selenium-chrome-standalone ip} &
       rails spec
     ~~~

   * or with a workers pool
     ~~~bash
       export USE_SELENIUM_CONTAINERS=true
       docker-compose up -d selenium-hub
       docker-compose up -d --scale selenium-chrome=4 selenium-chrome
       rails parallel:spec
     ~~~

   * or local chrome
     ~~~bash
       unset USE_SELENIUM_CONTAINERS
       # edit spec/support/capybara.rb => driven_by using: :headless_chrome or :chrome
       rails spec
     ~~~
