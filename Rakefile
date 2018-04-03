# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:spec) do |t|
  t.libs << '.'
  t.test_files = FileList['lib/**/*_spec.rb']
end

task default: :spec
