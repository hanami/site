# frozen_string_literal: true

require "hanami/rake_tasks"
require "rubocop/rake_task"

RuboCop::RakeTask.new

desc "Run code quality checks"
task lint: %i[rubocop]

Rake::Task["default"].clear
task default: %i[lint spec]
