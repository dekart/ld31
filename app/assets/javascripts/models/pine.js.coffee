window.Pine = class
  constructor: ->
    @x = canvasSize.width / 2
    @y = canvasSize.height / 2

    @health = 20

    @got_hit = false

  takeHit: ->
    @health -= 1

    @got_hit = true