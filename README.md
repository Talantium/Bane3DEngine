Bane3D
======

2D/3D Engine for iOS

Early Alpha Stage...

Requirements
======

iOS 5
OpenGL ES 2.0


How To Use
======

0. (Compile Bane3DFramwork Target of Bane3D Project)
1. Add Bane3D.framework Bundle from Bane3D/Framework to your Project
2. Additional System Frameworks: QuartzCore, GLKit, OpenGLES
3. Build Setting: "Compile Sources As" -> "Obj-C++"
4. Build Setting: "Other Linker Flags" -> "-ObjC"


Features
======

General
 * Scene graph with custom asset handling system
 * Shader based rendering of 2D and 3D nodes with depth sorting for transparency
 * Simple 2D touch handling
 * Uses optimized GLKit/Accelerate math
 * Draw call batching when rendering sprites
 * Font label with native on the fly rendering 

Textures
 * PNG
 * PVR
 * Texture Atlas

Models
 * Raw Header
 * 3DS