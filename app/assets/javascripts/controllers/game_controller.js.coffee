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
    @lumberjacks_every = 3

    @shooting = false
    @snowballs = []
    @snowball_emitted_at = 0
    @snowballs_every = 0.4

    @rabbit = null
    @rabbit_emitted_at = 0
    @rabbit_every = 5

    @carrots = []

    @sounds = new Sounds2()

    @lumberjacks_hit = 0
    @snowballs_thrown = 0

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
    return if @finished

    # Logic goes here
    window.current_time = Date.now()

    # Snowman checks

    @snowman.updateState()

    @.checkCarrotCollection()
    @.checkCarrotDelivery()

    # Snowball checks

    @.emitSnowballs()

    for snowball in @snowballs
      snowball.updateState()

    @.checkSnowballCollisions()
    @.checkSnowballExpiration()

    # Lumberjack checks

    @.emitLumberjacks()
    @.checkLumberjackHealth()

    for jack in @lumberjacks
      jack.updateState()

    @.checkSnowmanHit()

    @last_walk_sound_at ?= current_time

    if @rabbit and current_time > @last_walk_sound_at + 500
      @sounds.playSound('walk')

      @last_walk_sound_at = current_time

    # Rabbit checks

    @.emitRabbit()

    @rabbit?.updateState()

    @.checkRabbitExpiration()

    @.emitCarrots()
    @.checkCarrotExpiration()

    if @pine.health <= 0
      @.finish('chopped')
    else if @snowman.health <= 0
      @.finish('destroyed')
    else if @pine.isBeautiful()
      @.finish('beautified')

    if @pine.got_hit
      @animator.hitPine()
      @sounds.playSound('chop')

  updateMousePosition: (event)->
    touchpoint = if event.originalEvent.touches? then event.originalEvent.touches[0] else event

    if touchpoint
      if touchpoint.offsetX?
        @mouse_position.x = touchpoint.offsetX
        @mouse_position.y = touchpoint.offsetY
      else
        @offset ?= $(@el).offset()

        @mouse_position.x = touchpoint.pageX - @offset.left
        @mouse_position.y = touchpoint.pageY - @offset.top

  onTouchStart: (e)=>
    e.preventDefault()

    @.updateMousePosition(e)

    # Logic goes here

    if @finished and 360 < @mouse_position.x < 650 and 560 < @mouse_position.y < 680
      document.location = document.location
    else
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

  finish: (result)->
    @finished = true

    switch result
      when 'chopped'
        @animator.displayGameOver('Tree has been chopped!')
      when 'destroyed'
        @animator.displayGameOver('Snowman has been destroyed!')
      when 'beautified'
        @animator.displayVictory('Merry Christmas!')

  emitLumberjacks: ->
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

      @lumberjacks_hit += 1

  removeLumberjack: (lumberjack)->
    @animator.removeLumberjack(lumberjack)

    @lumberjacks.splice(@lumberjacks.indexOf(lumberjack), 1)

  emitSnowballs: ->
    if @shooting and current_time > @snowball_emitted_at + @snowballs_every * 1000
      snowball = new Snowball(@snowman.x, @snowman.y - 25)
      snowball.aimTo(@mouse_position)

      @snowballs.push(snowball)

      @animator.addSnowball(snowball)

      @snowball_emitted_at = current_time

      @sounds.playSound('throw')

      @snowballs_thrown += 1

  checkSnowballCollisions: ->
    hits = []

    for snowball in @snowballs
      for lumberjack in @lumberjacks
        hits.push([snowball, lumberjack]) if snowball.inHitRange(lumberjack)

    for [snowball, lumberjack] in hits
      @animator.explodeSnowball(snowball)
      @.removeSnowball(snowball)

      lumberjack.takeHit()

      @sounds.playSound('snowball_hit')

  checkSnowballExpiration: ->
    expired = []

    for snowball in @snowballs
      expired.push(snowball) if snowball.isExpired()

    for snowball in expired
      @.removeSnowball(snowball)

  removeSnowball: (snowball)->
    @animator.removeSnowball(snowball)

    @snowballs.splice(@snowballs.indexOf(snowball), 1)

  emitRabbit: ->
    if not @rabbit and current_time > @rabbit_emitted_at + @rabbit_every * 1000
      @rabbit_emitted_at = current_time

      @rabbit = new Rabbit()

      @animator.addRabbit(@rabbit)

  checkRabbitExpiration: ->
    if @rabbit?.isOutOfBounds()
      @rabbit_emitted_at = current_time

      @animator.removeRabbit()

      @rabbit = null

  emitCarrots: ->
    if @rabbit?.dropCarrot()
      carrot = new Carrot(@rabbit.x, @rabbit.y)

      @animator.addCarrot(carrot)

      @carrots.push(carrot)

      @sounds.playSound('drop')

  checkCarrotExpiration: ->
    expired = []

    for carrot in @carrots
      if carrot.isExpired()
        expired.push(carrot)
      else
        carrot.checkExpirationState()

    for carrot in expired
      @.removeCarrot(carrot)

  removeCarrot: (carrot)->
    @animator.removeCarrot(carrot)

    @carrots.splice(@carrots.indexOf(carrot), 1)

  checkCarrotCollection: ->
    collected = []

    for carrot in @carrots
      if @snowman.takeCarrot(carrot)
        collected.push(carrot)

    for carrot in collected
      @.removeCarrot(carrot)

    if collected.length > 0
      @sounds.playSound('pickup')

  checkCarrotDelivery: ->
    if @snowman.carrots > 0 and @pine.y - 75 < @snowman.y < @pine.y + 25 and @pine.x - 45 < @snowman.x < @pine.x + 45
      @pine.carrots += @snowman.carrots

      @snowman.deliverCarrots()

      @sounds.playSound('deliver')


  checkSnowmanHit: ->
    return if @snowman.took_hit_at?

    for lumberjack in @lumberjacks
      if lumberjack.canHitSnowman(@snowman)
        @snowman.takeHit()
        @animator.hitSnowman()