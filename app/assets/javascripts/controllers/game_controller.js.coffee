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

    for i in [0 .. 10]
      jack = new Lumberjack(Lumberjack.randomSpawnPosition()...)
      jack.aimTo(canvasSize.width / 2, canvasSize.height / 2)

      @lumberjacks.push(jack)

    jack = new Lumberjack(10, 10)
    jack.aimTo(canvasSize.width / 2, canvasSize.height / 2)

    @lumberjacks.push(jack)


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
    @snowman.updateState()

    for jack in @lumberjacks
      jack.updateState()

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

  onTouchMove: (e)=>
    e.preventDefault()

    @.updateMousePosition(e)

    # Logic goes here

  onTouchEnd: (e)=>
    e.preventDefault()

    @.updateMousePosition(e)

    # Logic goes here

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

    alert('Done!')

