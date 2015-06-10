minimatch = require('minimatch')
path = require('path')

noopTimer =
  start: ->
  elapsed: -> 0

colored = (color, str) ->
  if showColors then (ansi[color] + str + ansi.none) else str

plural = (str, count) ->
  if count == 1 then str else str + 's'

repeat = (thing, times) ->
  arr = []
  arr.push(thing) for i in [0...times]
  arr

indent = (str, spaces) ->
  lines = (str || '').split('\n')
  newArr = []
  for i in [0...lines.length]
    newArr.push(repeat(' ', spaces).join('') + lines[i])
  newArr.join('\n')

extend = (target, obj) ->
  for own attrKey, val of obj
    target[attrKey] = val
  target

class ConsoleReporter
  constructor: (options={}) ->
    @print = options.print || (str) -> process.stdout.write(str)

    @basePath = options.basePath ? process.cwd()
    @ignoreStackPatterns = options.ignoreStackPatterns ? []
    unless Array.isArray(@ignoreStackPatterns)
      @ignoreStackPatterns = [@ignoreStackPatterns]
    @ignoreStackPatterns = @ignoreStackPatterns.map (pattern) =>
      path.resolve(@basePath, pattern)

    @specCount = 0
    @failedSpecCount = 0
    @pendingSpecCount = 0
    @passedSpecCount = 0
    @disabledSpecCount = 0

    @_suites = {}
    @_specs = {}

    @topLevelSuites = []
    @stackFilter = options.stackFilter ||
      @defaultStackFilter.bind(this)

    @onComplete = options.onComplete

  jasmineStarted: ({totalSpecs}) ->
    @print('## Start\n')

  jasmineDone: ->
    @print('\n')
    @print('## Result\n')
    res = "**`#{@specCount}` specs**, **`#{@passedSpecCount}` passed specs**, " +
      "**`#{@failedSpecCount}` failures**, **`#{@pendingSpecCount}` pending specs**\n"
    @print(res)

    unless @failedSpecCount is 0
      @print('## Failures\n')
      @walkTree(suite, 0) for suite in @topLevelSuites

    @onComplete?(@failedSpecCount is 0)

  pathIsIgnore: (path) ->
    for pattern in @ignoreStackPatterns
      if minimatch(path, pattern)
        return true
    false

  if process.platform is 'win32'
    PATH_REG = /\b(\w:\\)?([\w\.-]+\\)*[\w\.-]+(?=:\d+:\d+)/
  else
    PATH_REG = /\b(\/)?([\w\.-]+\/)*[\w\.-]+(?=:\d+:\d+)/

  NODE_MODULE_REG = /^\w+.js$/
  defaultStackFilter: (stack) ->
    lines = stack.split('\n')
    resLines = []
    for stackLine in lines
      console.log stackLine
      unless matchRes = PATH_REG.exec(stackLine)
        resLines.push stackLine
      else
        file = matchRes[0]
        console.log file
        # reject nodejs module and ignore path
        if not NODE_MODULE_REG.test(file) and not @pathIsIgnore(file)
          # replace the abslute path with the relative path
          # console.log path.relative(@basePath, file)
          resLines.push stackLine.replace(file, path.relative(@basePath, file))
    resLines.join('\n')

  printDepth: (depth, str) ->
    space = ('  ' for i in [0...depth]).join('')
    lines = str.split('\n')
    unless lines[lines.length - 1]
      endWithNewLine = true
      lines.pop()
    str = ("#{space}#{line}" for line in lines).join('\n')
    str += '\n' if endWithNewLine
    @print str

  printStack: (depth, stack) ->
    space = ('  ' for i in [0...depth]).join('')
    lines = stack.split('\n')
    lines[0] = "*Stack*: `#{lines[0]}`"
    lines.splice(1, 0, '```js')
    lines.push('```\n')
    @print ("#{space}#{line}" for line in lines).join('\n')

  specFailureDetails: (result, depth) ->
    @printDepth(depth, "* **#{result.description}**\n")

    for failedExpectation in result.failedExpectations
      @printDepth(depth + 1, "* *Message*: `#{failedExpectation.message}`\n")
      @printStack(depth + 2, @stackFilter(failedExpectation.stack))

  suiteFailureDetails: (result, depth) ->
    for failedExpectation in result.failedExpectations
      @printDepth(depth, '*An error was thrown in an afterAll*')
      @printDepth(depth, '*AfterAll*: ' + failedExpectation.message)
      @printStack(depth, @stackFilter(failedExpectation.stack))

  walkTree: (suite, depth) ->
    return unless suite._status is 'failed'
    unless suite.children?
      @specFailureDetails(suite, depth)
    else
      @printDepth(depth, "* **#{suite.description}**\n")
      @walkTree(child, depth + 1) for child in suite.children
      @suiteFailureDetails(suite, depth + 1)

  specStarted: (result) ->
    spec = @getSpec(result)
    spec._suite = @currentSuite
    @currentSuite.children.push spec

  specDone: (result) ->
    spec = @getSpec(result)
    if spec.status is 'failed'
      spec._status = spec._suite._status = 'failed'
    @specCount++

    switch result.status
      when 'pending'
        @pendingSpecCount++
        @print('P')
      when 'passed'
        @passedSpecCount++
        @print('.')
      when 'disabled'
        @disabledSpecCount++
        @print('D')
      when 'failed'
        @failedSpecCount++
        @print('F')

  suiteStarted: (result) ->
    suite = @getSuite(result)
    suite.children = []
    if @currentSuite
      @currentSuite.children.push(suite)
    else
      @topLevelSuites.push(suite)
    suite._parent = @currentSuite
    @currentSuite = suite

  suiteDone: (result) ->
    suite = @getSuite(result)
    @currentSuite = suite._parent
    if suite.status is 'failed'
      suite._status = 'failed'
    if suite._status is 'failed' and @currentSuite
      @currentSuite._status = 'failed'

  getSpec: (spec) ->
    @_specs[spec.id] = extend(@_specs[spec.id] || {}, spec)

  getSuite: (suite) ->
    @_suites[suite.id] = extend(@_suites[suite.id] or {}, suite)

module.exports = exports = ConsoleReporter
