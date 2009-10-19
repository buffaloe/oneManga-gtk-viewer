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
require 'manga_viewer'

#dummy = DummyManga::MangaPages.new(true, true)

test = DummyManga::DummyMangaConstructor.new()

puts test.to_s

#build_manga_viewer(dummy)

#Gtk.main
