window.BaseAnimation = class
  constructor: (@animator, @callback)->

  onComplete: =>
    @progress = null

    @callback?()

  positionProgress: (start, end, progress)->
    (end - start) * progress + start


window.PineHitAnimation = class extends BaseAnimation
  speed: 200

  start: (@sprite)->
    @progress = 0

    createjs.Tween.get(@).to(progress: 1, @.speed).on('change', @.onChange)

    @.onChange()

  onChange: =>
    if @progress < 1
      @sprite.alpha = @progress
    else
      @.onComplete()

  onComplete: =>
    @sprite.alpha = 1

    super


window.SnowflakeAnimation = class extends BaseAnimation
  speed: 200

  start: (@sprite)->
    @progress = 0

    createjs.Tween.get(@).to(progress: 1, @.speed).on('change', @.onChange)

    @.onChange()

  onChange: =>
    if @progress < 1
      @sprite.alpha = @progress
    else
      @.onComplete()

  onComplete: =>
    @sprite.alpha = 1

    super

window.SnowmanHitAnimation = class extends BaseAnimation
  speed: 200
  color: 0xff0000

  start: (@sprite)->
    @progress = 0

    for key, sprite of @sprite.directions
      sprite.tint = @.color

    createjs.Tween.get(@).to(progress: 1, @.speed).on('change', @.onChange)

    @.onChange()

  onChange: =>
    if @progress < 1
      @sprite.alpha = @progress
    else
      @.onComplete()

  onComplete: =>
    for key, sprite of @sprite.directions
      sprite.tint = 0xFFFFFF

    @sprite.alpha = 1

    super


window.SnowballExplosionAnimation = class extends BaseAnimation
  speed: 200

  start: (@sprites)->
    @progress = 0

    createjs.Tween.get(@).to(progress: 1, @.speed).on('change', @.onChange)

    @.onChange()

  onChange: =>
    if @progress < 1
      for sprite in @sprites
        sprite.anchor.set(0.5 + 7 * sprite.scale.x * Math.cos(sprite.rotation) * @progress)
    else
      @.onComplete()

  onComplete: =>
    for sprite in @sprites
      @animator.object_layer.removeChild(sprite)

    @sprites = []

    super
