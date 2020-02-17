#
# Be sure to run `pod lib lint ARPopupLabel.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ARPopupLabel'
  s.version          = '1.0.1'
  s.summary          = 'An animated popup label to use with SceneKit or ARKit'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
An animated popup label to use in SceneKit or ARKit
                       DESC

  s.homepage         = 'https://github.com/ifullgaz/ARPopupLabel'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Emmanuel Merali' => 'emmanuel@merali.me' }
  s.source           = { :git => 'https://github.com/ifullgaz/ARPopupLabel.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.3'
  s.swift_versions        = ['4.0', '4.2', '4.1', '5.0', '5.1']
#  s.swift_version          = '4.0'

  s.source_files = 'ARPopupLabel/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ARPopupLabel' => ['ARPopupLabel/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'UIBezierPath-Query'
end
