Pod::Spec.new do |s|
  s.name         = "NoChatMM"
  s.version      = "0.2.2"
  s.summary      = "UI componentes for NoChat"
  s.homepage     = "https://github.com/little2s/NoChat.git"
  s.license      = "MIT"
  s.author       = { "Yinglun Duan" => "duanyinglun@ninty.cc" }
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/little2s/NoChat.git", :tag => s.version }
  s.source_files = "NoChatMM/Source/*.{h,swift}"
  s.public_header_files = "NoChatMM/Source/*.h"
  s.resources = ["NoChatMM/Source/*.xcassets"]
  s.dependency "NoChat", "~> 0.2"
end
