'use strict';

/* App Module */

var {module}App = angular.module('{module}App', [
  'ngRoute',

  '{module}Animations',
  '{module}Controllers',
  '{module}Filters',
  '{module}Services', 
]);

{module}App.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/list', {
        templateUrl: '/{module}/partials/{module-singular}-list.html',
        controller: '{module-capitalized}ListCtrl'
      }).
      when('/show/:{module-singular}Id', {
        templateUrl: '/{module}/partials/{module-singular}-detail.html',
        controller: '{module-capitalized}DetailCtrl'
      }).
      otherwise({
        redirectTo: '/list'
      });
  }]);

