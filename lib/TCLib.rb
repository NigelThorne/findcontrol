require 'win32ole'
require 'rubygems'
#require 'pry'

include WIN32OLE::VARIANT

class String
  def strip_quotes
    gsub(/\A['"]+|['"]+\Z/, "").gsub("\\\\","\\")
  end
end

class TCFramework
    def initialize(name, tc)
        @name, @tc = name, tc
    end    

private
    def method_missing(meth, *args, &blk)
        TCLibrary.new(@name+"."+meth.to_s, @tc)
    end
end

class TCLibrary
    def initialize(name, tc)
        @framework, @unit = name.split(".")
        @integration = tc.integration
    end

private
    def method_missing(meth, *args, &blk)
        raise("Test Complete is already Running a test") if(@integration.IsRunning) 
        @integration.RunRoutineEx(@framework, @unit, meth.to_s, WIN32OLE_VARIANT.new(args.map{|a| 
            a.is_a?(String) ? WIN32OLE_VARIANT.new(a, VT_BSTR) : WIN32OLE_VARIANT.new(a, VT_VARIANT|VT_BYREF)}
        ))
        while @integration.IsRunning 
            sleep(1) 
        end
        @integration.RoutineResult
    end
end

class Proj
	def initialize(proj_file)
		@tc = TC.new
		@integration = @tc.integration
		raise("Test Complete is already Running a test") if(@integration.IsRunning) 
        if (!@integration.IsProjectSuiteOpened || @integration.ProjectSuiteFileName != proj_file)
    		@suite = @integration.OpenProjectSuite(proj_file)
        end
        raise "can't open project" unless @integration.IsProjectSuiteOpened
	end

    def get_current_control_automation_path(include_text = true)
        sys = @integration.GetObjectByName("Sys")
        get_control_automation_path_from_location(sys.Desktop.MouseX, sys.Desktop.MouseY, include_text)
    end

		def get_control_automation_path_from_location(x,y,include_text)
        sys = @integration.GetObjectByName("Sys")
        sys.Refresh
        objTest = sys.Desktop.ObjectFromPoint( x, y )
        get_automation_path(objTest, include_text)
		end

	private

    def get_automation_path(object, include_text)
        object = object.Parent until object.nil? || object.Name.to_s.start_with?("UIAObject")
        return "" unless object && object.Exists
        return "Process" if(object.Name.to_s.start_with? "Process")
        return "#{get_automation_path(object.Parent, include_text)}/#{get_automation_name(object, include_text)}"
    end

    def get_automation_name(object, include_text)
        return "" if object.nil?
        begin
        automation_id = object.AutomationID
        rescue
        end
        begin
        class_name = object.ClassName
        rescue
        end
        begin
        text = object.NativeUIAObject.Name if include_text
        rescue
        end

        id= ''
        id+= automation_id if automation_id && automation_id.is_a?(String) && !automation_id.empty?
        id+= "(#{class_name})" if class_name && class_name.is_a?(String) && !class_name.empty?
        id+= "\"#{text}\"" if text && text.is_a?(String) && !text.empty?
        id+= "Unknown Control" if id.empty?
        id    
    end

    def method_missing(meth, *args, &blk)
        TCFramework.new(meth.to_s, @tc)
    end
end

class TC
    def initialize
        @tc = TC.get_TC
    end

    def self.get_TC
        tc = get_OLE("TestComplete.TestCompleteApplication.8")
        tc = get_OLE("TestExecute.TestExecuteApplication.8") unless tc
        tc
    end
    
    def self.get_OLE(strAutomationEngine)
        begin
            tc = WIN32OLE.connect(strAutomationEngine)
        rescue WIN32OLERuntimeError
            begin
                tc = WIN32OLE.new(strAutomationEngine)
            rescue WIN32OLERuntimeError
            end
        end
        tc
    end

    def library(name)
        TCLibrary.new(name, @tc)
    end

    def method_missing(meth, *args, &blk)
       @tc.send(meth, *args, &blk)
    end

    def StartProcess(executable, parameter, timeout)
        shell = WIN32OLE.new('WScript.Shell')
        shell.Run("#{executable} \"#{parameter}\"")

        processName = executable.split(/[\/\\]/).last.split(/\./).first
        sys = @tc.integration.GetObjectByName("Sys")
        x = Now + timeout

        begin
            process = sys.Find("ProcessName", processName)
        end while(!process.Exists && Now < x) 
        return process
    end
    
    def LaunchIe(url, timeout)
        executable = "C:\\Program Files (x86)\\Internet Explorer\\iexplore.exe"
        StartProcess(executable, url, timeout)
    end
end

