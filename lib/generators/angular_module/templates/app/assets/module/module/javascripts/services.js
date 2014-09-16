'use strict';

/* Services */

var {module}Services = angular.module('{module}Services', ['ngResource']);

{module}Services.factory('{module-capitalized}', ['$resource',
  function($resource){
    return $resource('/{module}/{module}/:{module-singular}Id.json', {}, {
      query: {method:'GET', params:{{module-singular}Id:'{module}'}, isArray:true}
    });
  }]);
