#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint display_metrics_macos.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'display_metrics_macos'
  s.version          = '1.0.0'
  s.summary          = 'Flutter plugin to retrieve device display metrics (resolution, size, PPI, diagonal). Convert inches & mm to Flutter logical pixels.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/nukeolay/display_metrics/tree/main/display_metrics_macos'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'nukeolay@gmail.com' }

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
