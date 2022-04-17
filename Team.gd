extends Reference

class_name Team

# Unique, identifies team
var name = ""

enum ControllerType {
  PLAYER, AI
}

enum Commands {
  END_TURN,
  ATTACK,
  MOVE_UNIT
}

