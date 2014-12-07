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

    @lumberjack_sprites = []
    @snowball_sprites = []

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

    speedx = @controller.snowman.speed.x
    speedy = @controller.snowman.speed.y

    for key, sprite of @snowman_sprite.directions
      sprite.visible = switch key
        when 'down_left'
          speedx == -1 and speedy == 1
        when 'left'
          speedx == -1 and speedy == 0
        when 'up_left'
          speedx == -1 and speedy == -1
        when 'up'
          speedx == 0 and speedy == -1
        when 'up_right'
          speedx == 1 and speedy == -1
        when 'right'
          speedx == 1 and speedy == 0
        when 'down_right'
          speedx == 1 and speedy == 1
        else
          speedx == 0 and (speedy == 1 or speedy == 0)

    for sprite in @lumberjack_sprites
      sprite.position.x = @.objectToSceneX(sprite.source.x)
      sprite.position.y = @.objectToSceneX(sprite.source.y)

    for sprite in @snowball_sprites
      sprite.position.x = @.objectToSceneX(sprite.source.x)
      sprite.position.y = @.objectToSceneX(sprite.source.y)

    if @controller.pine.got_hit
      animation = new PineHitAnimation()
      animation.start(@pine_sprite)

      @controller.pine.got_hit = false

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

    # top right
    if 22.5 < jack.angle <= 67.5
      container.walk_sprite = PIXI.Sprite.fromFrame("lumberjack_up_side.png")
      container.walk_sprite.scale.x = -1
    # right
    else if 67.5 < jack.angle <= 112.5
      container.walk_sprite = PIXI.Sprite.fromFrame("lumberjack_side.png")
      container.walk_sprite.scale.x = -1
    # bottom right
    else if 112.5 < jack.angle <= 157.5
      container.walk_sprite = PIXI.Sprite.fromFrame("lumberjack_down_side.png")
      container.walk_sprite.scale.x = -1
    # bottom
    else if 157.5 < jack.angle <= 202.5
      container.walk_sprite = PIXI.Sprite.fromFrame("lumberjack_down.png")
    # bottom left
    else if 202.5 < jack.angle <= 247.5
      container.walk_sprite = PIXI.Sprite.fromFrame("lumberjack_down_side.png")
    # left
    else if 247.5 < jack.angle <= 292.5
      container.walk_sprite = PIXI.Sprite.fromFrame("lumberjack_side.png")
    # top left
    else if 292.5 < jack.angle <= 337.5
      container.walk_sprite = PIXI.Sprite.fromFrame("lumberjack_up_side.png")
    # top
    else
      container.walk_sprite = PIXI.Sprite.fromFrame("lumberjack_up.png")

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

    dx = sprite.position.x - canvasSize.width / 2
    dy = sprite.position.y - canvasSize.height / 2

    if Math.abs(dx) < 75 and Math.abs(dy) < 75
      sprite.position.x += _.random(50, 100) * Math.sign(dx)
      sprite.position.y += _.random(50, 100) * Math.sign(dy)

    sprite.anchor.x = 0.5
    sprite.anchor.y = 1
    sprite.scale.y = _.random(0, 10) * 0.03 + 0.7
    sprite.scale.x = sprite.scale.y * _.shuffle([-1, 1])[0]
    sprite

  createSnowballSprite: (object)->
    sprite = PIXI.Sprite.fromFrame("snowball.png")
    sprite.position.x = @.objectToSceneX(object.x)
    sprite.position.y = @.objectToSceneY(object.y)
    sprite.anchor.x = 0.5
    sprite.anchor.y = 0.5
    sprite.source = object
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

  removeLumberjack: (lumberjack)->
    sprite = _.detect(@lumberjack_sprites, (s)=> s.source == lumberjack)

    @lumberjack_sprites.splice(@lumberjack_sprites.indexOf(sprite), 1)

    @object_layer.removeChild(sprite)

  addSnowball: (snowball)->
    sprite = @.createSnowballSprite(snowball)

    @snowball_sprites.push(sprite)

    @object_layer.addChild(sprite)

  removeSnowball: (snowball)->
    sprite = _.detect(@snowball_sprites, (s)=> s.source == snowball)

    @snowball_sprites.splice(@snowball_sprites.indexOf(sprite), 1)

    @object_layer.removeChild(sprite)