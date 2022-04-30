extends Control

signal player_end_turn_pressed()

func on_team_added(team):
  var label = Label.new()
  label.text = team.team_name
  $Teams.add_child(label)

func on_turn_started(teams, current_team):
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
  $Tween.remove_all()
  $WaveIndicator.text = "Wave %s" % wave_number
  $WaveIndicator.margin_top = 320/2
  $WaveIndicator.visible = true
  yield(get_tree().create_timer(1.0), "timeout")
  $Tween.interpolate_property($WaveIndicator, "margin_top", $WaveIndicator.margin_top, 800, 1, Tween.TRANS_EXPO)
  $Tween.start()
