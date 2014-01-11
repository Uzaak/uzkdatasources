Pod::Spec.new do |s|
  s.name     = 'UZKDataSources'
  s.version  = '1.2.7'
  s.license  = 'MIT'
  s.summary  = 'Foobar'
  s.authors  = { 'Tiago Furlanetto' => 'tiago.f.furlanetto@gmail.com' }
  s.source   = { :git => 'https://Uzaak@bitbucket.org/Uzaak/datasources.git' }
  s.source_files = 'PodContent/*.{h,m}'
  s.resources = 'PodContent/*.xib'
  s.requires_arc = true
end
