#= require ./animator

window.GameAnimator = class extends Animator
  movementAnimationSpeed: 300
  carrotPositions:
    [
      [25, -27], [11, -30], [-4, -34], [-16, -37]
      [17, -45], [3, -52], [-9, -61],
      [11, -65], [3, -74], [-5, -85]

    ]

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

    @rabbit_sprite = null

    @carrot_sprites = []

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
    direction = @controller.snowman.direction()

    for key, sprite of @snowman_sprite.directions
      sprite.visible = (direction == key)

    switch @controller.snowman.carrots
      when 2
        @snowman_sprite.carrot1.visible = true
        @snowman_sprite.carrot2.visible = true
      when 1
        @snowman_sprite.carrot1.visible = true
        @snowman_sprite.carrot2.visible = false
      when 0
        @snowman_sprite.carrot1.visible = false
        @snowman_sprite.carrot2.visible = false

    # Drop carrot positions to their defaults
    @snowman_sprite.carrot1.position.x = -20
    @snowman_sprite.carrot2.position.y = -35

    switch direction
      when 'up_right', 'down_left'
        @snowman_sprite.carrot2.position.y = -25
      when 'left', 'right'
        @snowman_sprite.carrot1.position.x = 0
        @snowman_sprite.carrot2.visible = false

    for sprite in @lumberjack_sprites
      sprite.position.x = @.objectToSceneX(sprite.source.x)
      sprite.position.y = @.objectToSceneY(sprite.source.y)

    for sprite in @snowball_sprites
      sprite.position.x = @.objectToSceneX(sprite.source.x)
      sprite.position.y = @.objectToSceneY(sprite.source.y)

    if @rabbit_sprite?
      @rabbit_sprite.position.x = @.objectToSceneX(@rabbit_sprite.source.x)
      @rabbit_sprite.position.y = @.objectToSceneY(@rabbit_sprite.source.y)

    for sprite in @carrot_sprites
      sprite.position.y = @.objectToSceneY(sprite.source.y + 2 * Math.sin((Date.now() - sprite.source.created_at) / 500))

    if @controller.pine.got_hit
      animation = new PineHitAnimation()
      animation.start(@pine_sprite)

      @controller.pine.got_hit = false

    for carrot, i in @pine_sprite.carrots
      carrot.visible = (@controller.pine.carrots > i)

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

    container.carrots = []

    for i in [0 .. 9]
      carrot = PIXI.Sprite.fromFrame("carrot.png")
      carrot.position.set(@.carrotPositions[i]...)
      carrot.anchor.set(0.5)
      carrot.scale.set(0.7)
      carrot.rotation = _.random(-30, 30) * Math.PI / 180

      container.carrots.push(carrot)

      container.addChild(carrot)

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

    container.carrot1 = PIXI.Sprite.fromFrame('carrot.png')
    container.carrot1.position.y = -30
    container.carrot1.scale.set(0.5)
    container.carrot1.visible = false

    container.carrot2 = PIXI.Sprite.fromFrame('carrot.png')
    container.carrot2.position.x = 15
    container.carrot2.scale.set(0.5)
    container.carrot2.visible = false

    container.addChild(container.carrot1)
    container.addChild(container.carrot2)

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


  addRabbit: (rabbit)->
    @rabbit_sprite = @.createRabbitSprite(rabbit)

    @object_layer.addChild(@rabbit_sprite)

  removeRabbit: ->
    @object_layer.removeChild(@rabbit_sprite)

    @rabbit_sprite = null


  createRabbitSprite: (object)->
    sprite = PIXI.Sprite.fromFrame("rabbit_sitting.png")
    sprite.position.x = @.objectToSceneX(object.x)
    sprite.position.y = @.objectToSceneY(object.y)
    sprite.anchor.x = 0.5
    sprite.anchor.y = 1
    sprite.scale.x = -1 if object.speed > 0
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


  addCarrot: (carrot)->
    sprite = @.createCarrotSprite(carrot)

    @carrot_sprites.push(sprite)

    @object_layer.addChild(sprite)

  createCarrotSprite: (object)->
    sprite = PIXI.Sprite.fromFrame("carrot.png")
    sprite.position.x = @.objectToSceneX(object.x)
    sprite.position.y = @.objectToSceneY(object.y)
    sprite.anchor.x = 0.5
    sprite.anchor.y = 1
    sprite.source = object
    sprite.rotation = _.shuffle([-60, -45, -30, 30, 45, 60])[0] * Math.PI / 180
    sprite

  removeCarrot: (carrot)->
    sprite = _.detect(@carrot_sprites, (s)=> s.source == carrot)

    @carrot_sprites.splice(@carrot_sprites.indexOf(sprite), 1)

    @object_layer.removeChild(sprite)

  deliverCarrots: ->
