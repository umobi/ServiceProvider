#
# Be sure to run `pod lib lint ServiceProvider.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ServiceProvider'
  s.version          = '1.1.0'
  s.summary          = 'ServiceProvider keeps your data near from our code'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
ServiceProvider is a library to implement the default methods to maintain stored data
DESC

  s.homepage         = 'https://github.com/umobi/ServiceProvider'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'brennobemoura' => 'brenno@umobi.com.br' }
  s.source           = { :git => 'https://github.com/umobi/ServiceProvider.git', :tag => s.version.to_s }
  
  s.swift_version = '5.1'
  s.tvos.deployment_target = '10.0'
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.15'
  s.watchos.deployment_target = '4.0'

  s.source_files = 'ServiceProvider/Classes/**/*'
  
  s.dependency 'RxSwift', '>= 4.5', "<= 5.0"
  s.dependency 'RxCocoa', '>= 4.5', "<= 5.0"
  s.dependency 'KeychainAccess', ">= 3.2", '<= 4.1.0'
end
