Pod::Spec.new do |s|
  s.name         = "NoChatTG"
  s.version      = "0.1.0"
  s.summary      = "UI componentes for NoChat"
  s.homepage     = "https://github.com/little2s/NoChat.git"
  s.license      = "MIT"
  s.author       = { "Yinglun Duan" => "duanyinglun@ninty.cc" }
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/little2s/NoChat.git", :tag => s.version }
  s.source_files = "NoChatTG/Source/*.{h,swift}"
  s.public_header_files = "NoChatTG/Source/*.h"
  s.resources = ["NoChatTG/Source/*.xcassets"]
  s.dependency "NoChat", "~> 0.1"
end
