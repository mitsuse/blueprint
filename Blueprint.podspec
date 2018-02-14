Pod::Spec.new do |spec|
  spec.name = 'Blueprint'
  spec.version = '0.5.2'
  spec.homepage = 'https://github.com/mitsuse/blueprint'
  spec.authors = {
    'Tomoya Kose' => 'tomoya@mitsuse.jp'
  }
  spec.summary = '-'
  spec.source = {
    :git => 'git@github.com:mitsuse/blueprint.git',
    :tag => "#{spec.version}",
  }
  spec.ios.deployment_target = '9.0'
  spec.source_files = 'Sources/Blueprint/*.swift'
  spec.dependency 'Domain', '~> 0.2.1'
  spec.dependency 'RxSwift', '~> 4.0.0'
  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
end
