window.Snowman = class
  speed:
    x: 0
    y: 0
    multiplier: 1.2

  constructor: (@x, @y)->

  updateState: ->
    @.updatePosition()

  updatePosition: ->
    @x += @.speed.x * @.speed.multiplier
    @y += @.speed.y * @.speed.multiplier