#!/usr/bin/ruby

require 'vrlib'
require 'win32ole'
require 'win32/clipboard'

#make program output in real time so errors visible in VR.
STDOUT.sync = true
STDERR.sync = true

#everything in these directories will be included
my_path = File.expand_path(File.dirname(__FILE__))
require_all Dir.glob(my_path + "/bin/**/*.rb") 
require_all Dir.glob(my_path + "/lib/*.rb") 

FindControlGui.new().show



# 	begin
# 		@proj ||= Proj.new(File.join(my_path, "lib", "testcomplete", "project", "AutomationPathProject", "AutomationPathProject.pjs").gsub("/","\\"))
# 		control_path=@proj.AutomationPathProject.Helper.GetAutomationPathForControlUnderMouse
# 		Clipboard.set_data(control_path)
# 		puts control_path	
# 	rescue => e
# 		puts e
# 	end

