#
#  Be sure to run `pod spec lint DDToolbox.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

s.name         = "DDHTTPClient"
s.version      = "0.0.6"
s.summary      = "AFNetworking HTTP client"
s.homepage     = "https://github.com/BrownCN023/DDHTTPClient"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author       = { "liyebiao1990" => "347991555@qq.com" }
s.platform     = :ios, "8.0"
s.source       = { :git => "https://github.com/BrownCN023/DDHTTPClient.git", :tag => s.version }
s.source_files = "DDHTTPClient/**/*.{h,m}"
s.requires_arc = true
s.frameworks = "Foundation"

s.dependency "AFNetworking"

end
