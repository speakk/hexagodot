extends Hex

#export var offset = 320

func _ready():
  #$BackBufferCopy/Hexagon.material = $BackBufferCopy/Hexagon.material.duplicate(true)
  #$BackBufferCopy/Hexagon2.material = $BackBufferCopy/Hexagon2.material.duplicate(true)
  #if randf() > 0.6:
  #  $Hexagon2.material = $Hexagon2.material.duplicate(true)
  $Hexagon2.material = $Hexagon2.material.duplicate()
  #$Hexagon.set_materi
  print("DUPAL")

#func _process(delta):
#  var W = 720
#  var H = 480
#  var calculatedOffset = position.y/H/2
  #print("offset", calculatedOffset)
  #$BackBufferCopy/Hexagon2.material.set_shader_param("calculatedOffset", calculatedOffset)
  #var calculatedOffset = (-get_node(cameraPath).position.y/(scrHeight) + self.position.y/scrHeight) * 2 / camZoom;
  #self.material.set_shader_param("calculatedOffset", calculatedOffset);
  #$Hexagon.material.set_shader_param("calculatedOffset", position.y/H * 2);
  #$Hexagon.material.set_shader_param("calculatedOffset", offset)

