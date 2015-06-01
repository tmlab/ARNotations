ARNotations
===========

ARNotations is a Ruby on Rails plugin to map any kind of ActiveRecord model
to a Topic Map Fragment, providing the ability to expose them TMExplore
compatible using REST.

Dependencies
===========
Currently ARNotations depends on the libxml gem.

Installation
===========
If you are using ruby, please install "libxml-ruby" or "libxml-jruby" if you use JRuby.
For Rails 2.x use `script/plugin install git://github.com/tmlab/ARNotations.git` to
install in your current Rails Application.
For actually arnotating your Application have a look at the examples provided.

Example
=======

Some examples how to "arnotate" your model:
Give some typical ActiveRecord class like:

    class Person < ActiveRecord::Base
       validates_presence_of :firstname, :lastname, :identifier
       has_and_belongs_to_many :publications, :class_name => 'Publication', :join_table => :authors_publications
       translates :description
    end

You would simply add:

## ...for things that should be represented as Topic Names
     has_name  :lastname, :psi => "http://xmlns.com/foaf/0.1/familyName"
     has_name  :firstname , :psi => "http://xmlns.com/foaf/0.1/givenName"

## ...for things that should be represented as Topic Occurrences

     has_occurrence :description

## ...for associations
     
     has_association :publications,
        {:name => "authorship", :psi => "http://psi.topicmapslab.de/tml/authorship"},
        {:name => "has author", :psi => "http://psi.topicmapslab.de/tml/work"},
        {:name => "is author of", :psi => "http://psi.topicmapslab.de/tml/author"}

to your model.
In your controller e.g. the PeopleController
add `format.xtm {render :xml =>  @person.to_xtm2}` to your `show` Method, and
`format.xtm {"render :xml =>  @people = Person.all.to_xtm2 }`
to your `index` Method, and given you use the default RoR routing (with `.:format`)
or request content type "application/xtm+xml" those Methods will return you some
nice explorable Topic Map fragments.

Copyright (c) 2010 Daniel Exner <exner@informatik.uni-leipzig.de>, released under the MIT license
