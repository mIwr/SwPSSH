Pod::Spec.new do |spec|
  spec.name         = "SwPSSH"
  spec.version      = "1.1.0"
  spec.summary      = "Protection System Specific Header (PSSH) box container swift impl. Supports Widevine and PlayReady"
  spec.homepage     = "https://github.com/mIwr/SwPSSH"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "mIwr" => "https://github.com/mIwr" }
  spec.osx.deployment_target = "10.13"
  spec.ios.deployment_target = "11.0"
  spec.tvos.deployment_target = "11.0"
  spec.watchos.deployment_target = "4.0"
  spec.swift_version = "5.0"
  spec.source        = { :git => "https://github.com/mIwr/SwPSSH.git", :tag => "#{spec.version}" }
  spec.source_files  = "Sources/SwPSSH/*.swift", "Sources/SwPSSH/**/*.swift"
  spec.exclude_files = "Sources/Exclude", "Sources/Exclude/*.*"
  spec.framework     = "Foundation"
  spec.dependency    "SwiftProtobuf"
  spec.resource_bundles = {'SwPSSH' => ['Sources/SwPSSH/PrivacyInfo.xcprivacy']}
end
