Gem::Specification.new do |s|
  s.name = "findcontrol"  # i.e. visualruby.  This name will show up in the gem list.
  s.version = "0.0.3"  # i.e. (major,non-backwards compatable).(backwards compatable).(bugfix)
	s.add_dependency "vrlib", ">= 0.0.1"
	s.add_dependency "gtk2", ">= 0.0.1"
	s.add_dependency "require_all", ">= 0.0.1"
	s.add_dependency "win32-clipboard", ">= 0.0.1"

	s.has_rdoc = false
  s.authors = ["Nigel Thorne"] 
  s.email = "github@nigelthorne.com" # optional
  s.summary = "SpyApp for detecting control automation paths. Requires TestComplete8" # optional
  s.homepage = "http://www.nigelthorne.com/"  # optional
  s.description = "Test automation helper tool" # optional
	s.executables = ['findcontrol.rb']  # i.e. 'vr' (optional, blank if library project)
	s.default_executable = ['findcontrol.rb']  # i.e. 'vr' (optional, blank if library project)
	s.bindir = ['.']    # optional, default = bin
	s.require_paths = ['.']  # optional, default = lib 
	s.files = Dir.glob(File.join("**", "*.{rb,glade,pjs,tcLS,tcCfgExtender,svb,tcScript,mds,gif}"))
	s.rubyforge_project = "nowarning" # supress warning message 
end
