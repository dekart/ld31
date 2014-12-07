window.Carrot = class
  lifspan: 10

  constructor: (@x, @y)->
    @created_at = Date.now()
    @expire_at = @created_at + @.lifspan * 1000
    @expiring_soon = false

  checkExpirationState: (current_time)->
    @expiring_soon = @expire_at - current_time < 2000

  isExpired: (current_time)->
    current_time > @expire_at