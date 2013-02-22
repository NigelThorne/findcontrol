require 'Win32API'

class FindControlGui

	include GladeGUI
	include Win32

	def mousePosition
		@@getCursorPos ||= Win32API.new("user32", "GetCursorPos", ['P'], 'V')
		lpPoint = " " * 8 # store two LONGs
		@@getCursorPos.Call(lpPoint)
		lpPoint.unpack("ll") # get the actual values
	end

	def show()
		load_glade(__FILE__) 
		
		my_path = File.expand_path(File.dirname(__FILE__))
		@proj ||= Proj.new(File.join(my_path,"..", "lib", "testcomplete", "project", "AutomationPathProject", "AutomationPathProject.pjs").gsub("/","\\"))

		set_glade_all() 

		target_flags = Gtk::Drag::TARGET_OTHER_APP #useless
		action = Gdk::DragContext::ACTION_COPY #useless
		dest =  Gtk::Drag::DEST_DEFAULT_ALL #useless
		button = Gdk::Window::BUTTON1_MASK #mouse button 1

		Gtk::Drag.source_set(@builder["button1"], button, [ ],  action)	
		Gtk::Drag.source_set(@builder["image1"], button, [ ],  action)	
		@image1 = my_path + '\\glade\\crosshairs.gif'
		dst2 = Gdk::Pixbuf.new(@image1)
		@dst2 = dst2.scale(40, 40, Gdk::Pixbuf::INTERP_HYPER)
		@builder["image1"].pixbuf = @dst2
		Gtk::Drag.source_set_icon(@builder["button1"], @dst2)
		show_window() 
	end

	def button1__drag_begin(*argv)
		context = argv[1]
		Gtk::Drag.set_icon(context, @dst2, 20, 20)
  end

	def button1__drag_failed(*argv)
		@loc = mousePosition
		control_path=@proj.get_control_automation_path_from_location(@loc[0], @loc[1],  @builder["include_text"].active?)
		Clipboard.set_data(control_path)
		@builder["label1"].text = control_path
		false
	end

end

