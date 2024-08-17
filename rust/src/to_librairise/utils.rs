use godot::{
    classes::{Engine, Os},
    prelude::*,
};

#[derive(GodotClass)]
#[class(base=Node)]
pub struct UtilsRS {
    base: Base<Node>,
}

#[godot_api]
impl INode for UtilsRS {
    fn init(base: Base<Node>) -> Self {
        Self { base }
    }
}

macro_rules! can_cast {
    ($node:expr, $ty:ty) => {
        $node.clone().try_cast::<$ty>().is_ok()
    };
}

macro_rules! internal_switch_parent_keep_global_transform {
    ($node:expr, $new_parent:expr, $ty:ty) => {
        let mut node_d: Gd<$ty> = $node.clone().cast();
        let global_transform = node_d.get_global_transform();
        UtilsRS::switch_parent($node, $new_parent);
        node_d.set_global_transform(global_transform);
    };
}

macro_rules! is_godot_dbg {
    () => {
        Os::singleton().has_feature("debug".to_godot())
    };
}

macro_rules! get_tree {
    () => {
        Engine::singleton()
            .get_main_loop()
            .expect("get_tree!() - no main_loop")
            .cast::<SceneTree>()
    };
}

#[godot_api]
impl UtilsRS {
    /// Change the parent of a node and keep the global transform
    #[func]
    fn switch_parent_keep_global_transform(node: Gd<Node>, new_parent: Gd<Node>) {
        if can_cast!(node, Node2D) {
            internal_switch_parent_keep_global_transform!(node, new_parent, Node2D);
        } else if can_cast!(node, Node3D) {
            internal_switch_parent_keep_global_transform!(node, new_parent, Node3D);
        } else {
            godot_warn!("Utils::switch_parent_keep_global_transform - node as no transform");
            UtilsRS::switch_parent(node, new_parent);
        }
    }

    /// Change the parent of a node
    #[func]
    fn switch_parent(node: Gd<Node>, mut new_parent: Gd<Node>) {
        if !node.is_inside_tree() {
            godot_warn!("Utils::switch_parent - node not inside tree");
            return;
        }
        match node.get_parent() {
            None => {
                godot_warn!("Utils::switch_parent - cannot get node parent");
                return;
            }
            Some(mut old_parent) => {
                old_parent.remove_child(node.clone());
                new_parent.add_child(node);
            }
        }
    }

    #[func]
    fn crash(messages: Vec<Variant>) {
        godot_error!("{:?}", messages);
        godot_error!("=== quiting ===");
        // TODO add stack tree
        if is_godot_dbg!() {
            Os::singleton().alert(
                messages
                    .into_iter()
                    .map(|m| m.to_string())
                    .collect::<Vec<String>>()
                    .join(" ")
                    .to_godot(),
            );
        }
        get_tree!().quit();
    }

    #[func]
    fn unimplemented(message: Variant) {
        Self::crash(vec!["unimplemented".to_variant(), message]);
    }
}
