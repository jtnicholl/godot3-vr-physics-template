# Godot VR Physics Template
This is a basic template for a VR application in Godot with physical hands that interact with the environment, and cannot go through walls or other solid objects. The player can pick up items, and those too cannot be pushed through walls. It also provides other expected VR functionality such as turning and teleporting, as well as some other basic features for any application including loading settings at runtime from a config file.

Godot version 3.5 or later is required, this is because 3.5 introduced asynchronous shader compilation and shader caching. This prevents stuttering caused by shader compilation, which is a nuisance in normal desktop games but in VR it is severely nausea inducing.

Godot 4.0 is not supported. I intend to port this to 4.0 using its built-in OpenXR support in a separate repo later.

## Why should I use this?
Many VR games use a very simple system for the player's hands. The hand copies the position of the controller every frame, and that's it. When the player picks up an object with their hand, the object gets its physics shut off, and it gets dragged along with the hand. When the item is let go it is disconnected from the controller, its physics turned back on, and sometimes it is given an impulse so it can be thrown.

This is the system used by all VR Godot projects I could find online. Its obvious limitation being that the player's hands and any objects they pick up simply phase through walls with no collision.
### New method
This template takes a different approach to hands. For each hand it involves:
- The ARVRController node built into Godot. This copies the position of the controller.
- A "hand anchor," which is a KinematicBody with a small shpere shape. It uses `move_and_slide` to copy the position of the controller, but without passing through the environment.
- A hand node, which is a RigidBody that uses `_integrate_forces` to losely copy the rotation of the controller. This is also where the hand is visually displayed.
- A PinJoint node that moves the hand node to the hand anchor node. Since the hand anchor won't pass through walls, this is never too extreme of a force.

For picking up an object, the hand node moves to the nearest grabbable point on the pickup and then the pickup is reparented to the hand. However, instead of just disabling collision on the picked up object, its collision bounds also get reparented to the hand. This effectively turns the object into an extension of the hand's collision bounds, keeping them together while also preventing them from passing through walls.

## Todo
This is already in a usable state but there is still some more to be done:
- Add an option for continuous (non-teleport based) locomotion, based on the head or controller rotation
- Allow adjusting the positions of the hands relative to the controllers, so that they line up better with the player's real hands
- Picking up objects with two hands
- Code cleanup
- Add documentation comments to public methods
- Improve the demo room
- Include default bindings for more than just the Vive controllers

## Credits
This project uses a stripped-down version of the OpenVR plugin by the GodotVR team, released under the MIT license. See [its license](addons/godot-openvr/LICENSE) for details.

The VR glove model was created by Valve.

## License
This project is released under the MIT license. See the [license](LICENSE) file for details.
