#!/usr/bin/env bash
bundle install && bundle exec rspec
bundle install --gemfile ./test_app/Gemfile && bundle exec --gemfile ./test_app/Gemfile rspec
