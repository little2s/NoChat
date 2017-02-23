Pod::Spec.new do |s|
  s.name         = "NOCProtoKit"
  s.version      = "0.3.2"
  s.summary      = "A lightweight chat framework."
  s.homepage     = "https://github.com/little2s/NoChat.git"
  s.license      = "MIT"
  s.author       = { "Yinglun Duan" => "duanyinglun@gmail.com" }
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/little2s/NoChat.git", :tag => s.version }
  s.source_files = "NOCProtoKit/NOCProtoKit/*.{h,m}"
  s.public_header_files = "NOCProtoKit/NOCProtoKit/*.h"
end
