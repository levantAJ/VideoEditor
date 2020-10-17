Pod::Spec.new do |s|
  s.name = 'VideoEditor'
  s.version = '0.1'
  s.summary = 'VideoEditor facilitates manipulate Audios volume, merge multiple audios to video'
  s.description = <<-DESC
  VideoEditor written on Swift 5.0 by levantAJ
                       DESC
  s.homepage = 'https://github.com/levantAJ/VideoEditor'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Tai Le' => 'sirlevantai@gmail.com' }
  s.source = { :git => 'https://github.com/levantAJ/VideoEditor.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  s.source_files = 'VideoEditor/*.{swift}'
  
end