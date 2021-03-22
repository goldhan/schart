#
# Be sure to run `pod lib lint YT_ChartKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YT_ChartKit'
  s.version          = '0.1.4'
  s.summary          = 'YT_ChartKit'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
分时K线图表库
                       DESC

  s.homepage         = 'https://gitlab.inin88.com/mobile-stock-ios-libs/YT_ChartKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '李燕山' => 'yanshan.li@inin88.com' }
  s.source           = { :git => 'git@gitlab.inin88.com:mobile-stock-ios-libs/YT_ChartKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'

  s.source_files = 'YT_ChartKit/YT_ChartKit.h','YT_ChartKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'YT_StockChartViewExample' => ['YT_StockChartViewExample/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
