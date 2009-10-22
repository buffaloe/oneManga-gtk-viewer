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

def build_manga_viewer(dummy)
    builder = Gtk::Builder.new
    builder.add_from_file('view/manga-view.glade')

    forward = builder.get_object('forward_button')
    back = builder.get_object('back_button')

    pages = builder.get_object('pages_combobox')
    chapters = builder.get_object('chapters_combobox')
    volumes = builder.get_object('volumes_combobox')

    image = builder.get_object('image')


    ##############################
    # Manga first page/setup
    ##############################

    # Loads first image (assuming manga info w/ pages only)
    dummy_pages = dummy.pages

    # first page image
    image.pixbuf = dummy_pages.first

    # Set the buttons status
    back.sensitive = false

    if !dummy_pages.next?
	forward.sensitive = false
    end

    # Setup the pages combo_box
    list_store = Gtk::ListStore.new(String)
    dummy_pages.page_titles.each do |text|
	(list_store.append())[0] = text
    end

    render = Gtk::CellRendererText.new
    pages.pack_start(render, true)
    pages.set_attributes(render, {"text" => 0})

    pages.model = list_store
    pages.active = 0


    ##############################
    # Manga forward/back button signal
    ##############################
    forward.signal_connect('clicked') do
	if dummy_pages.next?
	    puts "Next page"
	    image.pixbuf = dummy_pages.next

	    pages.active = dummy_pages.index
	    back.sensitive = true
	end

	if !dummy_pages.next?
	    forward.sensitive = false
	end
    end

    back.signal_connect('clicked') do
	if dummy_pages.prev?
	    puts "Prev page"
	    image.pixbuf = dummy_pages.prev

	    pages.active = dummy_pages.index
	    forward.sensitive = true
	end

	if !dummy_pages.prev?
	    back.sensitive = false
	end
    end


    ##############################
    # Manga pages combo box
    ##############################
    pages.signal_connect('changed') do |combobox|
	# Ignore changes that are from "forward/backward"
	# setting the combobox active index
	if combobox.active != dummy_pages.index
	    puts "valid"
	    image.pixbuf = dummy_pages.goto(combobox.active)
	end
    end

    window = builder.get_object('viewer_window')
    window.show_all

    # Show/hide widgets
    builder.get_object('chapters_hbox').hide_all
    builder.get_object('volumes_hbox').hide_all
end



def tmp
    # Load first image
    if dummy.next_page?
	image.pixbuf = dummy.first_page

	# Set the buttons status
	back.sensitive = false

	# Setup the pages combo_box
	list_store = Gtk::ListStore.new(String)
	dummy.list_pages.each do |text|
	    (list_store.append())[0] = text
	end

	render = Gtk::CellRendererText.new
	pages.pack_start(render, true)
	pages.set_attributes(render, {"text" => 0})

	pages.model = list_store
	pages.active = 0

	# Setup the chapters combo_box
	list_store = Gtk::ListStore.new(String)
	dummy.list_chapters.each do |text|
	    (list_store.append())[0] = text
	end

	render = Gtk::CellRendererText.new
	chapters.pack_start(render, true)
	chapters.set_attributes(render, {"text" => 0})

	chapters.model = list_store
	chapters.active = 0

	# Setup the volumes combo_box
	list_store = Gtk::ListStore.new(String)
	dummy.list_volumes.each do |text|
	    (list_store.append())[0] = text
	end

	render = Gtk::CellRendererText.new
	volumes.pack_start(render, true)
	volumes.set_attributes(render, {"text" => 0})

	volumes.model = list_store
	volumes.active = 0
    end

    # Connect the forward/back button Signals
    forward.signal_connect('clicked') do
	if dummy.next_page?
	    puts "Next page"
	    image.pixbuf = dummy.next_page

	    pages.active = dummy.currentPageIndex
	    back.sensitive = true
	elsif dummy.next_chapter?
	    puts "Next chapter"
	    dummy = dummy.next_chapter

	    # Loading first page of the new chapter
	    puts "Next chapter - first page"
	    image.pixbuf = dummy.first_page

	    pages.active = dummy.currentPageIndex
	    chapters.active = dummy.currentChapterIndex
	    back.sensitive = true
	elsif dummy.next_volume?
	    puts "Next volume"
	    dummy = dummy.next_volume

	    # Loading first page of the new volume/chapter
	    puts "Next volume - first page"
	    image.pixbuf = dummy.first_page

	    pages.active = dummy.currentPageIndex
	    chapters.active = dummy.currentChapterIndex
	    volumes.active = dummy.currentVolumeIndex
	    back.sensitive = true
	end

	if !dummy.next_page? and !dummy.next_chapter? and !dummy.next_volume?
	    forward.sensitive = false
	end
    end

    back.signal_connect('clicked') do
	if dummy.prev_page?
	    puts "Prev page"
	    image.pixbuf = dummy.prev_page

	    pages.active = dummy.currentPageIndex
	    forward.sensitive = true
	elsif dummy.prev_chapter?
	    puts "Prev chapter"
	    dummy = dummy.prev_chapter

	    # Loading first page of the new chapter
	    puts "Prev chapter - Last page"
	    image.pixbuf = dummy.last_page

	    pages.active = dummy.currentPageIndex
	    chapters.active = dummy.currentChapterIndex
	    forward.sensitive = true
	elsif dummy.prev_volume?
	    puts "Prev volume"
	    dummy = dummy.prev_volume

	    # Loading first page of the new chapter
	    puts "Prev volume - Last page"
	    image.pixbuf = dummy.last_page

	    pages.active = dummy.currentPageIndex
	    chapters.active = dummy.currentChapterIndex
	    volumes.active = dummy.currentVolumeIndex
	    forward.sensitive = true
	end

	if !dummy.prev_page? and !dummy.prev_chapter? and !dummy.prev_volume?
	    back.sensitive = false
	end
    end

    chapters.signal_connect('changed') do |combobox|
	# Ignore changes that are from "forward/backward"
	# setting the combobox active index
	if combobox.active != dummy.currentChapterIndex
	    puts "valid"
	    image.pixbuf = dummy.goto_chapter(combobox.active)

	    # update the page index
	    pages.active = dummy.currentPageIndex
	end
    end

    volumes.signal_connect('changed') do |combobox|
	# Ignore changes that are from "forward/backward"
	# setting the combobox active index
	if combobox.active != dummy.currentVolumeIndex
	    puts "valid"
	    image.pixbuf = dummy.goto_volume(combobox.active)

	    # update the chapter index
	    chapters.active = dummy.currentChapterIndex

	    # update the page index
	    pages.active = dummy.currentPageIndex
	end
    end

    # Connect the combo box selection
    pages.signal_connect('changed') do |combobox|
	# Ignore changes that are from "forward/backward"
	# setting the combobox active index
	if combobox.active != dummy.currentPageIndex
	    puts "valid"
	    image.pixbuf = dummy.goto_page(combobox.active)
	end
    end
end
