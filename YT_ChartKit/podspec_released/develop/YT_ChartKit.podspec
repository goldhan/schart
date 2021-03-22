#
# Be sure to run `pod lib lint YT_ChartKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YT_ChartKit'
  s.version          = '0.1.8'
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

  s.source_files = 'YT_ChartKit/YT_ChartKit.h'

  # 添加子spec K线
  s.subspec 'YTKLineChart' do |k|
    k.source_files = 'YT_ChartKit/Classes/YTKLineChart/*.{h,m}'

    # 添加子spec 算法
    k.subspec 'Calculator' do |c|
      c.source_files = 'YT_ChartKit/Classes/YTKLineChart/Calculator/**/*.{h,m}'
    end

    # 添加子spec Layer
    k.subspec 'ChartLayer' do |layer|
      layer.source_files = 'YT_ChartKit/Classes/YTKLineChart/ChartLayer/*.{h,m}'

      layer.subspec 'IndexLayer' do |index|
            index.source_files = 'YT_ChartKit/Classes/YTKLineChart/ChartLayer/IndexLayer/**/*'
      end

      layer.subspec 'RenderLayer' do |render|
            render.source_files = 'YT_ChartKit/Classes/YTKLineChart/ChartLayer/RenderLayer/**/*'
      end
    end

    # 添加子spec View
    k.subspec 'ChartView' do |view|
      view.source_files = 'YT_ChartKit/Classes/YTKLineChart/ChartView/**/*'
    end

    # 添加子spec 网格
    k.subspec 'Graphics' do |graph|
      graph.source_files = 'YT_ChartKit/Classes/YTKLineChart/Graphics/**/*'
    end

    # 添加子spec 数据
    k.subspec 'KLineDataSource' do |data|
      data.source_files = 'YT_ChartKit/Classes/YTKLineChart/KLineDataSource/**/*'
    end

    # 添加子spec
    k.subspec 'QueryView' do |query|
      query.source_files = 'YT_ChartKit/Classes/YTKLineChart/QueryView/**/*'
    end

    # 添加子spec
    k.subspec 'SCUtils' do |utils|
      utils.source_files = 'YT_ChartKit/Classes/YTKLineChart/SCUtils/**/*'
    end
  end

  # 添加子spec 分时
  s.subspec 'YTTimeChart' do |t|
    t.source_files = 'YT_ChartKit/Classes/YTTimeChart/*.{h,m}'

    # 添加子spec 算法
    t.subspec 'Calculator' do |c|
      c.source_files = 'YT_ChartKit/Classes/YTTimeChart/Calculator/**/*'
    end

    # 添加子spec Layer
    t.subspec 'ChartLayer' do |layer|
      layer.source_files = 'YT_ChartKit/Classes/YTTimeChart/ChartLayer/*.{h,m}'

      layer.subspec 'RenderLayer' do |render|
            render.source_files = 'YT_ChartKit/Classes/YTTimeChart/ChartLayer/RenderLayer/**/*'
      end
    end

    # 添加子spec View
    t.subspec 'ChartView' do |view|
      view.source_files = 'YT_ChartKit/Classes/YTTimeChart/ChartView/*.{h,m}'

      view.subspec 'ChartViewV2' do |v2|
            v2.source_files = 'YT_ChartKit/Classes/YTTimeChart/ChartView/ChartViewV2/**/*'
      end
    end

    # 添加子spec
    t.subspec 'QueryView' do |query|
      query.source_files = 'YT_ChartKit/Classes/YTTimeChart/QueryView/**/*'
    end

    # 添加子spec 数据
    t.subspec 'TimeDataSource' do |data|
      data.source_files = 'YT_ChartKit/Classes/YTTimeChart/TimeDataSource/**/*'
    end

    # 添加子spec View
    t.subspec 'SwitchView' do |view|
      view.source_files = 'YT_ChartKit/Classes/YTTimeChart/SwitchView/**/*'
    end
  end

  # s.resource_bundles = {
  #   'YT_StockChartViewExample' => ['YT_StockChartViewExample/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
