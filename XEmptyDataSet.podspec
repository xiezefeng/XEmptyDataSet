
Pod::Spec.new do |spec|


  spec.name         = "XEmptyDataSet"
  spec.version      = "0.0.1"
  spec.summary      = "XEmptyDataSet."

  spec.description  = "空数据页面展示"
                

  spec.homepage     = "https://github.com/xiezefeng/XEmptyDataSet.git"
  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  spec.author             = { "谢泽锋" => "815040727@qq.com" }
  spec.platform     = :ios, "10.0"
  spec.source       = { :git => "https://github.com/xiezefeng/XEmptyDataSet.git", :tag => "0.0.1" }
  spec.source_files  = "XEmptyDataSetClasses"
  spec.dependency  "Masonry", "~> 1.1.0"
  spec.framework = "UIKit"

end
