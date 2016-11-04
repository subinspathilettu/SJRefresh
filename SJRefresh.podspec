Pod::Spec.new do |spec|
  spec.name             = 'SJRefresh'
  spec.version          = '1.0.0'
  spec.summary          = 'A customizable pull to refresh.'
  spec.description      = 'A simple customizable pull to refresh developed in swift 3. SJRefersh supports animation images array and gif.'
  spec.homepage         = 'https://code.qburst.com/subinsjose/SJRefreshControl'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.author           = { 'Subins Jose' => 'subinsjose@gmail.com' }
  spec.source           = { :git => 'https://github.com/subinspathilettu/SJRefresh', :tag => 'v1.0.0' }
  spec.social_media_url = 'https://twitter.com/subinsjose'
  spec.ios.deployment_target = '9.0'
  spec.source_files     = 'SJRefresh/Classes/**/*'
  spec.resources		    = ['SJRefresh/Assets/**/*']
end
