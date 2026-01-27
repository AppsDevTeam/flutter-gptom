#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint gptom.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'gptom'
  s.version          = '0.0.1'
  s.summary          = 'GP Tom Plugin for Flutter'
  s.description      = <<-DESC
GP Tom Plugin for Flutter.

This plugin bundles GP tom iOS SDK (MIT licensed). See THIRD_PARTY_NOTICES.md.
                       DESC
  s.homepage         = 'http://appsdevteam.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Apps Dev Team' => 'martinf@appsdevteam.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'gptom_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
