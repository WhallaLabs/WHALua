#
# Be sure to run `pod lib lint WhallaLib.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "WHALua"
  s.version          = "0.1.0"
  s.summary          = "Objective C to Lua bridge"
  s.homepage         = "http://whallalabs.com"
  s.license          = 'Private'
  s.author           = { "Szymon Kuczur" => "szymon.kuczur@whallalabs.com" }
  s.source           = { :git => "git@github.com:WhallaLabs/WHALua.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.public_header_files = 'WHALua/*.h'
  s.source_files = 'WHALua/WHALua.h'

  s.subspec 'Lua' do |ss|
    ss.compiler_flags = '-Wno-deprecated-declarations', '-Wno-shorten-64-to-32'
    ss.source_files = 'Lua/**/*.{h,m,c}'
  end

  s.subspec 'WHALuaLib' do |ss|
    ss.source_files = 'WHALua/**/*.{h,m,c}'
    ss.dependency 'WHALua/Lua'
  end

end
