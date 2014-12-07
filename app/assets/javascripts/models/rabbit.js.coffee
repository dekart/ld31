window.Rabbit = class
  pixelsPerSecond: 100

  constructor: ->
    @created_at = Date.now()

    @x = _.shuffle([-50, canvasSize.width + 50])[0]
    @y = _.random(100, canvasSize.height / 2 - 50) * _.shuffle([-1, 1])[0] + canvasSize.height / 2

    console.log(@y)

    @speed = if @x < 0 then 1 else -1

    @drop_carrot_at = @created_at + Math.abs(_.random(100, canvasSize.width - 100) - @x) / @.pixelsPerSecond * 1000
    @carrot_dropped = false

    @.startMoving()

  startMoving: ->
    @last_position_update_at = Date.now()

  updateState: (current_time)->
    @.updatePosition(current_time)

  updatePosition: (current_time)->
    delta = (current_time - @last_position_update_at) / 1000

    @x += @pixelsPerSecond * delta * @speed

    @last_position_update_at = current_time

  isOutOfBounds: ->
    @x < -75 or @x > canvasSize.width + 75

  dropCarrot: (current_time)->
    if not @carrot_dropped and current_time > @drop_carrot_at
      @carrot_dropped = true

      true
    else
      false