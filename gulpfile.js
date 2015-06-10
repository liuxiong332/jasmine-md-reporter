'use strict';

var gulp   = require('gulp');
var jasmine = require('gulp-jasmine');
var TerminalReporter = require('./lib/terminal-reporter').TerminalReporter;

require('coffee-script/register');
var ConsoleReporter = require('./lib/reporter');
var fs = require('fs');

if(fs.existsSync('./wo.md')) {
  fs.unlinkSync('./wo.md')
}
function print(str) {
  fs.appendFileSync('./wo.md', str);
}

gulp.task('test', function () {
  return gulp.src('./spec/*.js')
    .pipe(jasmine({
      includeStackTrace: false,
      // reporter: new TerminalReporter({verbosity: 2, showStack: true}),
      reporter: new ConsoleReporter({print: print, ignoreStackPatterns: 'node_modules/**'}),
    }));
});

gulp.task('default', ['test']);
