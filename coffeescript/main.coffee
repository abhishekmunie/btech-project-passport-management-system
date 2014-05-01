
$ ->
  # enhanceAuto will be false for devices smaller than 720px (i.e. Smartphones or for devices smaller than 1024px and with touchevents (i.e.: Tablets)
  webshims.setOptions 'enhanceAuto', not (matchMedia('(max-device-width: 720px)').matches or matchMedia('(max-device-width: 1024px)').matches and Modernizr.touchevents)

  webshims.setOptions
    extendNative: true
    # 'forms-ext':
    #   types: 'datetime-local range date time number month color'
    forms:
      lazyCustomMessages: false

  webshims.setOptions 'forms',
    addValidators: true
    iVal:
      # handleBubble: 'hide'
      recheckDelay: 300
      submitCheck: true
      # the class of the errorbox, which is normally appended to the fieldWrapper
      errorBoxClass: 'ws-errorbox col-sm-offset-3 col-sm-9'
      # classes to adjust to your CSS/CSS-framework
      errorMessageClass: 'help-block'
      successWrapperClass: 'has-success'
      errorWrapperClass: 'has-error'
      fx: 'slide'
      # add config to find right wrapper
      fieldWrapper: '.form-group'

  # webshims will implement those features in all browsers/devices
  # but will only enhance capable browsers on desktop with custom styleable mediaelement controls and form widgets
  webshims.polyfill 'forms forms-ext details'

  $('.select-to-autocomplete').selectToAutocomplete()
