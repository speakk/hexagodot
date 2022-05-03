extends CanvasLayer

var torchParticles = preload("res://Materials/TorchParticles.tres")

var materials = [
  torchParticles
]

func _ready():
  for material in materials:
    var particle_instance = Particles2D.new()
    particle_instance.process_material = material
    particle_instance.modulate = Color(1,1,1,0)
    particle_instance.emitting = true
    
    add_child(particle_instance)
    print("Are we ever here?")
