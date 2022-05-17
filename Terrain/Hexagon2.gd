tool
extends Sprite

func _ready():
  material.set_shader_param("random_float", randf())
#
#func _process(_d):
#  # TODO: Only call this when zoom is changed
#  #_zoom_changed()
#  #material.set_shader_param("scale", scale)
#
#func _zoom_changed():
#  material.set_shader_param("y_zoom", get_viewport().global_canvas_transform.y.y)
#
#func _on_Hexagon2_item_rect_changed():
#  material.set_shader_param("scale", scale)
