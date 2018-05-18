Gem::Specification.new do |spec|
  spec.name        = 'serverspec-firewalld-resources'
  spec.version     = '0.0.2'
  spec.summary     = 'serverspec firewalld resource types'
  spec.description = spec.summary
  spec.authors     = ['Decors']
  spec.files       =  Dir['lib/*.rb'] + Dir['lib/resources/*.rb']

  spec.add_runtime_dependency 'serverspec', '>= 2.00.0'
end
