#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint display_metrics.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'display_metrics'
  s.version          = '0.4.1'
  s.summary          = 'Flutter plugin to retrieve device display metrics (resolution, size, PPI, diagonal). Convert inches & mm to Flutter logical pixels.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/nukeolay/display_metrics'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'nukeolay@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
