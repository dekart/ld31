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

  updateState: (current_time)->
    @.updatePosition(current_time) if @state == 'moving'
    @.updateHitting(current_time) if @state == 'hitting'

  updatePosition: (current_time)->
    delta = (current_time - @last_position_update_at) / 1000

    dx = Math.abs(@target.x - @x)
    dy = Math.abs(@target.y - @y)

    if dx + dy < 5
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

    if Math.abs(dx) > Math.abs(dy)
      @speed.x = Math.sign(dx)
      @speed.y = Math.sign(dy) * Math.abs(dy) / Math.abs(dx)
    else
      @speed.y = Math.sign(dy)
      @speed.x = Math.sign(dx) * Math.abs(dx) / Math.abs(dy)

  getHitZone: ->
    [
      @x,
      @y - 24,
      14,
      20
    ]

  takeHit: ->
    @health -= 1