Pod::Spec.new do |s|
  s.name     = 'UZKDataSources'
  s.version  = '1.0.7'
  s.license  = 'MIT'
  s.summary  = 'Foobar'
  s.authors  = { 'Tiago Furlanetto' => 'tiago.f.furlanetto@gmail.com' }
  s.source   = { :git => 'https://Uzaak@bitbucket.org/Uzaak/datasources.git' }
  s.source_files = '*.{h,m}'
  s.resources = '*.xib'
  s.requires_arc = true
end
