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

  activate: ->
    return unless super

    @.addSprites()

    @.attachRendererTo(@controller.el)

  addSprites: ->
    @background_sprite = PIXI.Sprite.fromImage(preloader.paths.background)

    @background_layer.addChild(@background_sprite)

    @pine_sprite = @.createPineSprite()

    @object_layer.addChild(@pine_sprite)

    @snowman_sprite = @.createSnowmanSprite()

    for i in [0..70]
      @object_layer.addChild(@.createTreeSprite())

    @object_layer.addChild(@snowman_sprite)

    @lumberjack_sprites = []

    for jack in @controller.lumberjacks
      @.addLumberjack(jack)

    @sprites_added = true

  animate: =>
    unless @paused_at
      @controller.updateState()

      @.updateSpriteStates()
      @.sortSpritesByLayers()

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

    for sprite in @lumberjack_sprites
      sprite.position.x = @.objectToSceneX(sprite.source.x)
      sprite.position.y = @.objectToSceneX(sprite.source.y)


  sortSpritesByLayers: ->
    for sprite, index in _.sortBy(@object_layer.children, (c)-> c.position.y)
      @object_layer.setChildIndex(sprite, index) unless @object_layer.getChildIndex(sprite) == index

  createPineSprite: ->
    container = new PIXI.DisplayObjectContainer()
    container.position.x = @.objectToSceneX(@controller.pine.x)
    container.position.y = @.objectToSceneY(@controller.pine.y)

    container.tree_sprite = PIXI.Sprite.fromFrame("pine.png")
    container.tree_sprite.anchor.x = 0.5
    container.tree_sprite.anchor.y = 1

    container.addChild(container.tree_sprite)

    container

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

  createLumberjackSprite: (jack)->
    container = new PIXI.DisplayObjectContainer()
    container.position.x = @.objectToSceneX(jack.x)
    container.position.y = @.objectToSceneY(jack.y)
    container.source = jack

    # down
    if jack.speed.y == 1 and -0.3 < jack.speed.x < 0.3
      container.walk_sprite = PIXI.Sprite.fromFrame("lumberjack_down.png")
    # up
    else if jack.speed.y == -1 and -0.3 < jack.speed.x < 0.3
      container.walk_sprite = PIXI.Sprite.fromFrame("lumberjack_up.png")
    # left
    else if jack.speed.x == -1 and -0.3 < jack.speed.y < 0.3
      container.walk_sprite = PIXI.Sprite.fromFrame("lumberjack_side.png")
    # right
    else if jack.speed.x == 1 and -0.3 < jack.speed.y < 0.3
      container.walk_sprite = PIXI.Sprite.fromFrame("lumberjack_side.png")
      container.walk_sprite.scale.x = -1
    # top left
    else if jack.speed.x == -1 and jack.speed.y < -0.3 or jack.speed.y == -1 and jack.speed.x < -0.3
      container.walk_sprite = PIXI.Sprite.fromFrame("lumberjack_up_side.png")
    # bottom left
    else if jack.speed.x == -1 and jack.speed.y > 0.3 or jack.speed.y == 1 and jack.speed.x < -0.3
      container.walk_sprite = PIXI.Sprite.fromFrame("lumberjack_down_side.png")
    # top right
    else if jack.speed.x == 1 and jack.speed.y < -0.3 or jack.speed.y == -1 and jack.speed.x > 0.3
      container.walk_sprite = PIXI.Sprite.fromFrame("lumberjack_up_side.png")
      container.walk_sprite.scale.x = -1
    # bottom right
    else if jack.speed.x == 1 and jack.speed.y > 0.3 or jack.speed.y == 1 and jack.speed.x > 0.3
      container.walk_sprite = PIXI.Sprite.fromFrame("lumberjack_down_side.png")
      container.walk_sprite.scale.x = -1

    container.walk_sprite.anchor.x = 0.5
    container.walk_sprite.anchor.y = 1

    container.addChild(container.walk_sprite)

    container

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

    dX = sprite.position.x - canvasSize.width / 2
    dY = sprite.position.y - canvasSize.height / 2

    if Math.abs(dX) < 75 and Math.abs(dY) < 75
      sprite.position.x += _.random(50, 100) * Math.sign(dX)
      sprite.position.y += _.random(50, 100) * Math.sign(dY)

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


  addLumberjack: (jack)->
    sprite = @.createLumberjackSprite(jack)

    @lumberjack_sprites.push(sprite)

    @object_layer.addChild(sprite)