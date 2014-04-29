# Avoid `console` errors in browsers that lack a console.
(->
  noop = ->
  methods = [
    'assert', 'clear', 'count', 'debug', 'dir', 'dirxml', 'error',
    'exception', 'group', 'groupCollapsed', 'groupEnd', 'info', 'log',
    'markTimeline', 'profile', 'profileEnd', 'table', 'time', 'timeEnd',
    'timeStamp', 'trace', 'warn'
  ]
  length = methods.length
  console = (window.console = window.console or {})

  while (length--)
    method = methods[length]

    # Only stub undefined methods.
    unless console[method]
      console[method] = noop

  undefined
)()

if navigator.userAgent.match(/IEMobile\/10\.0/)
  msViewportStyle = document.createElement 'style'
  msViewportStyle.appendChild document.createTextNode '@-ms-viewport{width:auto!important}'
  document.querySelector('head').appendChild(msViewportStyle)
