#
# Be sure to run `pod lib lint Core.podspec' to ensure this is a
# valid spec before submitting.

Pod::Spec.new do |s|
  s.name             = 'Core'
  s.version          = '0.2.6'
  s.summary          = 'A collection iOS User interface elements and extensions to speed up your iOS development.'

  s.description  = <<-DESC
Core is a collection iOS User interface elements and extensions to speed up your iOS development.
  DESC

  s.homepage         = 'https://www.github.com/joeypatino/core'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'joey patino' => 'joey.patino@pm.com' }
  s.source       = { :git => 'git@github.com:joeypatino/core.git', :tag => s.version.to_s }
  
  s.source_files    = 'Core/Classes/**/*'
  s.platform        = :ios, '13.0'
  s.swift_version   = '5.0'
  s.pod_target_xcconfig = { 'PRODUCT_BUNDLE_IDENTIFIER': 'com.joeypatino.core' }
  
  s.resources = ['Core/Localizable.strings']
  s.dependency 'VFCabbage'
  #s.dependency 'VideoLab'
  #s.dependency 'MTTransitions'
  #s.dependency 'MetalPetal'
end
