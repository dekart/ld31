#= require ./animator

window.GameAnimator = class extends Animator
  movementAnimationSpeed: 300
  carrotPositions:
    [
      [25, -27], [11, -30], [-4, -34], [-16, -37]
      [17, -45], [3, -52], [-9, -61],
      [11, -65], [3, -74], [-5, -85]

    ]

  loops: # [StartFrame, EndFrame, Speed]
    rabbit: {frames: [0,  4], speed: 0.25}
    snowman_up: {frames: [0,  3], speed: 0.2}
    snowman_down: {frames: [0,  3], speed: 0.2}
    snowman_side: {frames: [0,  3], speed: 0.2}
    snowman_up_side: {frames: [0,  3], speed: 0.2}
    snowman_down_side: {frames: [0,  3], speed: 0.2}
    lumberjack_up: {frames: [0,  3], speed: 0.2}
    lumberjack_down: {frames: [0,  3], speed: 0.2}
    lumberjack_side: {frames: [0,  3], speed: 0.2}
    lumberjack_down_side: {frames: [0,  3], speed: 0.2}
    lumberjack_up_side: {frames: [0,  3], speed: 0.2}
    lumberjack_chop: {frames: [0,  5], speed: 0.3}

  constructor: (controller)->
    super(controller)

    @background_layer = new PIXI.DisplayObjectContainer()
    @object_layer = new PIXI.DisplayObjectContainer()
    @particle_layer = new PIXI.DisplayObjectContainer()
    @snowflake_layer = new SnowflakeEmitter()

    @game_over_screen = new PIXI.DisplayObjectContainer()
    @game_over_screen.visible = false
    @game_over_background = PIXI.Sprite.fromImage('$assetPath(game_over.png)')
    @game_over_background.position.set(60, 50)
    @game_over_screen.addChild(@game_over_background)

    @victory_screen = new PIXI.DisplayObjectContainer()
    @victory_screen.visible = false
    @victory_background = PIXI.Sprite.fromImage('$assetPath(victory.png)')
    @victory_background.position.set(60, 50)
    @victory_screen.addChild(@victory_background)

    @lumberjacks_hit_text = new PIXI.Text('0', font: 'bold 50px Arial', fill: '#003cff', dropShadow: true)
    @lumberjacks_hit_text.position.set(720, 285)
    @snowballs_thrown_text = new PIXI.Text('0', font: 'bold 50px Arial', fill: '#003cff', dropShadow: true)
    @snowballs_thrown_text.position.set(720, 400)


    @game_layer = new PIXI.DisplayObjectContainer()

    @game_layer.addChild(@background_layer)
    @game_layer.addChild(@object_layer)
    @game_layer.addChild(@particle_layer)
    @game_layer.addChild(@snowflake_layer)

    @stage.addChild(@game_layer)
    @stage.addChild(@game_over_screen)
    @stage.addChild(@victory_screen)

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

    if speedx == 0 and speedy == 0
      @snowman_sprite.directions.down.gotoAndStop(0)
    else
      @snowman_sprite.directions.down.play()

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

      sprite.walk_sprite.visible = (sprite.source.state == 'moving')
      sprite.chop_sprite.visible = (sprite.source.state == 'hitting')
      sprite.chop_sprite.scale.x = (if sprite.source.x < sprite.source.pine.x then -1 else 1)

    for sprite in @snowball_sprites
      sprite.position.x = @.objectToSceneX(sprite.source.x)
      sprite.position.y = @.objectToSceneY(sprite.source.y)

    if @rabbit_sprite?
      @rabbit_sprite.position.x = @.objectToSceneX(@rabbit_sprite.source.x)
      @rabbit_sprite.position.y = @.objectToSceneY(@rabbit_sprite.source.y)

    for sprite in @carrot_sprites
      sprite.position.y = @.objectToSceneY(sprite.source.y + 2 * Math.sin((current_time - sprite.source.created_at) / 500))

      if sprite.source.expiring_soon
        sprite.alpha = 0.5 + 0.5 * Math.sin((current_time - sprite.source.created_at) / 70)

    if @controller.pine.got_hit
      animation = new PineHitAnimation()
      animation.start(@pine_sprite)

      @controller.pine.got_hit = false

    for carrot, i in @pine_sprite.carrots
      carrot.visible = (@controller.pine.carrots > i)

    @snowflake_layer.update()

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

    container.directions.down = new PIXI.MovieClip(@.loops["snowman_down"].textures)
    container.directions.down.animationSpeed = @.loops["snowman_down"].speed
    container.directions.down.play()

    container.directions.down_left = new PIXI.MovieClip(@.loops["snowman_down_side"].textures)
    container.directions.down_left.animationSpeed = @.loops["snowman_down_side"].speed
    container.directions.down_left.play()

    container.directions.left = new PIXI.MovieClip(@.loops["snowman_side"].textures)
    container.directions.left.animationSpeed = @.loops["snowman_side"].speed
    container.directions.left.play()

    container.directions.up_left = new PIXI.MovieClip(@.loops["snowman_up_side"].textures)
    container.directions.up_left.animationSpeed = @.loops["snowman_up_side"].speed
    container.directions.up_left.play()

    container.directions.up = new PIXI.MovieClip(@.loops["snowman_up"].textures)
    container.directions.up.animationSpeed = @.loops["snowman_up"].speed
    container.directions.up.play()

    container.directions.up_right = new PIXI.MovieClip(@.loops["snowman_up_side"].textures)
    container.directions.up_right.animationSpeed = @.loops["snowman_up_side"].speed
    container.directions.up_right.play()
    container.directions.up_right.scale.x = -1

    container.directions.right = new PIXI.MovieClip(@.loops["snowman_side"].textures)
    container.directions.right.animationSpeed = @.loops["snowman_side"].speed
    container.directions.right.play()
    container.directions.right.scale.x = -1

    container.directions.down_right = new PIXI.MovieClip(@.loops["snowman_down_side"].textures)
    container.directions.down_right.animationSpeed = @.loops["snowman_down_side"].speed
    container.directions.down_right.play()
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
      container.walk_sprite = new PIXI.MovieClip(@.loops["lumberjack_up_side"].textures)
      container.walk_sprite.animationSpeed = @.loops["lumberjack_up_side"].speed
      container.walk_sprite.play()
      container.walk_sprite.scale.x = -1
    # right
    else if 67.5 < jack.angle <= 112.5
      container.walk_sprite = new PIXI.MovieClip(@.loops["lumberjack_side"].textures)
      container.walk_sprite.animationSpeed = @.loops["lumberjack_side"].speed
      container.walk_sprite.play()
      container.walk_sprite.scale.x = -1
    # bottom right
    else if 112.5 < jack.angle <= 157.5
      container.walk_sprite = new PIXI.MovieClip(@.loops["lumberjack_down_side"].textures)
      container.walk_sprite.animationSpeed = @.loops["lumberjack_down_side"].speed
      container.walk_sprite.play()
      container.walk_sprite.scale.x = -1
    # bottom
    else if 157.5 < jack.angle <= 202.5
      container.walk_sprite = new PIXI.MovieClip(@.loops["lumberjack_down"].textures)
      container.walk_sprite.animationSpeed = @.loops["lumberjack_down"].speed
      container.walk_sprite.play()
    # bottom left
    else if 202.5 < jack.angle <= 247.5
      container.walk_sprite = new PIXI.MovieClip(@.loops["lumberjack_down_side"].textures)
      container.walk_sprite.animationSpeed = @.loops["lumberjack_down_side"].speed
      container.walk_sprite.play()
    # left
    else if 247.5 < jack.angle <= 292.5
      container.walk_sprite = new PIXI.MovieClip(@.loops["lumberjack_side"].textures)
      container.walk_sprite.animationSpeed = @.loops["lumberjack_side"].speed
      container.walk_sprite.play()
    # top left
    else if 292.5 < jack.angle <= 337.5
      container.walk_sprite = new PIXI.MovieClip(@.loops["lumberjack_up_side"].textures)
      container.walk_sprite.animationSpeed = @.loops["lumberjack_up_side"].speed
      container.walk_sprite.play()
    # top
    else
      container.walk_sprite = new PIXI.MovieClip(@.loops["lumberjack_up"].textures)
      container.walk_sprite.animationSpeed = @.loops["lumberjack_up"].speed
      container.walk_sprite.play()

    container.walk_sprite.anchor.x = 0.5
    container.walk_sprite.anchor.y = 1

    container.addChild(container.walk_sprite)

    container.chop_sprite = new PIXI.MovieClip(@.loops["lumberjack_chop"].textures)
    container.chop_sprite.animationSpeed = @.loops["lumberjack_chop"].speed
    container.chop_sprite.play()

    container.chop_sprite.anchor.x = 0.5
    container.chop_sprite.anchor.y = 1
    container.chop_sprite.visible = false

    container.addChild(container.chop_sprite)

    container


  addRabbit: (rabbit)->
    @rabbit_sprite = @.createRabbitSprite(rabbit)

    @object_layer.addChild(@rabbit_sprite)

  removeRabbit: ->
    @object_layer.removeChild(@rabbit_sprite)

    @rabbit_sprite = null


  createRabbitSprite: (object)->
    sprite = new PIXI.MovieClip(@.loops["rabbit"].textures)
    sprite.animationSpeed = @.loops["rabbit"].speed
    sprite.play()
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

  explodeSnowball: (snowball)->
    pieces = []

    for i in [0 .. 10]
      sprite = PIXI.Sprite.fromFrame("snowball.png")
      sprite.position.x = @.objectToSceneX(snowball.x)
      sprite.position.y = @.objectToSceneY(snowball.y)
      sprite.anchor.x = 0.5
      sprite.anchor.y = 0.5
      sprite.scale.set(0.25 + 0.5 * Math.random())
      sprite.rotation = _.random(0, 360) * Math.PI / 180

      pieces.push(sprite)

      @particle_layer.addChild(sprite)

    animation = new SnowballExplosionAnimation(@)
    animation.start(pieces)


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

  hitSnowman: ->
    @snowman_hit_animation ?= new SnowmanHitAnimation()
    @snowman_hit_animation.start(@snowman_sprite)

  hitPine: ->
    pieces = []

    for i in [0 .. 4]
      sprite = PIXI.Sprite.fromFrame("splint.png")
      sprite.start_at = new PIXI.Point(
        @.objectToSceneX(@controller.pine.x),
        @.objectToSceneY(@controller.pine.y - 25)
      )
      sprite.anchor.x = 0.5
      sprite.anchor.y = 0.5
      sprite.scale.set(0.2 + 0.8 * Math.random(), 0.2 + 0.8 * Math.random())
      sprite.angle = _.random(0, 360) * Math.PI / 180 * _.shuffle([-1, 1])[0]
      sprite.speed = 0.5 + Math.random() * 1.5

      pieces.push(sprite)

      @particle_layer.addChild(sprite)

    animation = new PineHitAnimation(@)
    animation.start(pieces)

  displayGameOver: ->
    @game_layer.alpha = 0.2

    @game_over_screen.visible = true
    @game_over_screen.addChild(@lumberjacks_hit_text)
    @game_over_screen.addChild(@snowballs_thrown_text)

    @lumberjacks_hit_text.setText(@controller.lumberjacks_hit)
    @snowballs_thrown_text.setText(@controller.snowballs_thrown)

  displayVictory: ->
    @game_layer.alpha = 0.2

    @victory_screen.visible = true
    @victory_screen.addChild(@lumberjacks_hit_text)
    @victory_screen.addChild(@snowballs_thrown_text)

    @lumberjacks_hit_text.setText(@controller.lumberjacks_hit)
    @snowballs_thrown_text.setText(@controller.snowballs_thrown)

