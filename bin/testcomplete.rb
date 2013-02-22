require 'win32ole'
require 'rubygems'
require 'pry'

include WIN32OLE::VARIANT


class TCLibrary
    def initialize(name, tc)
        @framework, @unit = name.split(".")
        @integration = tc.integration
    end
    def method_missing(meth, *args, &blk)
        @integration.RunRoutineEx(@framework, @unit, meth.to_s, WIN32OLE_VARIANT.new(args.map{|a| 
            a.is_a?(String) ? WIN32OLE_VARIANT.new(a, VT_BSTR) : WIN32OLE_VARIANT.new(a, VT_VARIANT|VT_BYREF)}
        ))
    end
end

class TC
    def initialize
        @tc = TC.get_TC
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
        sys = @tc.GetObjectByName("Sys")
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

private
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
end

def run_test(filename)
    integration = TC.new.integration
    raise("Test Complete is already Running a test") if(integration.IsRunning) 
    integration.OpenProjectSuite("C:\\LeicaAutomation\\LeicaAutomation.pjs")
    integration.RunRoutineEx("Framework", "MainProcessors", "ExecuteStandaloneTest", WIN32OLE_VARIANT.new(filename, VT_BSTR))

    sleep(1) while integration.IsRunning 
end

def run_qc_test_or_timeout(testId, runId, timeout_time, i= nil)
    integration = i || TC.get_TC.integration
    raise("Test Complete is already Running a test") if(integration.IsRunning) 
    integration.OpenProjectSuite("C:\\LeicaAutomation\\LeicaAutomation.pjs")
    integration.RunRoutineEx("Framework", "MainProcessors", "ExecuteFromQC", WIN32OLE_VARIANT.new( "#{testId}|#{runId}", VT_BSTR))
    sleep(1) while integration.IsRunning 
end

def PageLoaded(process)
    page = process.Page("*")
    return false if !page.Exists
end

# exit if Object.const_defined?(:Ocra)

# if(__FILE__ == $0 )

#     filename = ARGV[0] || "\\\\bedrock\\bsd srg\\Projects\\Tool Validation\\Automation framework\\Verification\\CerebroAutomation\\nigel.ts"

#     tc = TC.new
#     integration = tc.integration
#     Sys = integration.GetObjectByName("Sys")
#     #run_qc_test_or_timeout(1515, 485, Time.now + 120, integration)
#     #puts integration.GetLastResultDescription().Status == 0 ? "Passed" : "Failed" 
#     integration.OpenProjectSuite("C:\\LeicaAutomation\\LeicaAutomation.pjs")

#     kw = tc.library("Framework.CommonKeywords")
#     ac = tc.library("Framework.ApplicationClass")
#     pc = tc.library("Framework.ProcessClass")
#     fl = tc.library("Framework.FrameworkLibrary")
#     fl.Framework_Initialise

#     binding.pry

# end

