# ARNotations is a Ruby on Rails plugin to map any kind of ActiveRecord
# model to a Topic Map Fragment, providing the ability
# to expose them TMExplore compatible using REST.
#
# Author:: Daniel Exner
# Copyright:: Copyright (c) 2010 Daniel Exner
# License:: MIT License (http://www.opensource.org/licenses/mit-license.php)

require 'rake'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  gem.name = "arnoations"
  gem.summary = "Enrich your app with Topic Map fragments"
  gem.description = "Allows creation of Rails Applications with Topic Map Fragment support"
  gem.email = "darkwingdex@googlemail.com"
  gem.homepage = "http://github.com/DeX77/ARNotations"
  gem.authors = ["Daniel Exner"]
  gem.files = Dir["*", "{lib}/**/*"]
  if (RUBY_PLATFORM.include?('java'))
    gem.add_dependency("libxml-jruby")
  else
    gem.add_dependency("libxml-ruby")
  end
end

Jeweler::GemcutterTasks.new
