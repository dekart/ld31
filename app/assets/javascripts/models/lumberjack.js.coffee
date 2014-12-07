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
  hitEvery: 1.5

  constructor: (@x, @y)->
    @speed = {x: 0, y: 0}
    @target = {x: 0, y: 0}

    @.startMoving()

  startMoving: ->
    @state = 'moving'
    @last_position_update_at = Date.now()

  startHitting: ->
    @state = 'hitting'
    @last_hit_at = Date.now()

  updateState: (current_time)->
    @.updatePosition(current_time) if @state == 'moving'
    @.updateHitting(current_time) if @state == 'hitting'

  updatePosition: (current_time)->
    delta = (current_time - @last_position_update_at) / 1000

    dX = Math.abs(@target.x - @x)
    dY = Math.abs(@target.y - @y)

    if dX + dY < 5
      @x = @target.x
      @y = @target.y

      @.startHitting(current_time)
    else
      @x += @speed.x * @.pixelsPerSecond * delta
      @y += @speed.y * @.pixelsPerSecond * delta

    @last_position_update_at = current_time

  updateHitting: (current_time)->
    delta = (current_time - @last_hit_at) / 1000

    if delta >= @.hitEvery
      @pine.getHit()

      @last_hit_at = current_time

  aimTo: (@pine)->
    if @x < @pine.x
      @target.x = @pine.x - 40
    else
      @target.x = @pine.x + 40

    @target.y = @pine.y - _.random(-5, 50)

    dX = @target.x - @x
    dY = @target.y - @y

    if Math.abs(dX) > Math.abs(dY)
      @speed.x = Math.sign(dX)
      @speed.y = Math.sign(dY) * Math.abs(dY) / Math.abs(dX)
    else
      @speed.y = Math.sign(dY)
      @speed.x = Math.sign(dX) * Math.abs(dX) / Math.abs(dY)
