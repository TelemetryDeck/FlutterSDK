#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint telemetrydecksdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'telemetrydecksdk'
  s.version          = '1.0.0'
  s.summary          = 'Flutter SDK for TelemetryDeck, a privacy-conscious analytics service for apps and websites.'
  s.description      = <<-DESC
Flutter SDK for TelemetryDeck, a privacy-conscious analytics service for apps and websites.
                       DESC
  s.homepage         = 'https://telemetrydeck.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'TelemetryDeck' => 'info@telemetrydeck.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'TelemetryClient'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
