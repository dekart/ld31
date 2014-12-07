window.Snowball = class
  pixelsPerSecond: 200
  lifetime: 1.5

  constructor: (@x, @y)->
    @speed = {x: 0, y: 0}

    @created_at = Date.now()

    @.startMoving()

  startMoving: ->
    @last_position_update_at = Date.now()

  updateState: (current_time)->
    @.updatePosition(current_time)

  updatePosition: (current_time)->
    delta = (current_time - @last_position_update_at) / 1000

    @x += @speed.x * @.pixelsPerSecond * delta
    @y += @speed.y * @.pixelsPerSecond * delta

    @last_position_update_at = current_time

  aimTo: (position)->
    target = {}

    if @x < position.x
      target.x = position.x - 40
    else
      target.x = position.x + 40

    target.y = position.y - _.random(-5, 50)

    dx = target.x - @x
    dy = target.y - @y

    if Math.abs(dx) > Math.abs(dy)
      @speed.x = Math.sign(dx)
      @speed.y = Math.sign(dy) * Math.abs(dy) / Math.abs(dx)
    else
      @speed.y = Math.sign(dy)
      @speed.x = Math.sign(dx) * Math.abs(dx) / Math.abs(dy)

  inHitRange: (target)->
    [tx, ty, tw, th] = target.getHitZone()

    Math.abs(tx - @x) <= tw and Math.abs(ty - @y) <= th

  isExpired: ->
    Date.now() > @created_at + @lifetime * 1000