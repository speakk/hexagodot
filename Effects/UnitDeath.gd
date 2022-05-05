extends Node2D

func _ready():
  $Particles2D.emitting = true
  
func _physics_process(delta):
  if not $Particles2D.emitting:
    self.queue_free()
