'use strict';

/* http://docs.angularjs.org/guide/dev_guide.e2e-testing */

describe('{module-capitalized} App', function() {

  it('should redirect root ("/{module}") to /{module}/#/list', function() {
    browser.get('/{module}');
    browser.getLocationAbsUrl().then(function(url) {
        expect(url.split('#')[1]).toBe('/list');
      });
  });


  describe('{module-capitalized} list view', function() {

    beforeEach(function() {
      browser.get('/{module}/#/list');
    });


    it('should filter the {module-singular} list as user types into the search box', function() {

      var {module-singular}List = element.all(by.repeater('{module-singular} in {module}'));
      var query = element(by.model('query'));

      expect({module-singular}List.count()).toBe(3);

      query.clear();
      query.sendKeys('{module-capitalized} 2');
      expect({module-singular}List.count()).toBe(1);
    });


    it('should filter the {module-singular} list as user types into the search box', function() {

      var {module-singular}List = element.all(by.repeater('{module-singular} in {module}'));
      var query = element(by.model('query'));

      expect({module-singular}List.count()).toBe(3);

      query.clear();
      query.sendKeys('{module-capitalized} 2');
      expect({module-singular}List.count()).toBe(1);
    });


    describe('{module-capitalized} list view', function() {

      var {module-singular}NameColumn;
      var query;

      function getNames() {
        return {module-singular}NameColumn.map(function(elm) {
          return elm.getText();
        });
      }

      beforeEach(function() {
        {module-singular}NameColumn = element.all(by.repeater('{module-singular} in {module}').column('{{{module-singular}.name}}'));
        query = element(by.model('query'));
      });

      it('should filter the {module-singular} list by any associated terms', function() {
        query.sendKeys('Three');

        expect(getNames()).toEqual([
          '{module-capitalized} 3'
        ]);
      });

      it('should be possible to control {module-singular} order via the drop down select box', function() {
        query.clear();

        element(by.model('orderProp')).element(by.css('option[value="name"]')).click();

        expect(getNames()).toEqual([
          "{module-capitalized} 1", 
          "{module-capitalized} 2",
          "{module-capitalized} 3"
        ]);
      });

    });

    it('should render {module-singular} specific links', function() {
      var query = element(by.model('query'));
      query.sendKeys('{module-singular} 1');
      element.all(by.css('.{module} li a')).first().click();
      browser.getLocationAbsUrl().then(function(url) {
        expect(url.split('#')[1]).toBe('/show/{module-singular}-1');
      });
    });
  });


  describe('{module-capitalized} detail view', function() {

    beforeEach(function() {
      browser.get('/{module}/#/show/{module-singular}-1');
    });


    it('should display {module-singular}-1 page', function() {
      expect(element(by.binding('{module-singular}.name')).getText()).toBe('{module-capitalized} 1');
    });


    it('should display the first {module-singular} image as the main {module-singular} image', function() {
      expect(element(by.css('img.{module-singular}.active')).getAttribute('src')).toMatch(/img\/{module}\/{module-singular}-1.0.jpg/);
    });


    it('should swap main image if a thumbnail image is clicked on', function() {
      element(by.css('.{module-singular}-thumbs li:nth-child(3) img')).click();
      expect(element(by.css('img.{module-singular}.active')).getAttribute('src')).toMatch(/img\/{module}\/{module-singular}-1.2.jpg/);

      element(by.css('.{module-singular}-thumbs li:nth-child(1) img')).click();
      expect(element(by.css('img.{module-singular}.active')).getAttribute('src')).toMatch(/img\/{module}\/{module-singular}-1.0.jpg/);
    });
  });
});
