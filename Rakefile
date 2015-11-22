#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rubygems'
require 'bundler/setup'
require 'rake'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

begin
  RSpec::Core::RakeTask.new(:spec)
  task :default => :spec
rescue LoadError
end
