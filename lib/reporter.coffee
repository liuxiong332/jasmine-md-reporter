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

specFailureDetails = (result, failedSpecNumber) ->
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

suiteFailureDetails = (result) ->
  for i in [0...result.failedExpectations.length]
    printNewline()
    print(colored('red', 'An error was thrown in an afterAll'))
    printNewline()
    print(colored('red', 'AfterAll ' + result.failedExpectations[i].message))
  printNewline()

pendingSpecDetails = (result, pendingSpecNumber) ->
  printNewline()
  printNewline()
  print(pendingSpecNumber + ') ')
  print(result.fullName)
  printNewline()
  pendingReason = "No reason given"
  if result.pendingReason && result.pendingReason isnt ''
    pendingReason = result.pendingReason

  print(indent(colored('yellow', pendingReason), 2))
  printNewline()

class ConsoleReporter
  constructor: (options) ->
    @print = options.print
    @jasmineCorePath = options.jasmineCorePath

    @failedSpecs = []
    @pendingSpecs = []
    @failedSuites = []
    @stackFilter = options.stackFilter || defaultStackFilter

    @onComplete = options.onComplete

  jasmineStarted: ({totalSpecs}) ->
    @specCount = 0
    print('# Started')
    printNewline()

  jasmineDone: ->
    printNewline()
    printNewline()
    if @failedSpecs.length > 0
      print('Failures:')

    for i in [0...failedSpecs.length]
      specFailureDetails(failedSpecs[i], i + 1)

    print("Pending:") if pendingSpecs.length > 0

    for i in [0...pendingSpecs.length]
      pendingSpecDetails(pendingSpecs[i], i + 1)

    if specCount > 0
      printNewline()

      specCounts = specCount + ' ' + plural('spec', specCount) + ', ' +
        failureCount + ' ' + plural('failure', failureCount)

      if pendingSpecs.length
        specCounts += ', ' + pendingSpecs.length + ' pending ' + plural('spec', pendingSpecs.length);

      print(specCounts)
    else
      print('No specs found')

    printNewline()
    seconds = timer.elapsed() / 1000
    print('Finished in ' + seconds + ' ' + plural('second', seconds))
    printNewline()

    for i in [0...failedSuites.length]
      suiteFailureDetails(failedSuites[i])

    onComplete(failureCount is 0)

  specDone: (result) ->
    @specCount++

    switch result.status
      when 'pending'
        @pendingSpecs.push(result)
        @print('-')
      when 'passed'
        @print('.')
      when 'failed'
        @failedSpecs.push(result)
        @print('F')

  suiteDone: (result) ->
    if result.failedExpectations?.length > 0
      @failedSuites.push(result)

module.exports = exports = ConsoleReporter
