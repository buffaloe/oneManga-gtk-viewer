#
# Implements the API defined in the manga-*.txt notes in the notes directory
# for the Dummy Testing API
#
module DummyManga

    require 'gtk2'

    class MangaSite
    end

    class MangaInfo
    end

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
		puts "todo"
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
		puts "todo"
	    else
		puts "not implemented"
	    end
	end

	def next_page?
	    if !@vol_exist & !@chp_exist
		return (@pg >= 7) ? false : true
	    elsif !@vol_exist & @chp_exist
		puts "todo"
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
		puts "todo"
	    else
		puts "not implemented"
	    end
	end

	def prev_page?
	    if !@vol_exist & !@chp_exist
		return (@pg < 1) ? false : true
	    elsif !@vol_exist & @chp_exist
		puts "todo"
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
		puts "todo"
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
		puts "todo"
	    else
		puts "not implemented"
		return nil
	    end
	end

	def next_chapter?
	    if !@vol_exist & @chp_exist
		puts "todo"
	    else
		puts "not implemented"
		return nil
	    end
	end

	
	# Same thing as the "next_chapter" class of function
	def prev_chapter
	    if !@vol_exist & @chp_exist
		puts "todo"
	    else
		puts "not implemented"
		return nil
	    end
	end

	def prev_chapter?
	    if !@vol_exist & @chp_exist
		puts "todo"
	    else
		puts "not implemented"
		return nil
	    end
	end

	
	# Same thing as the "goto_page" function, however with respect
	# to chapters, the results is the same, but applied to chapters
	def goto_chapter (index)
	    if !@vol_exist & @chp_exist
		puts "todo"
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
	    puts "not implemented"
	    return nil
	end

	def next_volume?
	    puts "not implemented"
	    return nil
	end


	def prev_volume
	    puts "not implemented"
	    return nil
	end

	def prev_volume?
	    puts "not implemented"
	    return nil
	end

	
	def goto_volume (index)
	    puts "not implemented"
	    return nil
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
	    puts "not implemented"
	    return nil
	end

	def currentChapterIndex
	    puts "not implemented"
	    return nil
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
	    puts "not implemented"
	    return nil
	end
	
	def list_chapters
	    puts "not implemented"
	    return nil
	end
	
	def list_pages
	    return ["Pg 0", "Pg 1", "Pg 2", "Pg 3", "Pg 4", "Pg 5", "Pg 6", "Pg 7"]
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
