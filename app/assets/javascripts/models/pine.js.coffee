window.Pine = class
  constructor: ->
    @x = canvasSize.width / 2
    @y = canvasSize.height / 2

    @health = 20

  getHit: ->
    @health -= 1
