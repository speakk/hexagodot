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


func _on_EndTurnButton_pressed():
  emit_signal("player_end_turn_pressed")
