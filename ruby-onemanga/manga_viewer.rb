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

    # If dummy_pages is nil, check to see if it uses chapters
    if dummy_pages.nil?
	if (dummy.chapters).nil?
	    dummy_volumes = dummy.volumes[0] # assuming an array
	    dummy_chapters = dummy_volumes.chapters[0] # assuming an array
	    dummy_pages = dummy_chapters.pages
	else
	    dummy_chapters = dummy.chapters[0] #assuming an array
	    dummy_pages = dummy_chapters.pages
	end
    end

    # first page image
    image.pixbuf = dummy_pages.first

    # Set the buttons status
    back.sensitive = false

    if !dummy_pages.next?
	forward.sensitive = false
    end


    # Setup the pages combo_box
    render = Gtk::CellRendererText.new
    pages.pack_start(render, true)
    pages.set_attributes(render, {"text" => 0})

    update_combobox(dummy_pages.page_titles, pages)
    pages.active = 0


    # Setup the chapters combo_box
    if not dummy_chapters.nil?
	list_store = Gtk::ListStore.new(String)
	if dummy_volumes.nil?
	    dummy.chapters.each do |chp|
		(list_store.append())[0] = chp.title
	    end
	else
	    dummy_volumes.chapters.each do |chp|
		(list_store.append())[0] = chp.title
	    end
	end

	render = Gtk::CellRendererText.new
	chapters.pack_start(render, true)
	chapters.set_attributes(render, {"text" => 0})

	chapters.model = list_store
	chapters.active = 0
    end

    # Setup the volumes combo_box
    if not dummy_volumes.nil?
	list_store = Gtk::ListStore.new(String)
	dummy.volumes.each do |vol|
	    (list_store.append())[0] = vol.title
	end

	render = Gtk::CellRendererText.new
	volumes.pack_start(render, true)
	volumes.set_attributes(render, {"text" => 0})

	volumes.model = list_store
	volumes.active = 0
    end

    ##############################
    # Manga forward/back button signal
    ##############################
    forward.signal_connect('clicked') do
	if dummy_pages.next?
	    puts "Next page"
	    image.pixbuf = dummy_pages.next

	    pages.active = dummy_pages.index
	    back.sensitive = true
	elsif (dummy_chapters.next? unless dummy_chapters.nil?)
	    puts "Next chapter - first page"
	    dummy_chapters = dummy_chapters.next
	    dummy_pages = dummy_chapters.pages

	    image.pixbuf = dummy_pages.first

	    # Update the pages combobox
	    update_combobox(dummy_pages.page_titles, pages)

	    pages.active = dummy_pages.index
	    if dummy_volumes.nil?
		chapters.active = dummy.chapters.index(dummy_chapters)
	    else
		chapters.active = dummy_volumes.chapters.index(dummy_chapters)
	    end

	    back.sensitive = true
	elsif dummy_volumes.next?
	    puts "Next volume - first page"
	    dummy_volumes = dummy_volumes.next
	    dummy_chapters = dummy_volumes.chapters[0] # assuming arrays
	    dummy_pages = dummy_chapters.pages

	    image.pixbuf = dummy_pages.first

	    # Update the pages combobox
	    update_combobox(dummy_pages.page_titles, pages)

	    # Update the chapters combobox
	    update_combobox(dummy_volumes.chapters.map do |chp|
		chp.title
	    end, chapters)


	    pages.active = dummy_pages.index
	    chapters.active = dummy_volumes.chapters.index(dummy_chapters)
	    volumes.active = dummy.volumes.index(dummy_volumes)

	    back.sensitive = true
	end

	if !dummy_pages.next? and !(dummy_chapters.next? unless dummy_chapters.nil?) and !(dummy_volumes.next? unless dummy_volumes.nil?)
	    forward.sensitive = false
	end
    end

    back.signal_connect('clicked') do
	if dummy_pages.prev?
	    puts "Prev page"
	    image.pixbuf = dummy_pages.prev

	    pages.active = dummy_pages.index
	    forward.sensitive = true
	elsif (dummy_chapters.prev? unless dummy_chapters.nil?)
	    puts "Prev chapter - last page"
	    dummy_chapters = dummy_chapters.prev
	    dummy_pages = dummy_chapters.pages

	    image.pixbuf = dummy_pages.last

	    # Update the pages combobox
	    update_combobox(dummy_pages.page_titles, pages)

	    pages.active = dummy_pages.index
	    if dummy_volumes.nil?
		chapters.active = dummy.chapters.index(dummy_chapters)
	    else
		chapters.active = dummy_volumes.chapters.index(dummy_chapters)
	    end

	    forward.sensitive = true
	elsif dummy_volumes.prev?
	    puts "Prev volume - last page"
	    dummy_volumes = dummy_volumes.prev
	    dummy_chapters = dummy_volumes.chapters[dummy_volumes.chapters.length - 1] # assuming arrays
	    dummy_pages = dummy_chapters.pages

	    image.pixbuf = dummy_pages.last

	    # Update the pages combobox
	    update_combobox(dummy_pages.page_titles, pages)

	    # Update the chapters combobox
	    update_combobox(dummy_volumes.chapters.map do |chp|
		chp.title
	    end, chapters)


	    pages.active = dummy_pages.index
	    chapters.active = dummy_volumes.chapters.index(dummy_chapters)
	    volumes.active = dummy.volumes.index(dummy_volumes)

	    forward.sensitive = true
	end

	if !dummy_pages.prev? and !(dummy_chapters.prev? unless dummy_chapters.nil?) and !(dummy_volumes.prev? unless dummy_volumes.nil?)
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
	    puts "valid - page"
	    image.pixbuf = dummy_pages.goto(combobox.active)

	    # Setup the forward/backward button status
	    update_sensitiveness(dummy_pages, dummy_chapters, dummy_volumes, forward, back)
	end
    end


    ##############################
    # Manga chapters combo box
    ##############################
    chapters.signal_connect('changed') do |combobox|
	# Ignore changes that are from "forward/backward"
	# setting the combobox active index
	if combobox.active != dummy_volumes.chapters.index(dummy_chapters)
	    puts "valid - chapter"

	    dummy_chapters = dummy_volumes.chapters[combobox.active]
	    dummy_pages = dummy_chapters.pages

	    image.pixbuf = dummy_pages.first

	    # Update the combo box listing for pages
	    # Update the pages combobox
	    update_combobox(dummy_pages.page_titles, pages)

	    # Set the combo box index
	    pages.active = 0

	    # Setup the forward/backward button status
	    update_sensitiveness(dummy_pages, dummy_chapters, dummy_volumes, forward, back)
	end
    end


    ##############################
    # Manga volumes combo box
    ##############################
    volumes.signal_connect('changed') do |combobox|
	# Ignore changes that are from "forward/backward"
	# setting the combobox active index
	if combobox.active != dummy.volumes.index(dummy_volumes)
	    puts "valid - volume"

	    dummy_volumes = dummy.volumes[combobox.active]
	    dummy_chapters = dummy_volumes.chapters[0] # assuming arrays
	    dummy_pages = dummy_chapters.pages

	    image.pixbuf = dummy_pages.first

	    # Update the combo box listing for chapters & pages
	    # Update the pages combobox
	    update_combobox(dummy_pages.page_titles, pages)

	    # Update the chapters combobox
	    update_combobox(dummy_volumes.chapters.map do |chp|
		chp.title
	    end, chapters)

	    # Set the combo box index
	    chapters.active = 0
	    pages.active = 0

	    # Setup the forward/backward button status
	    update_sensitiveness(dummy_pages, dummy_chapters, dummy_volumes, forward, back)
	end
    end

    window = builder.get_object('viewer_window')
    window.show_all

    # Show/hide widgets
    #builder.get_object('chapters_hbox').hide_all
    #builder.get_object('volumes_hbox').hide_all
end


##############################
# Update the combobox
##############################
def update_combobox (list, combobox)
	list_store = Gtk::ListStore.new(String)
	list.each do |text|
	    (list_store.append())[0] = text
	end
	combobox.model = list_store
end


##############################
# Update the sensitiveness
# of back/forward button
##############################
def update_sensitiveness(pages, chapters, volumes, forward, back)
    if pages.next?
	forward.sensitive = true
    else
	if chapters.nil? and volumes.nil?
	    forward.sensitive = false
	elsif volumes.nil?
	    if chapters.next?
		forward.sensitive = true
	    else
		forward.sensitive = false
	    end
	else
	    if chapters.next?
		forward.sensitive = true
	    else
		if volumes.next?
		    forward.sensitive = true
		else
		    forward.sensitive = false
		end
	    end
	end
    end

    if pages.prev?
	back.sensitive = true
    else
	if chapters.nil? and volumes.nil?
	    back.sensitive = false
	elsif volumes.nil?
	    if chapters.prev?
		back.sensitive = true
	    else
		back.sensitive = false
	    end
	else
	    if chapters.prev?
		back.sensitive = true
	    else
		if volumes.prev?
		    back.sensitive = true
		else
		    back.sensitive = false
		end
	    end
	end
    end
end
