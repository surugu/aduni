require 'gtk'

class Canvas < Gtk::DrawingArea
  def initialize
    super
    signal_connect("expose_event") { |w,e| expose_event(w,e) }
    signal_connect("configure_event") { |w, e| configure_event(w,e) }
    @buffer = nil
    @bgc = nil
  end

  def expose_event(w,e)
    if ! @buffer.nil?
      rec = e.area
      w.window.draw_pixmap(@bgc, @buffer, rec.x, rec.y,
			   rec.x, rec.y, rec.width, rec.height)
    end
    false
  end

  def clear(b = @buffer)
    return if b.nil?

    g = b.get_geometry
    @bgc = self.style.bg_gc(self.state) if @bgc.nil?
    if (g[2] > 0 && g[3] > 0)
      b.draw_rectangle(@bgc, true, 0,0, g[2], g[3])
    end
  end

  def configure_event(w,e)
    g = w.window.get_geometry
    if (g[2] > 0 && g[3] > 0)
      b = Gdk::Pixmap::new(w.window, g[2], g[3], -1)
      clear(b)
      if not @buffer.nil?
	g = @buffer.get_geometry
	b.draw_pixmap(@bgc, @buffer, 0,0,
		      g[0], g[1], g[2], g[3])
      end
      @buffer = b
    end
    true
  end
end

class A < Canvas
  def initialize
    super
    signal_connect("button_press_event") { |w,e| pressed(w,e) }
    set_events(Gdk::BUTTON_PRESS_MASK)
  end

  def pressed(widget, ev)
    if not @last.nil?
      @buffer.draw_line(widget.style.fg_gc(widget.state),
			@last.x, @last.y, ev.x, ev.y)

      x1,x2 = if (@last.x < ev.x)
	      then [@last.x, ev.x]
	      else [ev.x,    @last.x]
	      end
      y1,y2 = if (@last.y < ev.y)
	    then [@last.y, ev.y]
	    else [ev.y,    @last.y]
	    end
      widget.draw(Gdk::Rectangle.new(x1,y1,x2-x1+1,y2-y1+1))
    end
    @last = nil
    @last = ev
    true
  end
end

window = Gtk::Window.new(Gtk::WINDOW_TOPLEVEL)
window.signal_connect("delete_event") { exit }
window.signal_connect("destroy_event") { exit }
window.realize
window.set_title("drawing test")

canvas = A.new
window.add(canvas)
canvas.show

window.show
Gtk::main()
