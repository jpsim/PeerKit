Pod::Spec.new do |s|
  s.name = 'PeerKit'
  s.version = '1.1.0'
  s.summary = 'Swift framework for building event-driven, zero-config Multipeer Connectivity apps'
  s.authors = { 'JP Simard' => 'jp@jpsim.com' }
  s.license = 'MIT'
  s.homepage = 'https://github.com/jpsim/PeerKit'
  s.social_media_url = 'https://twitter.com/simjp'
  s.source = {
    :git => 'https://github.com/jpsim/PeerKit.git',
    :tag => s.version
  }
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.source_files = 'PeerKit/*.swift'
  s.requires_arc = true
end
