extends Control

signal player_end_turn_pressed()

func _ready():
  $TurnIndicator.margin_top = 320/2 + 60
  $WaveIndicator.margin_top = 320/2

func on_team_added(team):
  var label = Label.new()
  label.text = team.team_name
  $Teams.add_child(label)

func handle_button_and_team_labels(teams, current_team):
  print("Current team in ui: %s" % current_team.team_name)
  for n in $Teams.get_children():
    $Teams.remove_child(n)
    n.queue_free()
  
  for team in teams.get_children():
    var label = Label.new()
    label.text = team.team_name
    if current_team == team:
      label.text = label.text + " <"
    $Teams.add_child(label)

  if current_team.controller == Team.ControllerType.PLAYER:
    $EndTurnButton.disabled = false
  else:
    $EndTurnButton.disabled = true

func _on_EndTurnButton_pressed():
  emit_signal("player_end_turn_pressed")

func _on_wave_started(wave_number):
  print("Wave started")
  $Tween.remove($WaveIndicator, "margin_top")
  $WaveIndicator.text = "Wave %s" % wave_number
  $WaveIndicator.margin_top = 320/2
  $WaveIndicator.visible = true
  yield(get_tree().create_timer(1.0), "timeout")
  $Tween.interpolate_property($WaveIndicator, "margin_top", $WaveIndicator.margin_top, 800, 1, Tween.TRANS_EXPO)
  $Tween.start()

func _on_round_started(round_no, wave_length):
  $NextWaveLabel.text = "Next wave in %s turns..." % (wave_length - (round_no - 1 % wave_length) % wave_length)

func _on_turn_started(teams, team):
  handle_button_and_team_labels(teams, team)
  if team.controller == Team.ControllerType.PLAYER:

    print("Turn started")
    $Tween.remove($TurnIndicator, "margin_top")
    $TurnIndicator.margin_top = 320/2 + 60
    $TurnIndicator.visible = true
    yield(get_tree().create_timer(1.3), "timeout")
    $Tween.interpolate_property($TurnIndicator, "margin_top", $TurnIndicator.margin_top, 800, 1, Tween.TRANS_EXPO)
    $Tween.start()
  
