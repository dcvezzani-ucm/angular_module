'use strict';

/* App Module */

/* make sure myAppModules is defined before calling angular.module */
var myAppModules = ['ngRoute'];

var myApp = angular.module('myApp', myAppModules);

myApp.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      otherwise({
        redirectTo: 'phones'
      });
  }]);

