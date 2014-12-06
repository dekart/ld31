window.Snowman = class
  pixelsPerSecond: 100

  constructor: (@x, @y)->
    @last_position_update_at = Date.now()

    @speed = {x: 0, y: 0}

  updateState: ->
    current_time = Date.now()

    @.updatePosition(current_time)

  updatePosition: (current_time)->
    delta = (current_time - @last_position_update_at) / 1000

    @x += @speed.x * @.pixelsPerSecond * delta
    @y += @speed.y * @.pixelsPerSecond * delta

    @last_position_update_at = current_time