noopTimer =
  start: ->
  elapsed: -> 0

printNewline = ->
  print('\n')

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

defaultStackFilter = (stack) ->
  stack.split('\n').filter (stackLine) ->
    stackLine.indexOf(jasmineCorePath) is -1
  .join('\n')

extend = (target, obj) ->
  for own attrKey, val of obj
    target[attrKey] = val
  target

class ConsoleReporter
  constructor: (options={}) ->
    @print = options.print || (str) -> console.log(str)
    @jasmineCorePath = options.jasmineCorePath

    @specCount = 0
    @failedSpecCount = 0
    @pendingSpecCount = 0
    @passedSpecCount = 0
    @disabledSpecCount = 0

    @_suites = {}
    @_specs = {}

    @topLevelSuites = []
    @stackFilter = options.stackFilter || defaultStackFilter

    @onComplete = options.onComplete

  jasmineStarted: ({totalSpecs}) ->
    console.log('hello world')

  jasmineDone: ->
    @print('## Result')
    res = "#{@specCount} specs, #{@passedSpecCount} passed specs, " +
      "#{@failedSpecCount} failures, #{@pendingSpecCount} pending specs"
    @print(res)

    unless @failedSpecCount is 0
      @print('## Failures')
      @walkTree(suite, 0) for suite in @topLevelSuites

    @onComplete?(@failedSpecCount is 0)

  printDepth: (depth, str) ->
    space = ('  ' for i in [0...depth]).join()
    @print("#{space}#{str}")

  specFailureDetails: (result, failedSpecNumber) ->
    return
    printNewline()
    print(failedSpecNumber + ') ')
    print(result.fullName)

    for i in [0...result.failedExpectations.length]
      failedExpectation = result.failedExpectations[i]
      printNewline()
      print(indent('Message:', 2))
      printNewline()
      print(colored('red', indent(failedExpectation.message, 4)))
      printNewline()
      print(indent('Stack:', 2))
      printNewline()
      print(indent(stackFilter(failedExpectation.stack), 4))

    printNewline()

  suiteFailureDetails: (result) ->
    return
    for i in [0...result.failedExpectations.length]
      printNewline()
      print(colored('red', 'An error was thrown in an afterAll'))
      printNewline()
      print(colored('red', 'AfterAll ' + result.failedExpectations[i].message))
    printNewline()

  walkTree: (suite, depth) ->
    return unless suite._status is 'failed'
    unless suite.children?
      @specFailureDetails(suite)
    else
      @printDepth(depth, "* #{suite.description}\n")
      @walkTree(child, depth + 1) for child in suite.children
      @suiteFailureDetails(suite)

  specStarted: (result) ->
    console.log('specStarted: ', result)
    return
    spec = @getSpec(result)
    spec._suite = @currentSuite
    @currentSuite.children.push spec

  specDone: (result) ->
    console.log('specDone: ', result)
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
    console.log 'suiteStarted: '
    suite = @getSuite(result)
    console.log suite
    suite.children = []
    if @currentSuite
      @currentSuite.children.push(suite)
    else
      @topLevelSuites.push(suite)
    suite._parent = @currentSuite
    @currentSuite = suite

  suiteDone: (result) ->
    console.log 'suiteDone: ', result
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
