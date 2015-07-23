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
  s.source           = { :git => "git@github.com:WhallaLabs/WHALua.git", :branch => "development" }#, :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = "WHALua/**/*.{h,m}"
end
