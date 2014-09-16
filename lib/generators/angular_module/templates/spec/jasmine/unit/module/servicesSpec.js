'use strict';

describe('service', function() {

  // load modules
  beforeEach(module('{module}App'));

  // Test service availability
  it('check the existence of {module-capitalized} factory', inject(function({module-capitalized}) {
      expect({module-capitalized}).toBeDefined();
    }));
});
