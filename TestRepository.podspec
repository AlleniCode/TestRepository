Pod::Spec.new do |s|
  s.name = "TestRepository"
  s.version = "1.0.0"
  s.summary = "A test for using repository"
  s.description = <<-Desc
                  It is just a test!
                  DESC
  s.homepage = "https://github.com/AlleniCode/TestRepository"
  s.license = "MIT"
  s.author = { "ManTou" => "3075504778@qq.com" }
  s.source = { :git => "https://github.com/AlleniCode/TestRepository.git", :tag => s.version.to_s }
  s.platform = :ios, '5.0'
  s.requires_arc = true
  s.source_files = "TestRepository/*"
  s.frameworks = "Foundation", "UIKit"
end
