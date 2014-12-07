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

    @health = 3

    @.startMoving()

  startMoving: ->
    @state = 'moving'
    @last_position_update_at = Date.now()

  startHitting: ->
    @state = 'hitting'
    @last_hit_at = Date.now()

  updateState: ->
    @.updatePosition() if @state == 'moving'
    @.updateHitting() if @state == 'hitting'

  updatePosition: ->
    delta = (current_time - @last_position_update_at) / 1000

    dx = Math.abs(@target.x - @x)
    dy = Math.abs(@target.y - @y)

    if dx + dy < 5
      @x = @target.x
      @y = @target.y

      @.startHitting()
    else
      @x += @speed.x * delta
      @y += @speed.y * delta

    @last_position_update_at = current_time

  updateHitting: ->
    delta = (current_time - @last_hit_at) / 1000

    if delta >= @.hitEvery
      @pine.takeHit()

      @last_hit_at = current_time

  aimTo: (@pine)->
    if @x < @pine.x
      @target.x = @pine.x - 40
    else
      @target.x = @pine.x + 40

    @target.y = @pine.y - _.random(-5, 50)

    dx = @target.x - @x
    dy = @target.y - @y

    @speed.x = Math.sqrt(
      Math.pow(@.pixelsPerSecond, 2) / (1 + Math.pow(dy / dx , 2) )
    ) * Math.sign(dx)

    @speed.y = Math.sqrt(
      Math.pow(@.pixelsPerSecond, 2) / (1 + Math.pow(dx / dy , 2) )
    ) * Math.sign(dy)

    @angle = Math.atan2(dx, -dy) * 180 / Math.PI
    @angle += 360 if @angle < 0

  getHitZone: ->
    [
      @x,
      @y - 24,
      15,
      25
    ]

  canHitSnowman: (snowman)->
    Math.abs(snowman.x - @x) < 15 and Math.abs(snowman.y - @y) < 25

  takeHit: ->
    @health -= 1