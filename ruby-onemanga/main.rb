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
require 'manga_index'
require 'fetcher/OneManga'

RELOAD = false
TESTING = false

if RELOAD
    test2 = SequelManga::SequelMangaConstructor.new true
    test3 = Fetcher::OneManga.new true
    test3.populate
else
    test2 = SequelManga::SequelMangaConstructor.new false
    test3 = Fetcher::OneManga.new false
end

if TESTING
    DB = test2.getDb

    ds = DB[:titles]
    ds.filter(:alternate => true).group(:info_id).having('COUNT(info_id) > 1').each do |r|
        info = SequelManga::Info[r[:info_id]]
        puts info.title
        puts "\t#{info.alt_titles.join(', ')}"
    end

    ds = DB[:infos]
    ds.select(:id).each do |r|
        puts SequelManga::Info[r[:id]].cover_page_url
    end
else
    #test = DummyManga::DummyMangaConstructor.new
    #site = test.getSite
    #puts test.to_s

    #build_manga_viewer(site.mangas[0])

    DB = test2.getDb
    site = SequelManga::Site[1]
    build_manga_index(site)
    Gtk.main
end
