window.Snowball = class
  pixelsPerSecond: 200
  lifetime: 1.5

  constructor: (@x, @y)->
    @speed = {x: 0, y: 0}

    @created_at = Date.now()

    @.startMoving()

  startMoving: ->
    @last_position_update_at = Date.now()

  updateState: ->
    @.updatePosition()

  updatePosition: ->
    delta = (current_time - @last_position_update_at) / 1000

    @x += @speed.x * delta
    @y += @speed.y * delta

    @last_position_update_at = current_time

  aimTo: (position)->
    dx = position.x - @x
    dy = position.y - @y

    @speed.x = Math.sqrt(
      Math.pow(@.pixelsPerSecond, 2) / (1 + Math.pow(dy / dx , 2) )
    ) * Math.sign(dx)

    @speed.y = Math.sqrt(
      Math.pow(@.pixelsPerSecond, 2) / (1 + Math.pow(dx / dy , 2) )
    ) * Math.sign(dy)


  inHitRange: (target)->
    [tx, ty, tw, th] = target.getHitZone()

    Math.abs(tx - @x) <= tw and Math.abs(ty - @y) <= th

  isExpired: ->
    Date.now() > @created_at + @lifetime * 1000