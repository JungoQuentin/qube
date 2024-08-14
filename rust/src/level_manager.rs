use godot::prelude::*;

#[derive(GodotClass)]
#[class(base=Object)]
pub struct LevelManagerRS;

#[godot_api]
impl IObject for LevelManagerRS {
    fn init(_base: Base<Object>) -> Self {
        Self
    }
}

#[godot_api]
impl LevelManagerRS {
    const ENTRY_POINT_PATH: &'static str = "res://src/level/levels/000_entry_point.tscn";

    #[func]
    fn goto_level_gate(mut tree: Gd<SceneTree>) {
        tree.change_scene_to_file(LevelManagerRS::ENTRY_POINT_PATH.into_godot());
    }
}
