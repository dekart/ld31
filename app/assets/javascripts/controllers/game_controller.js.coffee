#= require ./game_animator

window.GameController = class extends BaseController
  className: 'game_screen'

  constructor: ->
    super

    @mouse_position = {x: 0, y: 0}

    @animator = new GameAnimator(@)

    @pine = new Pine()

    @snowman = new Snowman(canvasSize.width / 2 - 50, canvasSize.height / 2)

    @lumberjacks = []
    @lumberjack_emitted_at = 0
    @lumberjacks_every = 2

    @shooting = false
    @snowballs = []
    @snowball_emitted_at = 0
    @snowballs_every = 0.4

  show: ->
    @.setupEventListeners()

    @.render()

  setupEventListeners: ->
    $(document).on('keydown', @.onKeyDown)
    $(document).on('keyup', @.onKeyUp)

    @el.on('mousedown touchstart', 'canvas', @.onTouchStart)
    @el.on('mousemove touchmove', 'canvas', @.onTouchMove)
    @el.on('mouseup touchend', 'canvas', @.onTouchEnd)

  render: ->
    @animator.deactivate()

    @el.appendTo('#game')

    @animator.activate()

  updateState: ->
    # Logic goes here
    current_time = Date.now()

    @.emitLumberjacks(current_time)
    @.emitSnowballs(current_time)

    @snowman.updateState(current_time)

    for snowball in @snowballs
      snowball.updateState(current_time)

    @.checkSnowballCollisions()
    @.checkSnowballExpiration()

    @.checkLumberjackHealth()

    for jack in @lumberjacks
      jack.updateState(current_time)

    if @pine.health <= 0
      @.finish()

  updateMousePosition: (event)->
    touchpoint = if event.originalEvent.touches? then event.originalEvent.touches[0] else event

    if touchpoint
      @canvas_offset ?= $(@animator.renderer.view).offset()

      @mouse_position.x = touchpoint.clientX - @canvas_offset.left
      @mouse_position.y = touchpoint.clientY - @canvas_offset.top

  onTouchStart: (e)=>
    e.preventDefault()

    @.updateMousePosition(e)

    # Logic goes here

    @shooting = true

  onTouchMove: (e)=>
    e.preventDefault()

    @.updateMousePosition(e)

    # Logic goes here

  onTouchEnd: (e)=>
    e.preventDefault()

    @.updateMousePosition(e)

    # Logic goes here

    @shooting = false

  onKeyDown: (e)=>
    switch e.keyCode
      when 37, 65 # left
        @snowman.speed.x = -1
      when 38, 87 # up
        @snowman.speed.y = -1
      when 39, 68 #right
        @snowman.speed.x = 1
      when 40, 83 # down
        @snowman.speed.y = 1
      else
        process_default = true

    e.preventDefault() unless process_default?

  onKeyUp: (e)=>
    switch e.keyCode
      when 37, 39, 65, 68 #left, right
        @snowman.speed.x = 0
      when 38, 40, 87, 83 # up, down
        @snowman.speed.y = 0
      else
        process_default = true

    e.preventDefault() unless process_default?

  finish: ->
    @animator.deactivate()

    console.log('Game over!')

  emitLumberjacks: (current_time)->
    if current_time > @lumberjack_emitted_at + @lumberjacks_every * 1000
      jack = new Lumberjack(Lumberjack.randomSpawnPosition()...)
      jack.aimTo(@pine)

      @lumberjacks.push(jack)

      @animator.addLumberjack(jack)

      @lumberjack_emitted_at = current_time

  checkLumberjackHealth: ->
    killed = []

    for lumberjack in @lumberjacks
      killed.push(lumberjack) if lumberjack.health <= 0

    for lumberjack in killed
      @.removeLumberjack(lumberjack)

  removeLumberjack: (lumberjack)->
    @animator.removeLumberjack(lumberjack)

    @lumberjacks.splice(@lumberjacks.indexOf(lumberjack), 1)

  emitSnowballs: (current_time)->
    if @shooting and current_time > @snowball_emitted_at + @snowballs_every * 1000
      snowball = new Snowball(@snowman.x, @snowman.y)
      snowball.aimTo(@mouse_position)

      @snowballs.push(snowball)

      @animator.addSnowball(snowball)

      @snowball_emitted_at = current_time

  checkSnowballCollisions: ->
    hits = []

    for snowball in @snowballs
      for lumberjack in @lumberjacks
        hits.push([snowball, lumberjack]) if snowball.inHitRange(lumberjack)

    for [snowball, lumberjack] in hits
      @.removeSnowball(snowball)

      lumberjack.takeHit()

  checkSnowballExpiration: ->
    expired = []

    for snowball in @snowballs
      expired.push(snowball) if snowball.isExpired()

    for snowball in expired
      @.removeSnowball(snowball)

  removeSnowball: (snowball)->
    @animator.removeSnowball(snowball)

    @snowballs.splice(@snowballs.indexOf(snowball), 1)
