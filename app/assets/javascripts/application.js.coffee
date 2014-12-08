#= require jquery
#= require jquery_ujs

#= require underscore
#= require visibility
#= require pixi
#= require tweenjs
#= require fpsmeter

#= require spine

#= require i18n
#= require i18n/translations

#= require sounds2

#= require_tree ./lib
#= require_tree ./helpers
#= require_tree ./controllers
#= require_tree ./models
#= require_tree ./views

#= require preloadjs

#= require preloader

#= require_self

window.Application = class
  start: ->
    $('#preloader').hide()
    $('#canvas_container').css(visibility: 'visible')

    window.current_time = Date.now()

    @game = new GameController()
    @game.show()

$ =>
  window.preloader = new Preloader(=>
    window.application = new Application()
    window.application.start()

    _gaq?.push(['_trackTiming', 'Game Load', 'Start', Date.now() - load_started_at, null, 100])
  )
