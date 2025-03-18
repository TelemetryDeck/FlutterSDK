#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint telemetrydecksdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'telemetrydecksdk'
  s.version          = '0.0.1'
  s.summary          = 'Flutter SDK for TelemetryDeck, a privacy-conscious analytics service for apps and websites.'
  s.description      = <<-DESC
Flutter SDK for TelemetryDeck, a privacy-conscious analytics service for apps and websites.
                       DESC
  s.homepage         = 'https://telemetrydeck.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'TelemetryDeck' => 'info@telemetrydeck.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.dependency 'TelemetryDeck', '~> 2.9.1'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
