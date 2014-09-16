'use strict';

/* jasmine specs for controllers go here */
describe('{module-capitalized} controllers', function() {

  beforeEach(function(){
    this.addMatchers({
      toEqualData: function(expected) {
        return angular.equals(this.actual, expected);
      }
    });
  });

  beforeEach(module('{module}App'));
  beforeEach(module('{module}Services'));

  describe('{module-capitalized}ListCtrl', function(){
    var scope, ctrl, $httpBackend;

    beforeEach(inject(function(_$httpBackend_, $rootScope, $controller) {
      $httpBackend = _$httpBackend_;
      $httpBackend.expectGET('/{module}/{module}/{module}.json').
          respond([{name: 'Nexus S'}, {name: 'Motorola DROID'}]);

      scope = $rootScope.$new();
      ctrl = $controller('{module-capitalized}ListCtrl', {$scope: scope});
    }));


    it('should create "{module}" model with 2 {module} fetched from xhr', function() {
      expect(scope.{module}).toEqualData([]);
      $httpBackend.flush();

      expect(scope.{module}).toEqualData(
          [{name: 'Nexus S'}, {name: 'Motorola DROID'}]);
    });


    it('should set the default value of orderProp model', function() {
      expect(scope.orderProp).toBe('order');
    });
  });


  describe('{module-capitalized}DetailCtrl', function(){
    var scope, $httpBackend, ctrl,
        xyz{module-capitalized}Data = function() {
          return {
            name: '{module-singular} xyz',
                images: ['image/url1.png', 'image/url2.png']
          }
        };


    beforeEach(inject(function(_$httpBackend_, $rootScope, $routeParams, $controller) {
      $httpBackend = _$httpBackend_;
      $httpBackend.expectGET('/{module}/{module}/xyz.json').respond(xyz{module-capitalized}Data());

      $routeParams.{module-singular}Id = 'xyz';
      scope = $rootScope.$new();
      ctrl = $controller('{module-capitalized}DetailCtrl', {$scope: scope});
    }));


    it('should fetch {module-singular} detail', function() {
      expect(scope.{module-singular}).toEqualData({});
      $httpBackend.flush();

      expect(scope.{module-singular}).toEqualData(xyz{module-capitalized}Data());
    });
  });
});
