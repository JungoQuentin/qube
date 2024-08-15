use godot::prelude::*;

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

#[godot_api]
impl UtilsRS {
    /// Change the parent of a node and keep the global transform
    #[func]
    fn switch_parent_keep_global_transform(node: Gd<Node>, new_parent: Gd<Node>) {
        if can_cast!(node, Node2D) {
            let mut node2d: Gd<Node2D> = node.clone().cast();
            let global_transform = node2d.get_global_transform();
            UtilsRS::switch_parent(node, new_parent);
            node2d.set_global_transform(global_transform);
        } else if can_cast!(node, Node3D) {
            let mut node3d: Gd<Node3D> = node.clone().cast();
            let global_transform = node3d.get_global_transform();
            UtilsRS::switch_parent(node, new_parent);
            node3d.set_global_transform(global_transform);
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
}
