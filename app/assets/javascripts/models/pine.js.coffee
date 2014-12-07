window.Pine = class
  constructor: ->
    @x = canvasSize.width / 2
    @y = canvasSize.height / 2

    @health = 50

    @got_hit = false

    @carrots = 0

  takeHit: ->
    @health -= 1

    @got_hit = true

  isBeautiful: ->
    @carrots >= 10