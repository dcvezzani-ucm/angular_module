angular_module
==============

Create framework for an angular module.

Are you a Rails developer new to Angular JS?  I pulled together this project to help myself add Angular JS modules to a Rails application by using a Rails generator.  Each module includes Jasmine e2e and unit tests.  The Angular JS modules are separated by using some logic in a common controller to determine which Angular app will control the page.

Once the modules have been generated, you change things around to your heart's content.

Requirements & Caveats
======================

* Rails 4.x
* Ruby 2.x
* PostgreSql (or another database)

Some of the scripts that are generated by the generator are geared for a Unix-like environment, but are small and simple enough that Windows versions could be easily created.

The included examples are geared toward using PostgreSql, but there is no reason why Oracle or Sqlite3 couldn't be used as well, with a few tweaks to the instructions.

Usage
======

Gemfile

```
gem 'angular_module', :git => 'https://github.com/dcvezzani-ucm/angular_module.git'
```

Run generator

```
rails generate angular_module <module-name>
```

Getting Started
===============

Create the Rails application

```
rails new ang3_app --database=postgresql --skip-test-unit
echo "2.1.0" > ang3_app/.ruby-version
cd ang3_app
```

Create database schema.  There are some nice shortcuts, but if they don't work, you can always add the schema manually.

```
psql -d postgres -U dvezzani

create user ang3_admin with password '<password>';
CREATE DATABASE ang3_development OWNER ang3_admin;
GRANT ALL ON DATABASE ang3_development TO ang3_admin; 

CREATE USER rails with SUPERUSER CREATEDB password '<password>';
CREATE DATABASE ang3_test OWNER rails;
GRANT ALL ON DATABASE ang3_test TO rails; 

```

Verify new schema

```
psql -d ang3_development -U ang3_admin

\d
```

Configure config/database.yml (from terminal)

```
# update config/database.yml
# -e renders newlines (\n)
# '!' escapes the history (!) character
echo -e "development:\n  adapter: postgresql\n  database: ang3_development\n  username: ang3_admin\n  password: pass13"'!'"#\n  encoding: utf8\n  pool: 5\n \ntest: \n  adapter: postgresql\n  database: ang3_test\n  username: rails\n  password: rails.pass13"'!'"#\n  encoding: utf8\n  pool: 5" > config/database.yml
```

Bootstrap the database

```
mkdir db/migrate
bundle exec rake db:migrate db:migrate:status
```

Update the Gemfile

Thanks to the node.js configuration supplied with the generator, Angular JS will manage its own version of JQuery.  And Turbolinks don't work well with Angular JS, so we disable that as well.

```
mvim Gemfile
```

content

```
# Use jquery as the JavaScript library
#gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'

gem "rspec-rails", "~> 2.14.0"
gem "nesty"

#gem "angular_module", :path => "~/rails-app/angular_module"
gem 'angular_module', :git => 'https://github.com/dcvezzani-ucm/angular_module.git'
```

Pull down Rails dependencies and bootstrap RSpec

```
bundle install
rails g rspec:install
```

Create source control repository

```
git init
cp ../clean_start/.gitignore .
git st
git add .
git commit -m "init"
```

Create an Angular JS module by calling the angular_module generator

```
rails generate angular_module pens
```

Pull down Angular JS dependencies using Node.js

If you haven't installed, Node.js yet, do so now before continuing.  If you are on a Mac, homebrew is your friend ('brew update; brew install node').

```
npm install
npm run preprotractor
```

Running the angular_module generator should, among other resources, create a couple of convenience scripts (useful only in Unix-like environments).

* ./start.sh : start up the web server
* ./open.sh : open the home page in a web browser

Run the Tests
=============

Both unit and end-to-end (e2e) tests should be provided with any generated Angular JS module.  

_You will need to have the web application running on the same port as configured in the ```protractor-conf.js``` files for the end-to-end tests to pass._

Run all unit tests

```
npm run test
```

Run particular unit tests (based on Angular JS module name)

```
npm run test-pens
```

Run all local integration tests (e2e)

```
./start.sh
npm run protractor
```

Run particular local integration tests (based on Angular JS module name)

```
npm run protractor-pens
```

Use the Database Instead of the File System
===========================================

Generate the RESTful service
===========================================

```
rails generate scaffold widget name:string
```

Add unique index to migration.

```
    add_index :widgets, :name, unique: true
```

Run migrations

```
rake db:migrate db:migrate:status
RAILS_ENV=test rake db:migrate db:migrate:status
```

Update the associated model spec.

```
mvim spec/models/widget_spec.rb
```

content

```
  require 'rails_helper'

  RSpec.describe Widget, :type => :model do
    before do
      @widget = Widget.new(name: "Momofuku")
    end

    subject { @widget }

    it { should respond_to(:name) }
    it { should be_valid }

    describe "when name is not present" do
      before { @widget.name = " " }
      it { should_not be_valid }
    end

    describe "when name is already taken" do
      before do
        widget_with_same_name = @widget.dup
        widget_with_same_name.name = @widget.name.upcase
        widget_with_same_name.save
      end

      it { should_not be_valid }
    end
  end
```

Run the tests (should fail)

```
rspec spec/models/widget_spec.rb
```

Update the model to satisfy the test

```
mvim app/models/widget.rb
```

content

```
  validates :name, presence: true, uniqueness: { case_sensitive: false }
```

Run the tests again (this time, they should pass)

```
rspec spec/models/widget_spec.rb
```

Generate an Angular JS module

```
rails generate angular_module widgets
```

Seed the database

```
mvim db/seeds.rb
```

content

```
Widget.create!(name: "autotonsorialist")
Widget.create!(name: "dentiloquent")
Widget.create!(name: "gossypiboma")
Widget.create!(name: "jentacular")
Widget.create!(name: "onychophagy")
Widget.create!(name: "recumbentibus")
Widget.create!(name: "witzelsucht")
```

Create default records.

```
rake db:seed
```

Detach the Static Files; Use RESTful calls
===========================================

Remove static widget data

```
rm -rf public/widgets/widgets
```

Update ```app/assets/widgets/widgets/javascripts/services.js```.  This is done to prevent conflict with '/widgets' that is used by Angular JS so that a RESTful service call can still be made to get the JSON packet.

from

```
    return $resource('/widgets/widgets/:widgetId.json', {}, {
      query: {method:'GET', params:{widgetId:'widgets'}, isArray:true}
    });
```

to

```
    return $resource('/widgets/list.json', {}, {
      query: {method:'GET', params:{}, isArray:true}
    });
```

Update ```config/routes.rb```.

from

```
  resources :widgets
```

to

```
  resources :widgets do
    collection do
      get 'list' => 'widgets#index'
    end
  end
```

If you want to view the widgets service via html, you may want to configure the layout to ```'static_pages'```.  This is not necessary for the RESTful service itself.

```
class WidgetsController < ApplicationController
  layout 'static_pages'
  ...
```

Restart the server and navigate to the Angular JS module, "widget".

```
./start.sh
./open.sh /widgets
```

The list shows up, but there aren't any pictures.  Let's fix that, assuming you already have a collection of images that you will associate with the Widget records.


Add Images
===========================================

Add an ```imageUrl``` column to the table.

```
rails g migration add_imageUrl_to_widgets imageUrl:string
rake db:migrate db:migrate:status
RAILS_ENV=test rake db:migrate db:migrate:status
```

In Rails console, associate icons with records.  This example stores the images under the ```public``` directory; the table only stores the relative path to the image icons.

```
imgs = %w{icon-home.png icon-notes.png icon-edit.png icon-binoculars.png icon-music.png icon-film.png icon-compress.png}

cnt = 0
Widget.all.each do |w|
  w.imageUrl = "/widgets/img/widgets/#{imgs[cnt]}"
  w.save!
  cnt += 1
end
```

Update the JSON builders

_app/views/widgets/index.json.jbuilder_

from

```
  json.extract! widget, :id, :name
```

to

```
  json.extract! widget, :id, :name, :imageUrl
```

_app/views/widgets/show.json.jbuilder_

from

```
json.extract! @widget, :id, :name, :created_at, :updated_at
```

to

```
json.extract! @widget, :id, :name, :imageUrl, :created_at, :updated_at
```

Restart the server and navigate to the Angular JS module, "widget".  The images should be showing up now.  Select one of the entries to get the detailed view.  Where are the images for the detailed view?  We can get them with a few more changes.

Add Images to the Detail View
===========================================

_app/assets/widgets/widgets/javascripts/services.js_

from

```
    return $resource('/widgets/widgets/:widgetId.json', {}, {
      query: {method:'GET', params:{widgetId:'widgets'}, isArray:true}
    });
```

to

```
    return $resource('/widgets/:widgetId.json', {}, {
      show: {method:'GET', params:{}, isArray:false, transformResponse: function(data, headersGetter){
        var json = angular.fromJson(data);
        json.images = [json.imageUrl];
        return json;
      }}, 
      list: {method:'GET', url:'/widgets/list.json', params:{}, isArray:true}
    });
```

The RESTful urls are not similar enough to share the same ```$resource``` definition, so they are now separated.  The ```url``` is overridden in the ```list``` action to specify the service to retrieve a list of all widgets.  The ```show``` action transforms the response to include an ```images``` array which is currently not part of the Rails resource json builder, but is referenced in the ```widget-detail.html``` template.


_app/assets/widgets/widgets/javascripts/controllers.js_

from

```
  function($scope, Widget) {
    $scope.widgets = Widget.query();
    $scope.orderProp = 'order';
  }]);

...

  function($scope, $routeParams, Widget) {
    $scope.widget = Widget.get({widgetId: $routeParams.widgetId}, function(widget) {
      $scope.mainImageUrl = widget.images[0];
    });
```

to

```
  function($scope, Widget) {
    $scope.widgets = Widget.list();
    $scope.orderProp = 'order';
  }]);

...

  function($scope, $routeParams, Widget) {
    $scope.widget = Widget.show({widgetId: $routeParams.widgetId}, function(widget) {
      $scope.mainImageUrl = widget.images[0];
    });
```

The ```query``` action name seems too vague.  By changing the actions to ```list``` and ```show```, more clarity is brought to the code.

Restart the server and navigate to the Angular JS module, "widget".  Select one of the entries.  An image should now be displayed on the ```widget-detail.html``` template.

Where to Go From Here
=====================

There are a few things left to make the db-driven "widgets" Angular JS module to be more compliant with the other static-file-driven Angular JS modules.

Missing attributes

* order
* real collection of images (instead of just a single image; create additional model to associate with widgets and update the json builders)

The angular_module Rails generator is not intended to make full-fledged applications out of the box.  It aims to provide a quick framework that can be updated and manipulated and bring consistency to an application that uses Angular JS.

Credits
=======

Much of the framework and examples (especially the unit test and e2e examples) came from here.

* https://www.honeybadger.io/blog/2013/12/11/beginners-guide-to-angular-js-rails

Part of the fun of this endeavor was to learn how to use Rails generators

* http://guides.rubyonrails.org/generators.html
* http://whatisthor.com/
* http://rubydoc.info/github/wycats/thor/master/Thor/Actions
* http://lostechies.com/derickbailey/2011/04/29/writing-a-thor-application/
* http://api.rubyonrails.org/classes/Rails/Generators/Base.html
* http://rubydoc.info/github/wycats/thor/master/Thor/Shell/Basic (~/.rvm/gems/ruby-2.1.0/gems/thor-0.19.1/lib/thor/shell/basic.rb)

I used real words instead of simply using Lorem Ipsum for seeding the Wiget data.
* http://users.tinyonline.co.uk/gswithenbank/unuwords.htm


