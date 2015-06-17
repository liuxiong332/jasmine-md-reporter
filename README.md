# jasmine-md-reporter
The jasmine test reporter that output markdown

This reporter only support jasmine 2.0, so you should require `jasmine-npm`.

# how to use

The following code will use *markdown reporter* to output the jasmine result.

```coffee
jasmineFn = require 'jasmine'

MdReporter = require 'jasmine-md-reporter'
reporter = new MdReporter
  basePath: path.resolve(__dirname, '..')
  ignoreStackPatterns: 'node_modules/jasmine/**'
  print: (str) -> process.stdout.write(str)
  onComplete: (allPassed) ->

jasmineEnv = jasmine.getEnv()
jasmineEnv.addReporter(reporter)

require '<test-file-path>'
jasmineEnv.execute()
```
