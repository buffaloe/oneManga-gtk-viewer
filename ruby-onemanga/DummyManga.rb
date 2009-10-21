#
# Implements the API defined in the manga-*.txt notes in the notes directory
# for the Dummy Testing API
#
module DummyManga

    require 'gtk2'

    # This is only a "meta" object for "constructing" the entire structure of
    # this "dummy site"
    class DummyMangaConstructor

	def initialize

	    ##############################
	    # Site Info
	    ##############################

	    # Site values/variables
	    categories = ["Action", "Adventure", "Drama"]

	    # Site Info
	    @site_info = MangaSite.new(categories, nil)


	    ##############################
	    # Manga (1) Info
	    ##############################
	    cover_page = "DummyManga-Data/death/cover.jpg"

	    title = "UNTIL DEATH DO US PART"
	    alt_title = ["Shi ga Futari wo Wakatsu Made", "死がふたりを分かつまで"]
	    categories = ["Action", "Drama"]
	    authors = "Takashige Hiroshi"
	    artists = "Double-s"
	    schedule = MangaUtils::MangaReleaseStatus::REGULAR
	    state = MangaUtils::MangaStatus::UNCOMPLETED
	    status = MangaUtils::MangaChapterStatus::NEW
	    total = [10, 88, nil]
	    last_update = Time.utc(2009, 10, 3)
	    release_year = Time.utc(2005)
	    serialized = nil
	    when_added = Time.utc(2008, 6, 2)
	    site_ranking = 332
	    rating = [4.97, 5, 320]
	    views = [32372, MangaUtils::MangaViews::MONTHLY]

	    summary = "A girl named Haruka Tōyama happens to be in the care of a certain company because she can see the future, but she wants to get away, so using her abilities she finds a blind though strong man and asks him to help her as a body guard 'till death do them part. The man, named Mamoru Hijikata, quickly dismisses her request as a joke from a small 12 year old kid, only to realize what shady business has beginning to unfold when people willing to do anything are desperately searching for the girl. As she predicted, Mamoru has past experience in shady business himself, and will not be pushed around easily by any criminal.

	    ... Is 'protection' the only reason that Haruka approached Mamoru? Or could it be something else?"

	    manga_info_one = MangaInfo.new(title, alt_title, categories, authors,
					   artists, schedule, state, status, total,
					   nil, last_update, release_year, serialized,
					   when_added, site_ranking, rating, views, summary,
					   @site_info, nil, nil, nil, cover_page)

	    ##############################
	    # Manga (2) Info
	    ##############################
	    cover_page = ["DummyManga-Data/anima/cover01.jpg",
			    "DummyManga-Data/anima/cover02.jpg",
			    "DummyManga-Data/anima/cover03.jpg"]

	    title = "+Anima"
	    alt_title = nil
	    categories = ["Adventure", "Drama"]
	    authors = "Mukai Natsumi"
	    artists = "Mukai Natsumi"
	    schedule = MangaUtils::MangaReleaseStatus::IRREGULAR
	    state = MangaUtils::MangaStatus::UNCOMPLETED
	    status = MangaUtils::MangaChapterStatus::NEW
	    total = [nil, 40, nil]
	    last_update = Time.utc(2008, 7, 27)
	    release_year = nil
	    serialized = nil
	    when_added = Time.utc(2008, 3, 26)
	    site_ranking = 52
	    rating = nil
	    views = nil

	    summary = "Beings who possess animal-like powers walk among humans in this alternate universe. These mysterious mutants, the +Anima, are shunned by society. Four outcasts in particular--Cooro, a boy with crow-like powers; Husky, a fish-boy; Senri, a bear +Anima; and a girl named Nana, who wields the power of the bat--search for others like themselves while trying to gain acceptance in a world cruel to anyone or anything that is different."

	    manga_info_two = MangaInfo.new(title, alt_title, categories, authors,
					   artists, schedule, state, status, total,
					   nil, last_update, release_year, serialized,
					   when_added, site_ranking, rating, views, summary,
					   @site_info, nil, nil, nil, cover_page)

	    ##############################
	    # Manga (3) Info
	    ##############################
	    cover_page = "DummyManga-Data/undead/cover.jpg"

	    title = "Hajimete no Aku"
	    alt_title = ["My First Mr.Akuno"]
	    categories = ["Drama"]
	    authors = ["Fujiki Shun", "Shun Fujiki"]
	    artists = ["Double-s", "Dumbar"]
	    schedule = MangaUtils::MangaReleaseStatus::REGULAR
	    state = MangaUtils::MangaStatus::UNCOMPLETED
	    status = MangaUtils::MangaChapterStatus::NEW
	    total = [nil, nil, 8]
	    last_update = Time.utc(2008, 10, 3)
	    release_year = Time.utc(2003)
	    serialized = nil
	    when_added = Time.utc(2008, 6, 2)
	    site_ranking = 22
	    rating = [4.97, 5, 320]
	    views = [32372, MangaUtils::MangaViews::MONTHLY]

	    summary = "In the spring of Kyoko's first year in high school, Eiko, a girl like a sister to her, returns with her younger brother, Jiro.
	    The return isn't that big of a deal, but Jiro (self proclaimed super mad scientist) has it in his head that he wants to operate on Kyoko!
	    And, what's even more, the two of them are actually high ranking members of an Evil organization at the run for the heroes of justice!
	    As if high school didn't have enough problems already, now she has to deal with these two living with her."

	    manga_info_three = MangaInfo.new(title, alt_title, categories, authors,
					   artists, schedule, state, status, total,
					   nil, last_update, release_year, serialized,
					   when_added, site_ranking, rating, views, summary,
					   @site_info, nil, nil, nil, cover_page)


	    ##############################
	    # Manga (1) Volume/Chapters/Pages
	    ##############################

	    # Volume 0
	    title = "Killers"
	    number = 0
	    cover_page_path = "DummyManga-Data/death/cover.jpg"

	    vol_zero = MangaVolumes.new(title, number, manga_info_one, nil, nil,
					cover_page_path, nil)

	    # Setup Chapter chp_zero
	    title = "Undying One"
	    number = 0
	    status = MangaUtils::MangaChapterStatus::NORMINAL
	    scanlator = "Manga-Urban"
	    date = Time.utc(2008, 2, 26)
	    num_pg = 2

	    chp_zero = MangaChapters.new(title, number, status, scanlator, date,
					  num_pg, nil, manga_info_one, nil, nil, nil)

	    # Setup Pages for chp_zero
	    page_titles = ["Page 0", "Page 1"]
	    reading_dir = MangaUtils::ReadingDirection::LEFT_TO_RIGHT

	    pages_zero = MangaPages.new(page_titles, chp_zero, manga_info_one,
					reading_dir)


	    # Setup Chapter chp_one
	    title = "Dead One"
	    number = 1
	    status = MangaUtils::MangaChapterStatus::NORMINAL
	    scanlator = "Manga-Urban"
	    date = Time.utc(2009, 2, 26)
	    num_pg = 2

	    chp_one = MangaChapters.new(title, number, status, scanlator, date,
					  num_pg, nil, manga_info_one, nil, nil, nil)

	    # Setup Pages for chp_one
	    page_titles = ["Page 0", "Page 1"]
	    reading_dir = MangaUtils::ReadingDirection::LEFT_TO_RIGHT

	    pages_one = MangaPages.new(page_titles, chp_one, manga_info_one,
					reading_dir)

	    # Setup the prev/next chapters here
	    chp_one.prev = chp_zero
	    chp_zero.next = chp_one

	    # Assign pages to chapters
	    chp_zero.pages = pages_zero
	    chp_one.pages = pages_one

	    # Assign Chapters to the volume
	    vol_zero.chapters = [chp_zero, chp_one]



	    # Volume 1
	    title = "Undead Ending of Road"
	    number = 1
	    cover_page_path = "DummyManga-Data/death/cover.jpg"

	    vol_one = MangaVolumes.new(title, number, manga_info_one, nil, nil,
					cover_page_path, nil)

	    # Setup Chapter chp_zero
	    title = "Undying End"
	    number = 2
	    status = MangaUtils::MangaChapterStatus::NORMINAL
	    scanlator = "Manga-Urban"
	    date = Time.utc(2008, 2, 26)
	    num_pg = 2

	    chp_zero = MangaChapters.new(title, number, status, scanlator, date,
					  num_pg, nil, manga_info_one, nil, nil, nil)

	    # Setup Pages for chp_zero
	    page_titles = ["Page 0", "Page 1"]
	    reading_dir = MangaUtils::ReadingDirection::LEFT_TO_RIGHT

	    pages_zero = MangaPages.new(page_titles, chp_zero, manga_info_one,
					reading_dir)

	    # Setup Chapter chp_one
	    title = "Dead End"
	    number = 3
	    status = MangaUtils::MangaChapterStatus::NORMINAL
	    scanlator = "Manga-Urban"
	    date = Time.utc(2009, 2, 26)
	    num_pg = 2

	    chp_one = MangaChapters.new(title, number, status, scanlator, date,
					  num_pg, nil, manga_info_one, nil, nil, nil)

	    # Setup Pages for chp_one
	    page_titles = ["Page 0", "Page 1"]
	    reading_dir = MangaUtils::ReadingDirection::LEFT_TO_RIGHT

	    pages_one = MangaPages.new(page_titles, chp_one, manga_info_one,
					reading_dir)


	    # Setup the prev/next chapters here
	    chp_one.prev = chp_zero
	    chp_zero.next = chp_one

	    # Assign pages to chapters
	    chp_zero.pages = pages_zero
	    chp_one.pages = pages_one

	    # Assign Chapters to the volume
	    vol_one.chapters = [chp_zero, chp_one]


	    # Setup the prev/next volumes here
	    vol_one.prev = vol_zero
	    vol_zero.next = vol_one

	    # Set manga_info_one's volumes list
	    manga_info_one.volumes = [vol_zero, vol_one]


	    ##############################
	    # Manga (2) Volume/Chapters/Pages
	    ##############################

	    # No Volumes, just Chapters/pages
	    title = "Sleepy One"
	    number = 0
	    status = MangaUtils::MangaChapterStatus::NORMINAL
	    scanlator = "Manga-Koekje"
	    date = Time.utc(2008, 3, 26)
	    num_pg = 4

	    chp_zero = MangaChapters.new(title, number, status, scanlator, date,
					  num_pg, nil, manga_info_two, nil, nil, nil)

	    # Setup Pages for chp_zero
	    page_titles = ["Page 0", "Page 1", "Page 2", "Page 3"]
	    reading_dir = MangaUtils::ReadingDirection::RIGHT_TO_LEFT

	    pages_zero = MangaPages.new(page_titles, chp_zero, manga_info_two,
					reading_dir)


	    title = "Diary of the Tree Leaking Day"
	    number = 1
	    status = MangaUtils::MangaChapterStatus::NEW
	    scanlator = "Manga-Koekje"
	    date = Time.utc(2008, 3, 26)
	    num_pg = 4

	    chp_one = MangaChapters.new(title, number, status, scanlator, date,
					  num_pg, nil, manga_info_two, nil, nil, nil)

	    # Setup Pages for chp_one
	    page_titles = ["Page 0", "Page 1", "Page 2", "Page 3"]
	    reading_dir = MangaUtils::ReadingDirection::RIGHT_TO_LEFT

	    pages_one = MangaPages.new(page_titles, chp_zero, manga_info_two,
					reading_dir)


	    # Setup the prev/next chapters here
	    chp_one.prev = chp_zero
	    chp_zero.next = chp_one


	    # Assign pages to chapters
	    chp_zero.pages = pages_zero
	    chp_one.pages = pages_one


	    # Set manga_info_two's chapters list
	    manga_info_two.chapters = [chp_zero, chp_one]


	    ##############################
	    # Manga (3) Volume/Chapters/Pages
	    ##############################

	    # No volumes, no chapter, just pages
	    page_titles = ["Page 0", "Page 1", "Page 2", "Page 3", "Page 4", "Page 5",
			    "Page 6", "Page 7"]
	    reading_dir = MangaUtils::ReadingDirection::RIGHT_TO_LEFT

	    pages = MangaPages.new(page_titles, nil, manga_info_three,
					reading_dir)

	    # Set manga_info_three's pages list
	    manga_info_three.pages = pages


	    ##############################
	    # Manga Setup
	    ##############################
	    @site_info.mangas = [manga_info_one, manga_info_two, manga_info_three]

	end


	# to_string for debugging
	def to_s
	    if (@site_info.is_a? Array)
		return (@site_info.each {|site| site.to_s})
	    else
		return @site_info.to_s
	    end
	end
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


	# Setter for manga list (Not offical)
	attr_writer :mangas


	# to_string for debugging
	def to_s
	    ret = "[MangaSite]\n"
	    ret += "Categories: #{@categories.join(', ')}\n\n"

	    if (@mangas.is_a? Array)
		@mangas.each do |manga|
		    ret += "[MangaInfo]\n#{manga.to_s}\n\n"
		end
	    else
		ret += "[MangaInfo]\n#{manga.to_s}\n\n"
	    end

	    return ret
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
	def initialize (title, alt_titles, categories, authors, artists,
			releases, state, status, total, latest_chapter, last_update,
			release_year, serialized, add_date, ranking, rating, views,
			summary, manga_site, volumes, chapters, pages, cover_pages)
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

	    @summary = summary

	    @manga_site = manga_site

	    @volumes = volumes
	    @chapters = chapters
	    @pages = pages

	    @cover_page_paths = cover_pages
	end

	# Setter for volumes list (not offical)
	attr_writer :volumes

	# Setter for chapters list (Not offical)
	attr_writer :chapters
	
	# Setter for pages list (Not offical)
	attr_writer :pages


	# to_string for debugging
	def to_s
	    ret  = "Title: #{@title}\n"

	    if (@alt_titles.is_a? Array)
		ret += "Alt Titles: #{@alt_titles.join(', ')}\n"
	    else
		ret += "Alt Titles: #{@alt_titles}\n"
	    end

	    if (@authors.is_a? Array)
		ret += "Authors: #{@authors.join(', ')}\n"
	    else
		ret += "Authors: #{@authors}\n"
	    end

	    if (@artists.is_a? Array)
		ret += "Artists: #{@artists.join(', ')}\n"
	    else
		ret += "Artists: #{@artists}\n"
	    end

	    ret += "Release Schedule: #{@release_schedule}\n"
	    ret += "State: #{@state}\n"
	    ret += "Status: #{@status}\n"

	    ret += "Total:\n\tVol: #{@total[0]}\n\tChp: #{@total[1]}\n\tPage: #{@total[2]}\n"

	    ret += "Latest Chapter: #{@latest_chapter}\n"
	    ret += "Last Update: #{@last_update}\n"
	    ret += "Release Year: #{@release_year}\n"
	    ret += "Serialized in: #{@serialized_in}\n"
	    ret += "When Added: #{@when_added}\n"
	    ret += "Site Ranking: #{@site_ranking}\n"

	    if (@rating.nil?)
		ret += "Rating:\n\tRating:\n\tVotes:\n"
	    else
		ret += "Rating:\n\tRating: (#{@rating[0]}/#{@rating[1]})\n\tVotes: #{@rating[2]}\n"
	    end

	    if (@views.nil?)
		ret += "Views:\n\tNumber:\n\tType:\n"
	    else
		ret += "Views:\n\tNumber: #{@views[0]}\n\tType: #{@views[1]}\n"
	    end

	    ret += "Summary:\n****\n#{@summary}\n****\n\n"

	    if (@volumes.is_a? Array)
		@volumes.each do |vol|
		    ret += "[MangaVolumes]\n#{vol.to_s}"
		end
	    else
		if (@volumes.nil?)
		    ret += "[MangaVolumes]\n-Not Used-\n\n"
		else
		    ret += "[MangaVolumes]\n#{@volumes.to_s}\n"
		end
	    end


	    if (@chapters.is_a? Array)
		@chapters.each do |chp|
		    ret += "[MangaChapters]\n#{chp.to_s}\n"
		end
	    else
		if (@chapters.nil?)
		    ret += "[MangaChapters]\n-Not Used-\n\n"
		else
		    ret += "[MangaChapters]\n#{@chapters.to_s}\n"
		end
	    end


	    if (@pages.is_a? Array)
		@pages.each do |pg|
		    ret += "[MangaPages]\n#{pg.to_s}\n"
		end
	    else
		if (@pages.nil?)
		    ret += "[MangaPages]\n-Not Used-\n\n"
		else
		    ret += "[MangaPages]\n#{@pages.to_s}\n"
		end
	    end


	    return ret
	end
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


	# First/Last page picture
	attr_reader :first, :last

	# Next/Previous page picture
	attr_reader :next, :prev


	# Check if next/prev page exist
	def next?
	end

	def prev?
	end


	# Go to the page index specifyed, if the page indicated by the index
	# does not exist it will throw an exception.  Anyway the index is
	# counted from 0 to the last page in the set.
	def goto (index)
	end


	# Returns the "index" of the current page that this "object/iterator" is
	# on
	def index
	end


	# Reading direction of the page itself, IE (MangaUtils::ReadingDirection)
	# this is for right to left, or left to right reading direction, etc..
	def reading_direction
	    return @reading_direction
	end


	# The class constructor
	def initialize (page_titles, chapter, manga_info, reading_direction)
	    @page_titles = page_titles

	    @chapter = chapter
	    @manga_info = manga_info

	    @reading_direction = reading_direction
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




    #######################################################################
    # Old MangaPages, mainly for refferences now
    #######################################################################
    class MangaPages_old

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
