#!/usr/bin/env bash
bundle install && bundle exec rspec
cd ./test_app
bundle install && bundle exec rspec
