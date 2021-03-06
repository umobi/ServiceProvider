#
# Be sure to run `pod lib lint ServiceProvider.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ServiceProvider'
  s.version          = '2.0.0'
  s.summary          = 'ServiceProvider use the idea of micro services to create expecialized services, like ones to store and load data from UserDefaults.'

  s.description      = <<-DESC
ServiceProvider is a library to implement the default methods to maintain stored data
DESC

  s.homepage         = 'https://github.com/umobi/ServiceProvider'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'brennobemoura' => 'brenno@umobi.com.br' }
  s.source           = { :git => 'https://github.com/umobi/ServiceProvider.git', :tag => s.version.to_s }
  
  s.swift_version = '5.2'
  s.tvos.deployment_target = '10.0'
  s.ios.deployment_target = '10.0'
  s.watchos.deployment_target = '4.0'
  s.macos.deployment_target = '10.13'

  s.source_files = 'Sources/ServiceProvider/**/*'

  s.dependency 'RxSwift', '>= 5.0', '< 6.0.0'
  s.dependency 'RxCocoa', '>= 5.0', '< 6.0.0'
  s.dependency 'KeychainAccess', ">= 4.0.0", '< 5.0.0'
end
