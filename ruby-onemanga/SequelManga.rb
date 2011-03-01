#
# Implements the API defined in the manga-*.txt notes in the notes directory
# for the Sequel Testing API
#
module SequelManga

    require 'gtk2'
    require 'sequel'

    # This is only a "meta" object for "constructing" the entire structure of
    # this "dummy site"
    class SequelMangaConstructor

	# Setup the sequel db connection
	DB = Sequel.connect('sqlite://SequelManga.db')

	def initialize
	    # Create the Manga Site table
	    DB.create_table! :sites do
		primary_key :id
		String :site_name, :unique => true
	    end

	    # Create the categories/genre table
	    DB.create_table! :category do
		primary_key :id
		String :category, :unique => true

		# Foreign Key
		Integer :site_id
		Integer :info_id
	    end

	    # Create the Manga Info table
	    DB.create_table! :infos do
		primary_key :id
		String :title
		# Alt titles [blah, foo]
		# Artist [blah, blz]
		Integer :schedule_id
		Integer :state_id
		Integer :status_id
		# Total [x, y, z]
		Date :last_update
		Date :release_year
		# Serialized ?
		Date :when_added
		Integer :site_ranking
		# Rating [rate, out_of, total]
		# Views [Number, Type Of]
		Text :summary

		# Foreign Key
		Integer :site_id
	    end
	end

	def populate
	    # Populate the categories table
	    c1 = DB[:category].insert(:category => "Action")
	    c2 = DB[:category].insert(:category => "Adventure")
	    c3 = DB[:category].insert(:category => "Drama")

	    # Populate the Manga Info table
	    i1 = DB[:infos].insert(
		:title		=> "UNTIL DEATH DO US PART",
		:schedule_id	=> MangaUtils::MangaReleaseStatus::REGULAR,
		:state_id	=> MangaUtils::MangaStatus::UNCOMPLETED,
		:status_id	=> MangaUtils::MangaChapterStatus::NEW,
		:last_update	=> Time.utc(2009, 10, 3),
		:release_year	=> Time.utc(2005),
		:when_added	=> Time.utc(2008, 6, 2),
		:site_ranking	=> 332,
		:summary	=> "A girl named Haruka Tōyama happens to be in the care of a certain company because she can see the future, but she wants to get away, so using her abilities she finds a blind though strong man and asks him to help her as a body guard 'till death do them part. The man, named Mamoru Hijikata, quickly dismisses her request as a joke from a small 12 year old kid, only to realize what shady business has beginning to unfold when people willing to do anything are desperately searching for the girl. As she predicted, Mamoru has past experience in shady business himself, and will not be pushed around easily by any criminal.

		... Is 'protection' the only reason that Haruka approached Mamoru? Or could it be something else?"
	    )

	    # Populate Manga Info Category
	    manga = Info[i1]
	    manga.add_category(Category[c1])
	    manga.add_category(Category[c3])
	    manga.save


	    # Populate the site table
	    s1 = DB[:sites].insert(:site_name => "One Manga")

	    # Populate site Category
	    site = Site[s1]
	    site.add_category(Category[c1])
	    site.add_category(Category[c2])
	    site.add_category(Category[c3])

	    # Populate Site Manga Info
	    site.add_info(Info[i1])
	    site.save

	    @site = s1
	end

	# Return the manga site
	def getSite
	    return Site[@site]
	end
    end
    
    
    #######################################################################
    # Category/Genre information
    #######################################################################
    class Category < Sequel::Model(:category)
	many_to_one :sites
	many_to_one :infos

	# to_string for debugging
	def to_s
	    return "#{category}"
	end
    end


    #######################################################################
    # Per Manga Site Information - This really is the "root" for each site
    # it holds the list of all manga, and some other informations that may
    # be needed for displaying data/etc
    #######################################################################
    class Site < Sequel::Model
	# List of categories/genre of manga that are available on the site
	one_to_many :category

	# List of all of the MangaInfo - multiple objects, on this site
	one_to_many :info


	# to_string for debugging
	def to_s
	    ret = "[Manga Site]\n"
	    ret += "\tName: #{site_name}\n"
	    ret += "\tCategories: #{category.join(', ')}\n"
	    ret += "#{info.join('\n')}\n"
	    return ret
	end
    end


    #######################################################################
    # Per manga Information - Each object holds information on one manga
    #######################################################################
    class Info < Sequel::Model
	# List of categories/genre of manga that are available on the site
	one_to_many :category

	# to_string for debugging
	def to_s
	    ret = "[Manga Info]\n"
	    ret += "\tTitle: #{title}\n"
	    ret += "\tCategories: #{category.join(', ')}\n"
	    ret += "\tSchedule id: #{schedule_id}\n"
	    ret += "\tState id: #{state_id}\n"
	    ret += "\tStatus id: #{status_id}\n"
	    ret += "\tLast Update: #{last_update}\n"
	    ret += "\tRelease Year: #{release_year}\n"
	    ret += "\tWhen Added: #{when_added}\n"
	    ret += "\tSite Ranking: #{site_ranking}\n"
#	    ret += "\tSummary: #{summary}\n"

	    return ret
	end
    end
    
    class MangaInfo
	# Front page picture, it will return a single image if there is only one
	# cover image.  However if there is more than one cover page image such
	# as one cover page image per volume, it will return an array with the
	# pictures in sequial order from first to last volume.
	def cover_pages
	    if @cover_page_paths.is_a? Array
		ret = []
		@cover_page_paths.each do |path|
		    ret.push(Gdk::Pixbuf.new(path))
		end
	    else
		ret = Gdk::Pixbuf.new(@cover_page_paths)
	    end
	    return ret
	end

	# Manga's Title
	attr_reader :title

	# Alternative Titles, there may be more than one.  If there is more than
	# one an array will be returned, otherwise it'll return a nil
	attr_reader :alt_titles

	# The manga's Categories/Genres, if there is more than one, it will be
	# returned as an array
	attr_reader :categories

	# Authors, if there is more than one its returned as an array
	attr_reader :authors

	# Artists, if there is more than one, its then returned as an array
	attr_reader :artists

	# Manga release schedule, such as irregular, regular, unknown, in other
	# words the schedule that the scanlators releases new materials - MangaUtil::ENUM
	attr_reader :release_schedule

	# The state of the manga, IE is it completed, uncompleted, or
	# suspended? - MangaUtil::ENUM
	attr_reader :state

	# The status of the manga, is it newly updated, new addition, or "hot"
	# meaning popular - MangaUtil::ENUM
	attr_reader :status

	# Manga size/total - number of pages, number of chapters, and number of
	# volumes, anyway it will return nil for unknown values, this function
	# won't actually hold the total number, it probably will query the list
	# of volumes/chapters for that information...
	# [10, 88, nil] - 10 Vol, 88 chp, unknown pages
	attr_reader :total

	# Latest chapter - A direct link to the latest chapter
	attr_reader :latest_chapter

	# Last update - The last time it was updated
	attr_reader :last_update

	# Year of release - Date/time object perhaps?
	attr_reader :release_year

	# Which magzine it was serialized in
	attr_reader :serialized_in

	# date/time it was added to the site - Date/time object
	attr_reader :when_added

	# Ranking on the site
	attr_reader :site_ranking

	# Rating on the site for this manga (rating, out-of, votes)
	attr_reader :rating

	# Views (number, type(monthly, weekly, etc)) - MangaUtil::ENUM
	attr_reader :views

	# Summary - Summary of the manga itself
	attr_reader :summary


	# Parent MangaSite
	attr_reader :manga_site


	# List of MangaVolumes, assigned to this manga - multiple objects
	# if volumes are not used, will return a nil?
	attr_reader :volumes

	# List of MangaChapters, assigned to this manga - multiple objects
	# if volumes are used, this will be a nil, otherwise if volume is
	# not used and chapters are used this will return an array of MangaChapters
	attr_reader :chapters


	# List of MangaPages - Really a single object that deals with "pagation",
	# if chapters or volumes are being used, this will return a nil, otherwise
	# it will return a single object that deals with pagation, this part is not
	# still certain yet...
	attr_reader :pages


	# The class constructor
#	def initialize (title, alt_titles, categories, authors, artists,
#			releases, state, status, total, latest_chapter, last_update,
#			release_year, serialized, add_date, ranking, rating, views,
#			summary, manga_site, volumes, chapters, pages, cover_pages)
#	    @title = title
#	    @alt_titles = alt_titles
#	    @categories = categories
#	    @authors = authors
#	    @artists = artists
#
#	    @release_schedule = releases
#	    @state = state
#	    @status = status
#	    @total = total
#
#	    @latest_chapter = latest_chapter
#	    @last_update = last_update
#	    @release_year = release_year
#	    @serialized_in = serialized
#	    @when_added = add_date
#
#	    @site_ranking = ranking
#	    @rating = rating
#	    @views = views
#
#	    @summary = summary
#
#	    @manga_site = manga_site
#
#	    @volumes = volumes
#	    @chapters = chapters
#	    @pages = pages
#
#	    @cover_page_paths = cover_pages
#	end

	# Setter for volumes list (not offical)
	attr_writer :volumes

	# Setter for chapters list (Not offical)
	attr_writer :chapters

	# Setter for pages list (Not offical)
	attr_writer :pages


	# to_string for debugging
#	def to_s
#	    ret  = "Title: #{@title}\n"
#
#	    if (@alt_titles.is_a? Array)
#		ret += "Alt Titles: #{@alt_titles.join(', ')}\n"
#	    else
#		ret += "Alt Titles: #{@alt_titles}\n"
#	    end
#
#	    if (@authors.is_a? Array)
#		ret += "Authors: #{@authors.join(', ')}\n"
#	    else
#		ret += "Authors: #{@authors}\n"
#	    end
#
#	    if (@artists.is_a? Array)
#		ret += "Artists: #{@artists.join(', ')}\n"
#	    else
#		ret += "Artists: #{@artists}\n"
#	    end
#
#	    ret += "Release Schedule: #{@release_schedule}\n"
#	    ret += "State: #{@state}\n"
#	    ret += "Status: #{@status}\n"
#
#	    ret += "Total:\n\tVol: #{@total[0]}\n\tChp: #{@total[1]}\n\tPage: #{@total[2]}\n"
#
#	    ret += "Latest Chapter: #{@latest_chapter}\n"
#	    ret += "Last Update: #{@last_update}\n"
#	    ret += "Release Year: #{@release_year}\n"
#	    ret += "Serialized in: #{@serialized_in}\n"
#	    ret += "When Added: #{@when_added}\n"
#	    ret += "Site Ranking: #{@site_ranking}\n"
#
#	    if (@rating.nil?)
#		ret += "Rating:\n\tRating:\n\tVotes:\n"
#	    else
#		ret += "Rating:\n\tRating: (#{@rating[0]}/#{@rating[1]})\n\tVotes: #{@rating[2]}\n"
#	    end
#
#	    if (@views.nil?)
#		ret += "Views:\n\tNumber:\n\tType:\n"
#	    else
#		ret += "Views:\n\tNumber: #{@views[0]}\n\tType: #{@views[1]}\n"
#	    end
#
#	    ret += "Summary:\n****\n#{@summary}\n****\n\n"
#
#	    if (@volumes.is_a? Array)
#		@volumes.each do |vol|
#		    ret += "[MangaVolumes]\n#{vol.to_s}"
#		end
#	    else
#		if (@volumes.nil?)
#		    ret += "[MangaVolumes]\n-Not Used-\n\n"
#		else
#		    ret += "[MangaVolumes]\n#{@volumes.to_s}\n"
#		end
#	    end
#
#
#	    if (@chapters.is_a? Array)
#		@chapters.each do |chp|
#		    ret += "[MangaChapters]\n#{chp.to_s}\n"
#		end
#	    else
#		if (@chapters.nil?)
#		    ret += "[MangaChapters]\n-Not Used-\n\n"
#		else
#		    ret += "[MangaChapters]\n#{@chapters.to_s}\n"
#		end
#	    end
#
#
#	    if (@pages.is_a? Array)
#		@pages.each do |pg|
#		    ret += "[MangaPages]\n#{pg.to_s}\n"
#		end
#	    else
#		if (@pages.nil?)
#		    ret += "[MangaPages]\n-Not Used-\n\n"
#		else
#		    ret += "[MangaPages]\n#{@pages.to_s}\n"
#		end
#	    end
#
#
#	    return ret
#	end
    end


    #######################################################################
    # Per Volume Information - Each object holds information on one volume
    #######################################################################
    class MangaVolumes

	# If the manga volume has a specific title for each volume, return
	# this volume's "title", otherwise return a nil
	attr_reader :title

	# Volume number, IE Vol 01, Vol 02, etc.. (Also used for sorting)
	attr_reader :number

	# Parent MangaInfo object - one object
	attr_reader :manga_info

	# Next & Previous volume object, if there is no more, it will be nil
	attr_reader :next, :prev

	# Check if next/prev volume exist
	def next?
	    return (not @next.nil?)
	end

	def prev?
	    return (not @prev.nil?)
	end

	# List of MangaChapters object assigned to this volume - Multiple object
	attr_reader :chapters

	# Cover page image for the volume
	def cover_page
	    return Gdk::Pixbuf.new(@cover_page_path)
	end


	# The class constructor
	def initialize (title, number, manga_info, next_vol, prev_vol,
			cover_page_path, chapters)
	    @title = title
	    @number = number
	    @manga_info = manga_info
	    @next = next_vol
	    @prev = prev_vol

	    @cover_page_path = cover_page_path

	    @chapters = chapters
	end


	# Setter for prev/next chapter (Not offical)
	attr_writer :next
	attr_writer :prev

	# Setter for chapters (Not offical)
	attr_writer :chapters


	# to_string for debugging
	def to_s
	    ret  = "Title: #{@title}\n"
	    ret += "Number: #{@number}\n"

	    ret += "Next/Prev:\n\tPrev: #{@prev.title unless @prev.nil?}\n"
	    ret += "\tNext: #{@next.title unless @next.nil?}\n\n"

	    if (@chapters.is_a? Array)
		@chapters.each do |chp|
		    ret += "[MangaChapters]\n#{chp.to_s}\n"
		end
	    else
		if (@chapters.nil?)
		    ret += "[MangaChapters]\n-Not Used-\n\n"
		else
		    ret += "[MangaChapters]\n#{@chapters.to_s}\n\n"
		end
	    end

	    return ret
	end
    end


    #######################################################################
    # Per Chapter Information - each object holds information on one chapter
    #######################################################################
    class MangaChapters

	# If the manga has an specific title for each chapter, otherwise
	# its nil
	attr_reader :title

	# Chapter "number" - IE Chp 01, Chp 02... (Also used for sorting)
	attr_reader :number

	# Chapter "Status" - IE is it a newly added chapter? - MangaUtil::ENUM
	attr_reader :status
	# ex: - MangaUtil::MangaChapterStatus::NEW

	# Scanlator/Scanned by
	attr_reader :scanlator

	# The date that "this" chapter was added/updated - Date/time object
	attr_reader :date_added

	# Number of Pages in this chapter - Not sure if needed
	attr_reader :num_pages


	# Parent MangaVolume object - one object
	attr_reader :volume

	# Parent MangaInfo object - one object
	attr_reader :manga_info

	# Next & Previous chapter object, if there is no more, it will be nil
	attr_reader :next, :prev

	# Check if next/prev chapter exist
	def next?
	    return (not @next.nil?)
	end

	def prev?
	    return (not @prev.nil?)
	end

	# The "MangaPages" Object, which takes care of pages/pagation - one object
	attr_reader :pages


	# The class constructor
	def initialize (title, number, status, scanlator, date_added, number_of_pages,
			volume, manga_info, next_chapter, prev_chapter,
			manga_pages)
	    @title = title
	    @number = number
	    @status = status
	    @scanlator = scanlator
	    @date_added = date_added
	    @num_pages = number_of_pages

	    @volume = volume
	    @manga_info = manga_info
	    @next = next_chapter
	    @prev = prev_chapter

	    @pages = manga_pages
	end

	# Setter for prev/next chapter (Not offical)
	attr_writer :next
	attr_writer :prev

	# Setter for pages (Not offical)
	attr_writer :pages


	# to_string for debugging
	def to_s
	    ret  = "Title: #{@title}\n"
	    ret += "Number: #{@number}\n"
	    ret += "Status: #{@status}\n"
	    ret += "Scanlator: #{@scanlator}\n"
	    ret += "Date Added: #{@date_added}\n"
	    ret += "Number Pages: #{@num_pages}\n"

	    ret += "Next/Prev:\n\tPrev: #{@prev.title unless @prev.nil?}\n"
	    ret += "\tNext: #{@next.title unless @next.nil?}\n\n"

	    if (@pages.is_a? Array)
		@pages.each do |pg|
		    ret += "[MangaPages]\n#{pg.to_s}"
		end
	    else
		if (@pages.nil?)
		    ret += "[MangaPages]\n-Not Used-\n"
		else
		    ret += "[MangaPages]\n#{@pages.to_s}"
		end
	    end

	    return ret
	end
    end


    #######################################################################
    # Per "Page" Information - Information on each pages (really its the
    # same object, but it simulates one object per page, it takes care of
    # pagation)
    #######################################################################
    class MangaPages
	# Returns a list of "names" for each page, ie "00 - credit"
	attr_reader :page_titles


	# Parent MangaChapter object - one object
	attr_reader :chapter

	# Parent MangaInfo object - one object
	attr_reader :manga_info

	# First/Last Page picture
	def first
	    @index = 0

	    str  = @directory
	    str += ("v#{@vol_idx}") unless @vol_idx.nil?
	    str += ("c#{@chp_idx}") unless @chp_idx.nil?
	    str += ("p#{@index}.jpg")

	    return Gdk::Pixbuf.new(str)
	end

	def last
	    @index = @max

	    str  = @directory
	    str += ("v#{@vol_idx}") unless @vol_idx.nil?
	    str += ("c#{@chp_idx}") unless @chp_idx.nil?
	    str += ("p#{@index}.jpg")

	    return Gdk::Pixbuf.new(str)
	end

	# Next/Previous page picture
	def next
	    @index += 1

	    str  = @directory
	    str += ("v#{@vol_idx}") unless @vol_idx.nil?
	    str += ("c#{@chp_idx}") unless @chp_idx.nil?
	    str += ("p#{@index}.jpg")

	    return Gdk::Pixbuf.new(str)
	end

	def prev
	    @index -= 1

	    str  = @directory
	    str += ("v#{@vol_idx}") unless @vol_idx.nil?
	    str += ("c#{@chp_idx}") unless @chp_idx.nil?
	    str += ("p#{@index}.jpg")

	    return Gdk::Pixbuf.new(str)
	end


	# Check if next/prev page exist
	def next?
	    return (@index >= @max) ? false : true
	end

	def prev?
	    return (@index < 1) ? false : true
	end


	# Go to the page index specifyed, if the page indicated by the index
	# does not exist it will throw an exception.  Anyway the index is
	# counted from 0 to the last page in the set.
	def goto (index)
	    @index = index

	    str  = @directory
	    str += ("v#{@vol_idx}") unless @vol_idx.nil?
	    str += ("c#{@chp_idx}") unless @chp_idx.nil?
	    str += ("p#{@index}.jpg")

	    return Gdk::Pixbuf.new(str)
	end


	# Returns the "index" of the current page that this "object/iterator" is
	# on
	attr_reader :index


	# Reading direction of the page itself, IE (MangaUtils::ReadingDirection)
	# this is for right to left, or left to right reading direction, etc..
	attr_reader :reading_direction


	# The class constructor
	def initialize (page_titles, chapter, manga_info, reading_direction)
	    @page_titles = page_titles

	    @chapter = chapter
	    @manga_info = manga_info

	    @reading_direction = reading_direction
	end


	# Initalize "file pagation" - (Unoffical)
	def file_init (directory, vol_idx, chp_idx)
	    @index = 0
	    @max = @page_titles.length - 1

	    @directory = directory
	    @vol_idx = vol_idx
	    @chp_idx = chp_idx
	end


	# to_string for debugging
	def to_s
	    ret = "Reading Direction: #{@reading_direction}\n"

	    if (@page_titles.is_a? Array)
		@page_titles.each do |page|
		    ret += "Page Title: #{page}\n"
		end
	    else
		if (@pages.nil?)
		    ret += "Page Title:\n"
		else
		    ret += "Page Title: #{@page_titles}\n"
		end
	    end

	    return ret
	end
    end
end



#
# This is the General Manga Utils module for taking care of misc items
# that all Manga Backend/frontend needs
#
module MangaUtils
    class ReadingDirection
	RIGHT_TO_LEFT = 1
	LEFT_TO_RIGHT = 2
    end

    class MangaReleaseStatus
	REGULAR = 1
	IRREGULAR = 2 # Ongoing
    end

    class MangaStatus
	COMPLETED = 1
	UNCOMPLETED = 2
	SUSPENDED = 3
    end

    class MangaViewType
	EVER = 1
	MONTHLY = 2
	WEEKLY = 3
    end

    class MangaChapterStatus
	NEW = 1
	NORMINAL = 2
    end

    class MangaViews
	FOREVER = 1
	YEARLY = 2
	MONTHLY = 3
	WEEKLY = 4
	DAILY = 5
    end
end


# State machine states here
#
# If there is no more volumes left, there maybe
# more chapters left, thus more pages left
#
# if there is no more chapters left, there maybe
# more pages left
#
# if there is no more pages left, there maybe more
# chapters left, however, if there is no more chapters left
# there maybe more volumes left, if there is no more volumes
# left, its done
#
# more vol, more chp, more pg   - +1 pg
# more vol, more chp, no pg	    - +1 chp, pg = 0
# more vol, no chp,   more pg   - +1 pg
# more vol, no chp,   no pg	    - +1 vol, chp = 0, pg =0
# no vol,   more chp, more pg   - +1 pg
# no vol,   more chp, no pg	    - +1 chp, pg = 0
# no vol,   no chp,   more pg   - +1 pg
# no vol,   no chp,   no pg	    - +1 vol & exit
