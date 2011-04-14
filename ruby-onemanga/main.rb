#!/usr/bin/env ruby
# ruby-OneManga Viewer
#
# Copyright (c) 2009, Paul Berens
#
# You can redistribute it and/or modify it under the terms of
# the GPL's licence.
#

require 'gtk2'
#require 'DummyManga'
require 'SequelManga'
#require 'manga_viewer'
#require 'manga_index'
require 'fetcher/OneManga'


#test2 = SequelManga::SequelMangaConstructor.new
#test2.populate

#site2 = test2.getSite

#puts site2.to_s


SequelManga::SequelMangaConstructor.new
test3 = Fetcher::OneManga.new
test3.populate

site3 = test3.getSite

puts site3.to_s



#test = DummyManga::DummyMangaConstructor.new
#site = test.getSite
#puts test.to_s

#build_manga_viewer(site.mangas[0])

#build_manga_index([site])
#Gtk.main
