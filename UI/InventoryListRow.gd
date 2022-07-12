extends HBoxContainer

var item

export(String) var default_label = ""

func init(_item: Item):
  item = _item
  $Label.text = item.item_name
  $TextureRect.texture = item.get_texture()
  print("Set texture!", item.get_texture())
  return self

func get_drag_data(_position):
  var data = {}
  var preview = TextureRect.new()
  preview.texture = item.get_texture()
  set_drag_preview(preview)
  data.item = item
  return data
