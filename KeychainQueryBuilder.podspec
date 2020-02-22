Pod::Spec.new do |s|
  s.name             = 'KeychainQueryBuilder'
  s.version          = '0.1.0'
  s.summary          = 'Typesafe query builder for keychain queries'
  s.swift_version    = '5.0'

  s.description      = <<-DESC
  Typesafe query builder for keychain queries.
                       DESC

  s.homepage         = 'https://github.com/anconaesselmann/KeychainQueryBuilder'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'anconaesselmann' => 'axel@anconaesselmann.com' }
  s.source           = { :git => 'https://github.com/anconaesselmann/KeychainQueryBuilder.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'

  s.source_files = 'KeychainQueryBuilder/Classes/**/*'

end
