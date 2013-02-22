findcontrol
===========

A small tool to help test authors write automated tests for usage my custom test execution engine. Currently this tool requires TestComplete8 or TestExecute8 to be installed.

You can't use this!
===================

This tool generates the automation path for the control you drag the button onto.

Elements of this path are of the format: 

AutomationId(ClassName)"TextContent"

Where AutomationId, Classname are properties of the indicated control, and Text Content is what UISpy referrs to as Name

This path is useful for a custom automated testing tool I have implemented and haven't released yet, so probably not much use to you.

You can use this!
=================

If however you can get some value from this source code, then feel free to copy whatever you like from it.

If you find it useful, I'd love to hear from you. 