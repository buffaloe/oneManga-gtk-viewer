#!/usr/bin/env ruby
# ruby-OneManga Viewer
#
# Copyright (c) 2009, Paul Berens
#
# You can redistribute it and/or modify it under the terms of
# the GPL's licence.
#

require 'gtk2'

builder = Gtk::Builder.new
builder.add_from_file('view/manga-view.glade')
builder.connect_signals {|handler| method(handler) }

window = builder.get_object('viewer_window')

window.show_all
Gtk.main

#window = Gtk::Window.new
#button = Gtk::Button.new("Hello World")
#
#window.set_title("Hello Ruby")
##window.border_width(10)
#
## Connect the button to a callback.
#button.signal_connect('clicked') { puts "Hello Ruby" }
#
## Connect the signals 'delete_event' and 'destroy'
#window.signal_connect('delete_event') {
#	puts "delete_event received"
#	false
#}
#window.signal_connect('destroy') {
#	puts "destroy event received"
#	Gtk.main_quit
#}
#
#window.add button
#window.show_all
#Gtk.main
