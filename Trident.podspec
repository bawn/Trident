#
# Be sure to run `pod lib lint Trident.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Trident'
  s.version          = '0.3.0'
  s.summary          = 'A MenuView For Aquaman'
  s.homepage         = 'https://github.com/bawn/Trident'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'bawn' => 'lc5491137@gmail.com' }
  s.source           = { :git => 'https://github.com/bawn/Trident.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.requires_arc     = true
  s.public_header_files = "Trident/Trident.h"
  s.source_files     = ["Trident/*.swift", "Trident/Trident.h"]
  s.frameworks = 'UIKit'
  s.swift_version    = "4.2"
  s.dependency 'SnapKit', '~> 4.2.0'
end
