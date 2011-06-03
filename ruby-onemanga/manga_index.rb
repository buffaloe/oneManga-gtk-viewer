#!/usr/bin/env ruby
# ruby-OneManga Viewer
#
# Copyright (c) 2009, Paul Berens
#
# You can redistribute it and/or modify it under the terms of
# the GPL's licence.
#

require 'gtk2'
require 'SequelManga'

def build_manga_index(dummy, fetcher)
    builder = Gtk::Builder.new
    builder.add_from_file('view/manga-list.glade')

    ####################
    # Site combobox
    ####################
    site = builder.get_object('site_combobox')
    category = builder.get_object('category_combobox')

    # Setup the site combo_box
    render = Gtk::CellRendererText.new
    site.pack_start(render, true)
    site.set_attributes(render, {"text" => 0})

    update_site_combobox([dummy.site_name], site)
    site.active = 0

    # Setup the site category combo_box
    render = Gtk::CellRendererText.new
    category.pack_start(render, true)
    category.set_attributes(render, {"text" => 0})

    update_category_combobox(dummy.category, dummy.info.length, dummy.id, category)
    category.active = 0

    # Fix up the TextView with its own TextBuffer
    summary = builder.get_object('summary_textview')
    summary.set_buffer(Gtk::TextBuffer.new)

    # Treeview stuff
    manga_list = builder.get_object('manga_list')
    # Title - Schedule - State - Site Ranking
    title_cell = Gtk::CellRendererText.new
    title_col = Gtk::TreeViewColumn.new("Title", title_cell, :text => 0)
#    schedule_cell = Gtk::CellRendererText.new
#    schedule_col = Gtk::TreeViewColumn.new("Schedule", schedule_cell, :text => 0)
#    state_cell = Gtk::CellRendererText.new
#    state_col = Gtk::TreeViewColumn.new("State", state_cell, :text => 0)
#    site_ranking_cell = Gtk::CellRendererText.new
#    site_ranking_col = Gtk::TreeViewColumn.new("Site Ranking", site_ranking_cell, :text => 0)

    title_col.set_cell_data_func(title_cell) do |tvc, cell, model, iter|
	id = model.get_value(iter, 0)
	info = SequelManga::Info[id]
	cell.text = info.title
    end

    manga_list.append_column(title_col)
#    manga_list.append_column(schedule_col)
#    manga_list.append_column(state_col)
#    manga_list.append_column(site_ranking_col)

    # Populate the list
    update_manga_list(dummy.info, manga_list)

    # setup all of the listeners/actions/events
    manga_list.selection.mode = Gtk::SELECTION_SINGLE
    manga_list.selection.set_select_function { |selection, model, path, path_selected|
	iter = model.get_iter(path)
	id = model.get_value(iter, 0)
	info = SequelManga::Info[id]
	update_manga_info(info, fetcher, builder)
    }

    # Combobox listener
    category.signal_connect('changed') do |combobox|
	# See if its "all" if so get "all category mangas"
	model = combobox.model
	iter = model.get_iter(Gtk::TreePath.new(combobox.active))
	value = iter.get_value(0)

	# TODO: Find a better way of dealing with this
	# Strip the (/d) off
	value = value.slice(0, value.index(' ('))

	if value == "all"
	    update_manga_list(dummy.info, manga_list)
	else
	    # list of "all" manga -> dummy.info
	    update_manga_list(dummy.info_category(value), manga_list)
	end
    end


    window = builder.get_object('list_window')
    window.show_all
end

##############################
# Update/populate the manga_list
##############################
def update_manga_list (list, manga_list)
    list_store = Gtk::ListStore.new(Integer)
    list.each do |info|
	list_store.append.set_value(0, info.id)
    end
    manga_list.model = list_store
end

##############################
# Update the combobox
##############################
def update_site_combobox (list, combobox)
    list_store = Gtk::ListStore.new(String)
    list.each do |text|
	(list_store.append())[0] = text
    end
    combobox.model = list_store
end

##############################
# Update the combobox
##############################
def update_category_combobox (list, total_info, site_id, combobox)
    list_store = Gtk::ListStore.new(String, Integer)
    (list_store.append())[0] = "all" + " (" + total_info.to_s + ")"

    list.each do |text|
	(list_store.append())[0] = text.category + " (" + text.count_site_specific_info(site_id).to_s + ")"
    end
    combobox.model = list_store
end

##############################
# Update manga info panel
##############################
def update_manga_info (manga, fetcher, builder)
    title = builder.get_object('title_entry')
    if manga.title.nil?
	title.text = ""
    else
	title.text = manga.title
    end

    alt_titles = builder.get_object('alt_titles_entry')
    if manga.alt_titles.nil? or manga.alt_titles.empty?
	alt_titles.text = ""
    else
	alt_titles.text = manga.alt_titles.join(', ')
    end

    authors = builder.get_object('authors_entry')
    if manga.author.nil? or manga.author.empty?
	authors.text = ""
    else
	authors.text = manga.author.join(', ')
    end

    artists = builder.get_object('artists_entry')
    if manga.artist.nil? or manga.artist.empty?
	artist.text = ""
    else
	artists.text = manga.artist.join(', ')
    end

    categories = builder.get_object('categories_entry')
    if manga.category.nil? or manga.category.empty?
	categories.text = ""
    else
	categories.text = manga.category.join(', ')
    end

    schedule = builder.get_object('schedule_entry')
    if manga.schedule.nil?
	schedule.text = ""
    else
	schedule.text = manga.schedule
    end

    state = builder.get_object('state_entry')
    if manga.state.nil?
	state.text = ""
    else
	state.text = manga.state
    end

    status = builder.get_object('status_entry')
    if manga.status.nil?
	status.text = ""
    else
	status.text = manga.status
    end

    last_update = builder.get_object('last_update_entry')
    if manga.last_update.nil?
	last_update.text = ""
    else
	last_update.text = manga.last_update
    end

    release_year = builder.get_object('release_year_entry')
    if manga.release_year.nil?
	release_year.text = ""
    else
	release_year.text = manga.release_year.year.to_s
    end

    when_added = builder.get_object('when_added_entry')
    if manga.when_added.nil?
	when_added.text = ""
    else
	when_added.text = manga.when_added
    end

    site_ranking = builder.get_object('site_ranking_entry')
    if manga.site_ranking.nil?
	site_ranking.text = ""
    else
	site_ranking.text = manga.site_ranking.to_s
    end

    summary = builder.get_object('summary_textview')
    if manga.summary.nil?
	summary.buffer.text = ""
    else
	summary.buffer.text = manga.summary
    end

    # Deal with the image
    cover = builder.get_object('image')
    url = manga.cover_page_url
    image_file = fetcher.get_image(url)

    if !image_file.nil?
	cover.pixbuf = Gdk::Pixbuf.new(image_file)
    else
	cover.stock = Gtk::Stock.MISSING_IMAGE
    end
end


def old
    # Treeview stuff
    manga_list = builder.get_object('manga_list')
    # Title - Schedule - State - Site Ranking
    cell = Gtk::CellRendererText.new
    col  = Gtk::TreeViewColumn.new("test", cell, :text => 0)
    col.set_cell_data_func(cell) { |column, cell, model, iter|
	scrollwindow = builder.get_object('manga_list_scrollwindow')
	vadjust = scrollwindow.vadjustment

	pageSize = vadjust.page_size + 20
	adjGap = vadjust.upper - vadjust.value

	if (manga_list.focus? and adjGap < pageSize)
	    model.append.set_value(0, "test")
	end
    }
    manga_list.append_column(col)

    list = Gtk::ListStore.new(String)
    list.append.set_value(0, "test")
    list.append.set_value(0, "test")
    list.append.set_value(0, "test")
    list.append.set_value(0, "test")
    list.append.set_value(0, "test")
    list.append.set_value(0, "test")
    list.append.set_value(0, "test")
    list.append.set_value(0, "test")

    manga_list.model = list
end
