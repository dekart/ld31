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
