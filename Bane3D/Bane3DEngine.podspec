Pod::Spec.new do |s|
  s.name         = 'Bane3DEngine'
  s.version      = '1.0.0'
  s.platform     = :ios, '6.0'
  s.license      = 'MIT' 
  s.homepage     = 'https://github.com/Talantium/Bane3DEngine'
  s.author       = { 'Andreas Hanft' => 'andreas.hanft@gmail.com' }
  s.homepage     = 'http://talantium.net/'
  s.summary      = '2D/3D Engine for iOS using OpenGL ES 2.0'
  s.source       = { :git => 'https://github.com/Talantium/Bane3DEngine.git' }
  s.source_files = 'Code/**/*'
  s.exclude_files = 'Code/Bane3D_Prefix.pch'
  s.header_mappings_dir = 'Code'
  s.frameworks   = 'QuartzCore', 'GLKit', 'OpenGLES', 'CoreMotion'
  s.requires_arc = true
  s.xcconfig     = { 'OTHER_LDFLAGS' => '-lObjC', 'GCC_INPUT_FILETYPE' => 'sourcecode.cpp.objcpp' }
  s.prefix_header_file = 'Code/Bane3D_Prefix.pch'
  s.library      = 'stdc++.6'
end