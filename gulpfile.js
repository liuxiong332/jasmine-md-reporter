'use strict';

var gulp   = require('gulp');
var jasmine = require('gulp-jasmine');
var TerminalReporter = require('./lib/terminal-reporter').TerminalReporter;

require('coffee-script/register');

gulp.task('test', function () {
  return gulp.src('./spec/*.js')
    .pipe(jasmine({
      includeStackTrace: false,
    }));
});


function OutFileInfo() {}

OutFileInfo.prototype.removeOutFile = function() {
  var fs = require('fs');
  var path = require('path');

  var outPath = path.resolve(__dirname, 'out');
  if(!fs.existsSync(outPath)) {
    fs.mkdirSync(outPath);
  }

  this.outFilePath = outFile = path.resolve(outPath, 'log.md');
  if(fs.existsSync(outFile)) {
    fs.unlinkSync(outFile);
  }
};

OutFileInfo.prototype.print = function(str) {
  fs.appendFileSync(this.outFilePath, str);
};

gulp.task('exercies', function() {
  var ConsoleReporter = require('./lib/reporter');
  var info = new OutFileInfo
  info.removeOutFile()
  return gulp.src('./spec/fixture/*.js')
    .pipe(jasmine({
      includeStackTrace: false,
      reporter: new ConsoleReporter({
        print: info.print.bind(info),
        ignoreStackPatterns: 'node_modules/**'
      }),
    }));
});

gulp.task('default', ['test']);
