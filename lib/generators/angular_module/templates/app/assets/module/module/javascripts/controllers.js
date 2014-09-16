'use strict';

/* Controllers */

var {module}Controllers = angular.module('{module}Controllers', []);

{module}Controllers.controller('{module-capitalized}ListCtrl', ['$scope', '{module-capitalized}',
  function($scope, {module-capitalized}) {
    $scope.{module} = {module-capitalized}.query();
    $scope.orderProp = 'order';
  }]);

{module}Controllers.controller('{module-capitalized}DetailCtrl', ['$scope', '$routeParams', '{module-capitalized}',
  function($scope, $routeParams, {module-capitalized}) {
    $scope.{module-singular} = {module-capitalized}.get({{module-singular}Id: $routeParams.{module-singular}Id}, function({module-singular}) {
      $scope.mainImageUrl = {module-singular}.images[0];
    });

    $scope.setImage = function(imageUrl) {
      $scope.mainImageUrl = imageUrl;
    }
  }]);
