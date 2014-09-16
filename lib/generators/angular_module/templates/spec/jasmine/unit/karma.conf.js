module.exports = function(config){
  config.set({

    basePath : '../../../',

    files: [
      'vendor/assets/angular/javascripts/angular.js',
      'vendor/assets/angular/javascripts/angular-route.js',
      'vendor/assets/angular/javascripts/angular-resource.js',
      'vendor/assets/angular/javascripts/angular-animate.js',
      'vendor/assets/angular/javascripts/angular-mocks.js',

      'spec/jasmine/unit/module/*pec.js'
    ], 

    autoWatch : true,

    frameworks: ['jasmine'],

    browsers : ['Chrome'],

    plugins : [
            'karma-chrome-launcher',
            'karma-firefox-launcher',
            'karma-jasmine', 
            'karma-coffee-preprocessor'
            ],

    preprocessors: {
      '**/*.coffee': 'coffee'
    }, 

    junitReporter : {
      outputFile: 'test_out/unit.xml',
      suite: 'unit'
    }

  });
};
