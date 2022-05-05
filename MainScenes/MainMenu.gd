extends Control

func _ready():
  $Map.place_torches()

func _on_PlayButton_pressed():
  SceneManager.switch_scenes("InGame")

func _on_QuitButton_pressed():
  get_tree().quit()
