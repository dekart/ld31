window.SnowflakeEmitter = class extends PIXI.DisplayObjectContainer
  constructor: ->
    @particle_every = 0.05

    super

  update: ->
    @last_emitted_at ?= current_time

    if current_time > @last_emitted_at + @particle_every * 1000
      @.emitParticle()

      @last_emitted_at = current_time

  emitParticle: ->
    @.addChild(new Snowflake(@))

  destroyParticle: (particle)->
    @.removeChild(particle)

  destroy: ->
    for particle in @children
      particle.stopAnimation()

    @.removeChildren()


window.Snowflake = class extends PIXI.Sprite
  colors: [0xffff00, 0xff00ff, 0x00ffff]
  rotations: [-5, -3, 3, 5]
  lifespan: 15000

  constructor: (@emitter)->
    texture = PIXI.Texture.fromFrame('snowflake.png')

    super(texture)

    @progress = 0

    @.anchor.x = 0.5
    @.anchor.y = 0.5
    @.alpha = 0.5 + 0.5 * Math.random()
    @.scale.x = 0.5 + 0.5 * Math.random()

    @.rotationAngle = @.rotations[_.random(0, @.rotations.length - 1)]

    @.startPosition = new PIXI.Point(
      _.random(0, canvasSize.width),
      _.random(-50, -30)
    )

    @.endPosition = new PIXI.Point(
      @.startPosition.x,
      _.random(canvasSize.height + 20, canvasSize.height + 50)
    )

    createjs.Tween.get(@).to(progress: 1, @.lifespan).on('change', @.onChange)

  onChange: =>
    if @progress < 1
      @.position.x = (@endPosition.x - @startPosition.x) * @progress + @startPosition.x + 10 * Math.sin(@progress * 100)
      @.position.y = (@endPosition.y - @startPosition.y) * @progress + @startPosition.y

      @.scale.y = @.scale.x * Math.sin(@progress * 50)
      @.scale.y = 0.1 * Math.sign(@.scale.y) if Math.abs(@.scale.y) < 0.1

      @.rotation = Math.sin(@progress * 50)
    else
      @.stopAnimation()

      @emitter.destroyParticle(@)

  stopAnimation: ->
    createjs.Tween.removeTweens(@)
