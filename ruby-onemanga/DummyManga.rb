#
# Implements the API defined in the manga-*.txt notes in the notes directory
# for the Dummy Testing API
#
module DummyManga

    require 'gtk2'

    # This is only a "meta" object for "constructing" the entire structure of
    # this "dummy site"
    class DummyMangaConstructor
    end


    #######################################################################
    # Per Manga Site Information - This really is the "root" for each site
    # it holds the list of all manga, and some other informations that may
    # be needed for displaying data/etc
    #######################################################################
    class MangaSite
	# List of categories/genre of manga that are available on the site
	attr_reader :categories

	# List of all of the MangaInfo - multiple objects, on this site
	attr_reader :mangas


	# The class constructor
	def initialize (categories, mangas)
	    @categories = categories
	    @mangas = mangas
	end
    end


    #######################################################################
    # Per manga Information - Each object holds information on one manga
    #######################################################################
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
	# words the schedule that the scanlators releases new materials
	attr_reader :release_schedule

	# The state of the manga, IE is it completed, uncompleted, or 
	# suspended?
	attr_reader :state

	# The status of the manga, is it newly updated, new addition, or "hot"
	# meaning popular
	attr_reader :status

	# Manga size/total - number of pages, number of chapters, and number of
	# volumes, anyway it will return nil for unknown values, this function
	# won't actually hold the total number, it probably will query the list
	# of volumes/chapters for that information...
	def total
	    return [10, 88, nil] # IE 10 vol, 88 chapters, unknown pages
	end

	# Latest chapter - A direct link to the latest chapter
	attr_reader :latest_chapter

	# Last update - The last time it was updated
	attr_reader :last_update

	# Year of release - Date/time object perhaps?
	attr_reader :release_year

	# Which magzine it was serialized in
	attr_reader :serialized_in

	# date/time it was added to the site
	attr_reader :when_added

	# Ranking on the site
	attr_reader :site_ranking

	# Rating on the site for this manga (rating, out-of, votes)
	attr_reader :rating

	# Views (number, type(monthly, weekly, etc))
	attr_reader :views


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
	def initialize (title, alt_titles, categories, authors, artists,
			releases, state, status, total, latest_chapter, last_update,
			release_year, serialized, add_date, ranking, rating, views,
			manga_site, volumes, chapters, pages, cover_pages)
	    @title = title
	    @alt_titles = alt_titles
	    @categories = categories
	    @authors = authors
	    @artists = artists

	    @release_schedule = releases
	    @state = state
	    @status = status
	    @total = total

	    @latest_chapter = latest_chapter
	    @last_update = last_update
	    @release_year = release_year
	    @serialized_in = serialized
	    @when_added = add_date

	    @site_ranking = ranking
	    @rating = rating
	    @views = views

	    @manga_site = manga_site

	    @volumes = volumes
	    @chapters = chapters
	    @pages = pages

	    @cover_page_paths = cover_pages
	end
    end


    #######################################################################
    # Per Volume Information - Each object holds information on one volume
    #######################################################################
    class MangaVolumes

	# If the manga volume has a specific title for each volume, return
	# this volume's "title", otherwise return a nil
	attr_reader :title

	# Volume number, IE Vol 01, Vol 02, etc..
	attr_reader :number

	# Parent MangaInfo object - one object
	attr_reader :manga_info

	# Next & Previous volume object, if there is no more, it will be nil
	attr_reader :next, :prev

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
    end


    #######################################################################
    # Per Chapter Information - each object holds information on one chapter
    #######################################################################
    class MangaChapters

	# If the manga has an specific title for each chapter, otherwise
	# its nil
	attr_reader :title

	# Chapter "number" - IE Chp 01, Chp 02...
	attr_reader :number

	# Chapter "Status" - IE is it a newly added chapter?
	attr_reader :status
	# ex: - MangaUtil::MangaChapterStatus::NEW

	# Scanlator/Scanned by
	attr_reader :scanlator

	# The date that "this" chapter was added/updated
	attr_reader :date_added

	# Number of Pages in this chapter - Not sure if needed
	attr_reader :num_pages


	# Parent MangaVolume object - one object
	attr_reader :volume

	# Parent MangaInfo object - one object
	attr_reader :manga_info

	# Next & Previous chapter object, if there is no more, it will be nil
	attr_reader :next, :prev

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
    end




    # Manga Pages
    # TODO: Update this class
    class MangaPages

	def initialize (vol_exist, chp_exist)
	    # Does Volume or Chapters matter
	    @vol_exist = vol_exist
	    @chp_exist = chp_exist

	    # Volume/chapter/page index
	    @vol = 0
	    @chp = 0
	    @pg  = 0
	end


	# These two function returns the Manga, and the Site
	# that this "Manga Page" is from
	def get_manga
	    return MangaInfo.new
	end

	def get_manga_site
	    return MangaSite.new
	end


	# Returns an Pixbuf of the first page, this is to make the next/prev_page
	# code to be simpler, plus when the manga viewer loads up it will want a
	# pixbuf of the first page of the manga anyway (for now)
	def first_page
	    if !@vol_exist & !@chp_exist
		str = "DummyManga-Data/pg/p#{@pg}.jpg"
		return Gdk::Pixbuf.new(str)

	    elsif !@vol_exist & @chp_exist
		str = "DummyManga-Data/chp_pg/c#{@chp}p#{@pg}.jpg"
		return Gdk::Pixbuf.new(str)
	    elsif @vol_exist & @chp_exist
		str = "DummyManga-Data/vol_chp_pg/v#{@vol}c#{@chp}p#{@pg}.jpg"
		return Gdk::Pixbuf.new(str)
	    else
		puts "not implemented"
	    end
	end

	# Returns an Pixbuf of the last page, this is to make the next/prev_page
	# code to be simpler, plus when the manga viewer loads up it will want a
	# pixbuf of the last page of the manga anyway (for now)
	def last_page
	    if !@vol_exist & !@chp_exist
		str = "DummyManga-Data/pg/p#{@pg}.jpg"
		return Gdk::Pixbuf.new(str)

	    elsif !@vol_exist & @chp_exist
		str = "DummyManga-Data/chp_pg/c#{@chp}p#{@pg}.jpg"
		return Gdk::Pixbuf.new(str)
	    elsif @vol_exist & @chp_exist
		str = "DummyManga-Data/vol_chp_pg/v#{@vol}c#{@chp}p#{@pg}.jpg"
		return Gdk::Pixbuf.new(str)
	    else
		puts "not implemented"
	    end
	end


	# Returns an Pixbuf of the page, if its past the last of the pages, it 
	# will return nil to indicate its past the last page
	#
	# If there is a failure at fetching the image, it will throw an exception
	def next_page
	    if !@vol_exist & !@chp_exist
		if @pg >= 7
		    return nil
		else
		    @pg += 1
		    str = "DummyManga-Data/pg/p#{@pg}.jpg"

		    return Gdk::Pixbuf.new(str)
		end
	    elsif !@vol_exist & @chp_exist
		if @pg >= 3
		    return nil
		else
		    @pg += 1
		    str = "DummyManga-Data/chp_pg/c#{@chp}p#{@pg}.jpg"

		    return Gdk::Pixbuf.new(str)
		end
	    elsif @vol_exist & @chp_exist
		if @pg >= 1
		    return nil
		else
		    @pg += 1
		    str = "DummyManga-Data/vol_chp_pg/v#{@vol}c#{@chp}p#{@pg}.jpg"

		    return Gdk::Pixbuf.new(str)
		end
	    else
		puts "not implemented"
	    end
	end

	def next_page?
	    if !@vol_exist & !@chp_exist
		return (@pg >= 7) ? false : true
	    elsif !@vol_exist & @chp_exist
		return (@pg >= 3) ? false : true
	    elsif @vol_exist & @chp_exist
		return (@pg >= 1) ? false : true
	    else
		puts "not implemented"
	    end
	end


	# Same thing as the "next_page" class of function
	def prev_page
	    if !@vol_exist & !@chp_exist
		if @pg < 1
		    return nil
		else
		    @pg -= 1
		    str = "DummyManga-Data/pg/p#{@pg}.jpg"

		    return Gdk::Pixbuf.new(str)
		end
	    elsif !@vol_exist & @chp_exist
		if @pg < 1
		    return nil
		else
		    @pg -= 1
		    str = "DummyManga-Data/chp_pg/c#{@chp}p#{@pg}.jpg"

		    return Gdk::Pixbuf.new(str)
		end
	    elsif @vol_exist & @chp_exist
		if @pg < 1
		    return nil
		else
		    @pg -= 1
		    str = "DummyManga-Data/vol_chp_pg/v#{@vol}c#{@chp}p#{@pg}.jpg"

		    return Gdk::Pixbuf.new(str)
		end
	    else
		puts "not implemented"
	    end
	end

	def prev_page?
	    if !@vol_exist & !@chp_exist
		return (@pg < 1) ? false : true
	    elsif !@vol_exist & @chp_exist
		return (@pg < 1) ? false : true
	    elsif @vol_exist & @chp_exist
		return (@pg < 1) ? false : true
	    else
		puts "not implemented"
	    end
	end

	# This function will go to the page as specifyed in the index passed
	# as a parameter, it will then return an image of that said page and
	# reset the "internal" iterator to resume from that point in time.
	# otherwise it functions just like the "next_page" class of function
	# 
	# Also if the page as indicated by the index does not exist, it will
	# throw an exception
	def goto_page (index)
	    if !@vol_exist & !@chp_exist
		@pg = index
		str = "DummyManga-Data/pg/p#{@pg}.jpg"

		return Gdk::Pixbuf.new(str)
	    elsif !@vol_exist & @chp_exist
		@pg = index
		str = "DummyManga-Data/chp_pg/c#{@chp}p#{@pg}.jpg"

		return Gdk::Pixbuf.new(str)
	    elsif @vol_exist & @chp_exist
		@pg = index
		str = "DummyManga-Data/vol_chp_pg/v#{@vol}c#{@chp}p#{@pg}.jpg"

		return Gdk::Pixbuf.new(str)
	    else
		puts "not implemented"
	    end
	end


	# This function will return the next "MangaPages" object, which can
	# be this current object if the Manga Site/Backend does not have the
	# concept of "Chapters".  This function will return nil if there is
	# no more chapters to fetch, the "pages count is undefined at the moment"
	def next_chapter
	    if !@vol_exist & @chp_exist
		if @chp >= 1
		    return nil
		else
		    @chp += 1
		    @pg = 0

		    return self
		end
	    elsif @vol_exist & @chp_exist
		if @chp >= 1
		    return nil
		else
		    @chp += 1
		    @pg = 0

		    return self
		end
	    else
		puts "not implemented"
		return nil
	    end
	end

	def next_chapter?
	    if !@vol_exist & @chp_exist
		return (@chp >= 1) ? false : true
	    elsif @vol_exist & @chp_exist
		return (@chp >= 1) ? false : true
	    else
		puts "not implemented"
		return nil
	    end
	end


	# Same thing as the "next_chapter" class of function
	def prev_chapter
	    if !@vol_exist & @chp_exist
		if @chp < 1
		    return nil
		else
		    @chp -= 1
		    @pg = 3

		    return self
		end
	    elsif @vol_exist & @chp_exist
		if @chp < 1
		    return nil
		else
		    @chp -= 1
		    @pg = 1

		    return self
		end
	    else
		puts "not implemented"
		return nil
	    end
	end

	def prev_chapter?
	    if !@vol_exist & @chp_exist
		return (@chp < 1) ? false : true
	    elsif @vol_exist & @chp_exist
		return (@chp < 1) ? false : true
	    else
		puts "not implemented"
		return nil
	    end
	end


	# Same thing as the "goto_page" function, however with respect
	# to chapters, the results is the same, but applied to chapters
	#
	# It defaults to the first page of each chapter
	def goto_chapter (index)
	    if !@vol_exist & @chp_exist
		@pg = 0
		@chp = index

		return first_page
	    elsif @vol_exist & @chp_exist
		@pg = 0
		@chp = index

		return first_page
	    else
		puts "not implemented"
		return nil
	    end
	end


	# Most Manga Backend does not really have the concept of 
	# Manga Volume so this class of function is somewhat redudant,
	# however its still here for those backends that do.
	#
	# Regardless, the functionality here is the same as the
	# "*_chapter" classes of function, just applied to volumes
	def next_volume
	    if @vol_exist & @chp_exist
		if @vol >= 1
		    return nil
		else
		    @vol += 1
		    @chp = 0
		    @pg = 0

		    return self
		end
	    end
	end

	def next_volume?
	    if @vol_exist & @chp_exist
		return (@vol >= 1) ? false : true
	    end
	end


	def prev_volume
	    if @vol_exist & @chp_exist
		if @vol < 1
		    return nil
		else
		    @vol -= 1
		    @chp = 1
		    @pg = 1

		    return self
		end
	    end
	end

	def prev_volume?
	    if @vol_exist & @chp_exist
		return (@vol < 1) ? false : true
	    end
	end


	def goto_volume (index)
	    if @vol_exist & @chp_exist
		@pg = 0
		@chp = 0
		@vol = index

		return first_page
	    end
	end


	# This function returns an enum (MangaUtils::ReadingDirection::)
	# for which direction that the manga is read, IE right to left
	# or left to right
	def reading_direction
	    return MangaUtils::ReadingDirection::RIGHT_TO_LEFT
	end


	# These family of function returns the current index of the 
	# MangaPages, in volumes/chapter/page, and if one of these
	# function/class are not used it will return nil
	def currentVolumeIndex
	    return @vol
	end

	def currentChapterIndex
	    return @chp
	end

	def currentPageIndex
	    return @pg
	end


	# These family of function will return a list for use by the 
	# GUI (IE chapter names or numbers for example)
	#
	# If its not used it will return nil also if there is problems
	# fetching that information, it will also toss out an exception
	def list_volumes
	    if @vol_exist & @chp_exist
		return ["Vol 0", "Vol 1"]
	    end
	end

	def list_chapters
	    if !@vol_exist & !@chp_exist
		return nil
	    elsif !@vol_exist & @chp_exist
		return ["Chp 0", "Chp 1"]
	    elsif @vol_exist & @chp_exist
		return ["Chp 0", "Chp 1"]
	    else
		puts "not implemented"
		return nil
	    end
	end

	def list_pages
	    if !@vol_exist & !@chp_exist
		return ["Pg 0", "Pg 1", "Pg 2", "Pg 3", "Pg 4", "Pg 5", "Pg 6", "Pg 7"]
	    elsif !@vol_exist & @chp_exist
		return ["Pg 0", "Pg 1", "Pg 2", "Pg 3"]
	    elsif @vol_exist & @chp_exist
		return ["Pg 0", "Pg 1"]
	    else
		puts "not implemented"
		return nil
	    end
	end


	# The to_s function
	def to_s
	    return "v:#{@vol} c:#{@chp} p:#{@pg} - v:#{@exist_more_vol} c:#{@exist_more_chp} p:#{@exist_more_pg}"
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
