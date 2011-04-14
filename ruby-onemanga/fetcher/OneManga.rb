# Deals with populating the db with oneManga data
module Fetcher
    require 'SequelManga'

    # Cache
    require 'fetcher/http_fetch'

    # Html parser
    require 'nokogiri'

    class OneManga
	def initialize
	    @site = SequelManga::Site.new
	    @site.site_name = "One Manga"
	    @site.save

	    @url = "http://www.onemanga.com"
	    @directory_url = "#{@url}/directory/"

	    @fetch = HTTP_fetch.new
	end

	# Hash operation for storing a string into a "key"
	def populate
	    dir = Nokogiri::HTML(@fetch.fetch(@directory_url))
	    exclude = ['All', 'Top 50', 'New', 'Updated', 'Completed']

	    # Manga Category
	    dir.xpath('/html/body/div[2]/div[3]/div[2]/div[3]/div[2]/ul/li/a').each do |cat|
		if (exclude.index(cat.content)).nil?
		    # Not in exclude list
		    category = SequelManga::Category.new
		    category.category = cat.content

		    @site.add_category(category)
		end
	    end

	    exclude2 = ['/directory/', '/directory/pop/']
	    # Manga Info
	    manga_url = []
	    dir.xpath('/html/body/div[2]/div[3]/div/table/tr/td/a').each do |manga|
		url = manga.values
		next if (url.length > 1)
		
		url = url.to_s
		if (exclude2.index(url)).nil?
		    manga_url << url
		end
	    end
	    manga_url.uniq!
	    #puts manga_url.length
	   
	    # Process each site
	    manga_url.each do |url|
		puts url
		data = Nokogiri::HTML(@fetch.fetch(@url + url))

		manga_info = SequelManga::Info.new
		manga_info.save

		# This part needs work for the alt titles
		titledata = data.xpath('/html/body/div[2]/div[3]/div/h1').first.content.strip
		title = SequelManga::Title.new
		title.title = titledata
		manga_info.title = title

		data.xpath('/html/body/div[2]/div[3]/div/div/div/table/tr').each do |chunk|
		    type = chunk.xpath('th').first.content.strip
		    value = chunk.xpath('td').first.content.strip

		    case type
		    when 'OM Rank:'
			manga_info.site_ranking = value.strip.to_i
		    when 'Categories:'
			value.split(',').each do |cat|
			    category = SequelManga::Category[:category => cat.strip]
			    if category.nil?
				category = SequelManga::Category.new
				category.category = cat.strip
			    end
			    manga_info.add_category(category)
			end
		    when 'Author:'
			value.split(',').each do |auth|
			    author = SequelManga::Author[:name => auth.strip]
			    if author.nil?
				author = SequelManga::Author.new
				author.name = auth.strip
			    end
			    manga_info.add_author(author)
			end
		    when 'Artist:'
			value.split(',').each do |art|
			    artist = SequelManga::Artist[:name => art.strip]
			    if artist.nil?
				artist = SequelManga::Artist.new
				artist.name = art.strip
			    end
			    manga_info.add_artist(artist)
			end
		    when 'Start Date:'
			manga_info.release_year = Time.utc(value.strip.to_i)
		    when 'Chapters:'
			if (value.strip) =~ /\d* - (\w*) - (\w*)/
			    manga_info.state = $1.to_sym
			    manga_info.schedule = $2.to_sym
			elsif (value.strip) =~ /\d* - (\w*)/
			    manga_info.state = $1.to_sym
			end
		    end
		end

		manga_info.save
		@site.add_info(manga_info)

# Uncomment this if using network transfers
#		sleep 1
	    end
	    @site.save
	end

	def getSite
	    return @site
	end
    end
end
