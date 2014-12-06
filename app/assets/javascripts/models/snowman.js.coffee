window.Snowman = class
  speed:
    x: 0
    y: 0
    perSecond: 100

  constructor: (@x, @y)->
    @last_position_update_at = Date.now()

  updateState: ->
    current_time = Date.now()

    @.updatePosition(current_time)

  updatePosition: (current_time)->
    delta = (current_time - @last_position_update_at) / 1000

    @x += @.speed.x * @.speed.perSecond * delta
    @y += @.speed.y * @.speed.perSecond * delta

    @last_position_update_at = current_time