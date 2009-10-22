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

test = DummyManga::DummyMangaConstructor.new()
site = test.getSite()

#puts test.to_s

build_manga_viewer(site.mangas[2])
Gtk.main
