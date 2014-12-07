window.Snowman = class
  pixelsPerSecond: 100
  hitFallbackTime: 0.3

  constructor: (@x, @y)->
    @last_position_update_at = Date.now()

    @speed = {x: 0, y: 0}
    @fallback = {x: 0, y: 0}

    @carrots = 0
    @health = 5

    @took_hit_at = null

  updateState: ->
    @.updatePosition()

  updatePosition: ->
    delta = (current_time - @last_position_update_at) / 1000

    if @took_hit_at?

      @x += @fallback.x * @.pixelsPerSecond * delta
      @y += @fallback.y * @.pixelsPerSecond * delta
    else
      @x += @speed.x * @.pixelsPerSecond * delta
      @y += @speed.y * @.pixelsPerSecond * delta

    @last_position_update_at = current_time

    if current_time > @took_hit_at + @.hitFallbackTime * 1000
      @took_hit_at = null

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

  takeHit: ->
    @health -= 1
    @took_hit_at = current_time

    @fallback.x = _.shuffle([-2, -1, 1, 2])[0]
    @fallback.y = _.shuffle([-2, -1, 1, 2])[0]

    console.log(@health)
