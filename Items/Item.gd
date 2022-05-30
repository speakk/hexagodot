extends Node2D

class_name Item

var solid = false
var spawn_chance: float = 0
var item_name := ""

func get_texture():
  return $Sprite.texture
