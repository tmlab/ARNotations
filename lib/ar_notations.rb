# ARNotations is a Ruby on Rails plugin to map any kind of ActiveRecord
# model to a Topic Map Fragment, providing the ability
# to expose them TMExplore compatible using REST.
#
# Author:: Daniel Exner
# Copyright:: Copyright (c) 2010 Daniel Exner
# License:: MIT License (http://www.opensource.org/licenses/mit-license.php)

#Require the ARNotationsController

#Register XTM2 Format
Mime::Type.register "application/xtm+xml", :xtm,  mime_type_synonyms = [], extension_synonyms = [:xtm2]


#Map any XTM2 Request to the ARNotationsController
#ActionController::Routing::Routes.draw do |map|
# map.connect ':controller', ':controller => 'ARNotations', :requirements => {:format => :xtm2} 
#end

#The more information Occurrence PSI
$MORE_INFORMATION = "http://psi.topicmapslab.de/tmexplore/mi"


#Require helper modules
require "ar_notations/TOXTM2"
require "ar_notations/characteristics"
require "ar_notations/associations"

#Extend ActiveRecord::Base
require "ar_notations/model_core_ext"

#Extend Array
require "ar_notations/array_ext"

 