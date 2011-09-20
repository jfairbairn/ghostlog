Gem::Specification.new do |s|
  s.name = 'ghostlog'
  s.summary = 'A stream interface to your workstreams'
  s.version = '0.0.1'
  s.authors = ['James Fairbairn']
  s.email = %q{james@netlagoon.com}
  s.extra_rdoc_files = %w{README.md}
  s.require_paths = %w{lib}
  s.executables = `ls bin`.split("\n")

  s.files = `git ls-files`.split("\n")

  %w{thin sinatra em-http-request em-net-http mail mustache}.each do |g| # dalli, em-synchrony, kgio
    s.add_runtime_dependency(g)
  end

  %w{rspec shotgun}.each do |g|
    s.add_development_dependency(g)
  end
end