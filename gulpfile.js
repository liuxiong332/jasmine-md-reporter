'use strict';

var gulp   = require('gulp');
var jasmine = require('gulp-jasmine');
var TerminalReporter = require('./lib/terminal-reporter').TerminalReporter;

require('coffee-script/register');
var ConsoleReporter = require('./lib/reporter');

gulp.task('test', function () {
  return gulp.src('./spec/*.js')
    .pipe(jasmine({
      includeStackTrace: false,
      // reporter: new TerminalReporter({verbosity: 2, showStack: true}),
      reporter: new ConsoleReporter,
    }));
});

gulp.task('default', ['test']);
