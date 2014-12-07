window.Snowman = class
  pixelsPerSecond: 100

  constructor: (@x, @y)->
    @last_position_update_at = Date.now()

    @speed = {x: 0, y: 0}

    @carrots = 0

  updateState: (current_time)->
    @.updatePosition(current_time)

  updatePosition: (current_time)->
    delta = (current_time - @last_position_update_at) / 1000

    @x += @speed.x * @.pixelsPerSecond * delta
    @y += @speed.y * @.pixelsPerSecond * delta

    @last_position_update_at = current_time

  takeCarrot: (carrot)->
    dx = Math.abs(carrot.x - @x)
    dy = Math.abs(carrot.y - @y)

    if dx + dy < 30 and @carrots < 2
      @carrots += 1

      true
    else
      false

  deliverCarrots: ->
    @carrots = 0

  direction: ->
    if @speed.x == -1 and @speed.y == 1
      'down_left'
    else if @speed.x == -1 and @speed.y == 0
      'left'
    else if @speed.x == -1 and @speed.y == -1
      'up_left'
    else if @speed.x == 0 and @speed.y == -1
      'up'
    else if @speed.x == 1 and @speed.y == -1
      'up_right'
    else if @speed.x == 1 and @speed.y == 0
      'right'
    else if @speed.x == 1 and @speed.y == 1
      'down_right'
    else
      'down'
