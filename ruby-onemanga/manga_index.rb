#!/usr/bin/env ruby
# ruby-OneManga Viewer
#
# Copyright (c) 2009, Paul Berens
#
# You can redistribute it and/or modify it under the terms of
# the GPL's licence.
#

require 'gtk2'
require 'DummyManga'

def build_manga_index(dummy)
    builder = Gtk::Builder.new
    builder.add_from_file('view/manga-list.glade')

    window = builder.get_object('list_window')
    window.show_all
end
