window.Lumberjack = class
  @randomSpawnPosition: ->
    switch _.shuffle(['top', 'bottom', 'left', 'right'])[0]
      when 'top'
        [_.random(0, canvasSize.width), -50]
      when 'bottom'
        [_.random(0, canvasSize.width), canvasSize.height + 50]
      when 'left'
        [-50, _.random(0, canvasSize.height)]
      when 'right'
        [canvasSize.width + 50, _.random(0, canvasSize.height)]

  pixelsPerSecond: 50

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

  aimTo: (targetX, targetY)->
    dX = targetX - @x
    dY = targetY - @y

    if Math.abs(dX) > Math.abs(dY)
      @speed.x = Math.sign(dX)
      @speed.y = Math.sign(dY) * Math.abs(dY) / Math.abs(dX)
    else
      @speed.y = Math.sign(dY)
      @speed.x = Math.sign(dX) * Math.abs(dX) / Math.abs(dY)
