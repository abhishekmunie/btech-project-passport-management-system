
$ ->
  # enhanceAuto will be false for devices smaller than 720px (i.e. Smartphones or for devices smaller than 1024px and with touchevents (i.e.: Tablets)
  webshims.setOptions 'enhanceAuto', not (matchMedia('(max-device-width: 720px)').matches or matchMedia('(max-device-width: 1024px)').matches and Modernizr.touchevents)

  webshims.setOptions
    extendNative: true
    'forms-ext':
      replaceUI: 'auto'
    'mediaelement':
      replaceUI: 'auto'
    forms:
      lazyCustomMessages: true

  # webshims will implement those features in all browsers/devices
  # but will only enhance capable browsers on desktop with custom styleable mediaelement controls and form widgets
  webshims.polyfill 'forms forms-ext mediaelement'
