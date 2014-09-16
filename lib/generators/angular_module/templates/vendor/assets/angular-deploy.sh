#!/bin/bash

mkdir -p vendor/assets/angular/stylesheets
mkdir -p vendor/assets/angular/javascripts

cp ./bower_components/bootstrap/dist/css/bootstrap.css vendor/assets/angular/stylesheets

cp ./bower_components/jquery/jquery.js vendor/assets/angular/javascripts
cp ./bower_components/angular/angular.js vendor/assets/angular/javascripts
cp ./bower_components/angular-animate/angular-animate.js vendor/assets/angular/javascripts
cp ./bower_components/angular-mocks/angular-mocks.js vendor/assets/angular/javascripts
cp ./bower_components/angular-resource/angular-resource.js vendor/assets/angular/javascripts
cp ./bower_components/angular-route/angular-route.js vendor/assets/angular/javascripts

echo -e "// This is a manifest file that'll be compiled into application.js, which will include all the files\n// listed below.\n//\n// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,\n// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.\n//\n// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the\n// compiled file.\n//\n// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details\n// about supported directives.\n\n//= require ./javascripts/jquery\n//= require ./javascripts/angular\n//= require_tree ./javascripts\n\n//= require_tree .\n" > vendor/assets/angular/angular.js

echo -e "/*\n * This is a manifest file that'll be compiled into application.css, which will include all the files\n * listed below.\n *\n * Any CSS and SCSS file within this directory, lib/assets/stylesheets, vendor/assets/stylesheets,\n * or vendor/assets/stylesheets of plugins, if any, can be referenced here using a relative path.\n *\n * You're free to add application-wide styles to this file and they'll appear at the top of the\n * compiled file, but it's generally better to create a new file per style scope.\n *\n *= require_tree ./stylesheets/\n *= require_tree .\n */\n" > vendor/assets/angular/angular.css

