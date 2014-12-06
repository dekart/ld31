#= require ./animator

window.GameAnimator = class extends Animator
  movementAnimationSpeed: 300

  # loops: # [StartFrame, EndFrame, Speed]
    # object: {frames: [0,  3], speed: 0.2}

  constructor: (controller)->
    super(controller)

    @background_layer = new PIXI.DisplayObjectContainer()
    @object_layer = new PIXI.DisplayObjectContainer()

    @stage.addChild(@background_layer)
    @stage.addChild(@object_layer)

    @object_sprite = null

  activate: ->
    return unless super

    @.addSprites()

    @.attachRendererTo(@controller.el)

  addSprites: ->
    @background_sprite = PIXI.Sprite.fromImage(preloader.paths.background)

    @background_layer.addChild(@background_sprite)

    @snowman_sprite = @.createSnowmanSprite()

    for i in [0..70]
      @object_layer.addChild(@.createTreeSprite())

    @object_layer.addChild(@snowman_sprite)


    @sprites_added = true

  animate: =>
    unless @paused_at
      @controller.updateState()

      @.updateSpriteStates()

    super

  updateSpriteStates: ->
    return unless @sprites_added

    @snowman_sprite.position.x = @.objectToSceneX(@controller.snowman.x)
    @snowman_sprite.position.y = @.objectToSceneY(@controller.snowman.y)

    speedX = @controller.snowman.speed.x
    speedY = @controller.snowman.speed.y

    for key, sprite of @snowman_sprite.directions
      sprite.visible = switch key
        when 'down_left'
          speedX == -1 and speedY == 1
        when 'left'
          speedX == -1 and speedY == 0
        when 'up_left'
          speedX == -1 and speedY == -1
        when 'up'
          speedX == 0 and speedY == -1
        when 'up_right'
          speedX == 1 and speedY == -1
        when 'right'
          speedX == 1 and speedY == 0
        when 'down_right'
          speedX == 1 and speedY == 1
        else
          speedX == 0 and (speedY == 1 or speedY == 0)


  createSnowmanSprite: ->
    container = new PIXI.DisplayObjectContainer()
    container.position.x = @.objectToSceneX(@controller.snowman.x)
    container.position.y = @.objectToSceneY(@controller.snowman.y)

    container.directions = {}

    container.directions.down = PIXI.Sprite.fromFrame("snowman_down.png")
    container.directions.down_left = PIXI.Sprite.fromFrame("snowman_down_side.png")
    container.directions.left = PIXI.Sprite.fromFrame("snowman_side.png")
    container.directions.up_left = PIXI.Sprite.fromFrame("snowman_up_side.png")
    container.directions.up = PIXI.Sprite.fromFrame("snowman_up.png")
    container.directions.up_right = PIXI.Sprite.fromFrame("snowman_up_side.png")
    container.directions.up_right.scale.x = -1
    container.directions.right = PIXI.Sprite.fromFrame("snowman_side.png")
    container.directions.right.scale.x = -1
    container.directions.down_right = PIXI.Sprite.fromFrame("snowman_down_side.png")
    container.directions.down_right.scale.x = -1

    for key, sprite of container.directions
      sprite.anchor.x = 0.5
      sprite.anchor.y = 1
      sprite.visible = false

      container.addChild(sprite)

    container

  createLumberjackSprite: (object)->
    sprite = PIXI.Sprite.fromFrame("lumberjack_up_side.png")
    sprite.position.x = @.objectToSceneX(100)
    sprite.position.y = @.objectToSceneY(100)
    sprite.anchor.x = 0.5
    sprite.anchor.y = 0.5
    sprite.source = object
    sprite

  createRabbitSprite: (object)->
    sprite = PIXI.Sprite.fromFrame("rabbit_sitting.png")
    sprite.position.x = @.objectToSceneX(200)
    sprite.position.y = @.objectToSceneY(200)
    sprite.anchor.x = 0.5
    sprite.anchor.y = 0.5
    sprite.source = object
    sprite

  createTreeSprite: ->
    sprite = PIXI.Sprite.fromFrame("tree.png")
    sprite.position.x = @.objectToSceneX(_.random(0, canvasSize.width))
    sprite.position.y = @.objectToSceneY(_.random(0, canvasSize.height))
    sprite.anchor.x = 0.5
    sprite.anchor.y = 1
    sprite.scale.y = _.random(0, 10) * 0.03 + 0.7
    sprite.scale.x = sprite.scale.y * _.shuffle([-1, 1])[0]
    sprite

  objectToSceneX: (coordinate)->
    coordinate # Offset logic goes here

  objectToSceneY: (coordinate)->
    coordinate # Offset logic goes here

  mousePositionToCanvas: (position)->
    position

  animateObjectMovement: ()->
    @movement_animation_started = Date.now()

    # Animation logic start

  isMovementAnimationFinished: ->
    Date.now() - @movement_animation_started > @.movementAnimationSpeed


  movementAnimationProgress: ->
    (Date.now() - @movement_animation_started) / @.movementAnimationSpeed


  isBlockingAnimationInProgress: ->
    @movement_animation_started

