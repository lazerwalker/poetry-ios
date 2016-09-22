source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'Poetry' do
    pod 'Alamofire', '~> 3.4'
    pod 'ForecastIO', '~> 2.1'
    pod 'IntentKit', git: 'https://github.com/intentkit/intentkit.git'
    pod 'SQLite.swift', '~> 0.10'
end

plugin 'cocoapods-keys', {
  :project => "Poetry",
  :keys => [
    "ForecastIOAPIKey"
    ]
}
