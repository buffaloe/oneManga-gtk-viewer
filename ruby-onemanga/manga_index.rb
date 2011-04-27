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

def build_manga_index(dummy)
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

    update_combobox([dummy.site_name], site)
    site.active = 0

    # Setup the site category combo_box
    render = Gtk::CellRendererText.new
    category.pack_start(render, true)
    category.set_attributes(render, {"text" => 0})

    update_combobox(dummy.category.map {|cat| cat.category}, category)
    category.active = 0


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
    list = Gtk::ListStore.new(Integer)
    dummy.info.each do |info|
	list.append.set_value(0, info.id)
    end
    manga_list.model = list

    # setup all of the listeners/actions/events
    manga_list.selection.mode = Gtk::SELECTION_SINGLE
    manga_list.selection.set_select_function { |selection, model, path, path_selected|
	iter = model.get_iter(path)
	id = model.get_value(iter, 0)
	info = SequelManga::Info[id]
	update_manga_info(info, builder)
    }

    window = builder.get_object('list_window')
    window.show_all
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
# Update manga info panel
##############################
def update_manga_info (manga, builder)
    # Deal with image latter
    cover = builder.get_object('image')

    # Infobox/etc
    title = builder.get_object('title_entry')
    alt_titles = builder.get_object('alt_titles_entry')
    authors = builder.get_object('authors_entry')
    artists = builder.get_object('artists_entry')
    categories = builder.get_object('categories_entry')
    schedule = builder.get_object('schedule_entry')
    state = builder.get_object('state_entry')
    status = builder.get_object('status_entry')
    last_update = builder.get_object('last_update_entry')
    release_year = builder.get_object('release_year_entry')
    when_added = builder.get_object('when_added_entry')
    site_ranking = builder.get_object('site_ranking_entry')
    summary = builder.get_object('summary_textview')

    # Set them
    title.text = manga.title
    alt_titles.text = manga.alt_titles.join(', ')
    authors.text = manga.author.join(', ')
    artists.text = manga.artist.join(', ')
    categories.text = manga.category.join(', ')
    schedule.text = manga.schedule
    state.text = manga.state
    status.text = manga.status
    last_update.text = manga.last_update
    release_year.text = manga.release_year.year.to_s
    when_added.text = manga.when_added
    site_ranking.text = manga.site_ranking.to_s

    summary.set_buffer((Gtk::TextBuffer.new).set_text(manga.summary))
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
