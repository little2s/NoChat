Pod::Spec.new do |s|
  s.name         = "Minimal"
  s.version      = "0.3.0"
  s.summary      = "Minimal theme for NoChat"
  s.homepage     = "https://github.com/little2s/NoChat.git"
  s.license      = "MIT"
  s.author       = { "Yinglun Duan" => "duanyinglun@gmail.com" }
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/little2s/NoChat.git", :tag => s.version }
  s.source_files = "Minimal/Minimal/*.{h,m}"
  s.public_header_files = "Minimal/Minimal/*.h"
  s.frameworks = 'CoreText'
  s.dependency "NoChat", "~> 0.3"
end
