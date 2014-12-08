window.Sounds2 = class
  sounds:
    walk: [0, 0.2]
    chop: [1, 1.2]
    throw: [2, 2.1]
    snowball_hit: [3, 3.4]
    drop: [4, 4.2]
    pickup: [5, 5.2]
    deliver: [6, 6.5]

  constructor: ->
    @players = []

    for i in [0 .. 9] # create 10 players by default
      @.createPlayer()

  createPlayer: ->
    player = document.createElement("audio");
    player.src = '/sounds.mp3'

    $('body').append(player)

    player.pause()

    player.addEventListener('timeupdate',
      ()=>
        @.onPlayerTimeUpdate(player)
      false
    )

    @players.push(player)

    player

  getFreePlayer: ->
    _.detect(@players, (p)-> not p.stop_at? ) || @.createPlayer()

  playSound: (key)->
    player = @.getFreePlayer()

    if player.readyState == player.HAVE_ENOUGH_DATA
      player.currentTime = @.sounds[key][0]
      player.stop_at = @.sounds[key][1]

      player.play()

  # binds to player
  onPlayerTimeUpdate: (player)->
    if player.currentTime > player.stop_at
      player.pause()

      delete player.stop_at
