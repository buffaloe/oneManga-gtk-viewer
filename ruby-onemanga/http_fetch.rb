# Fetches a http page and deals with caching it
#
require 'cache.rb'
require 'net/http'
require 'uri'

class HTTP_fetch
    def initialize
	@cache = Cache.new
    end

    def fetch(url_str, limit = 10)
	raise ArgumentError, 'HTTP redirect too deep' if limit == 0

	# Check the URL
	url = URI.parse(url_str)
	n_url = url.normalize.to_s

	# Deal with cache
	if @cache.has_key?(n_url)
	    return @cache[n_url]
	end

	response = Net::HTTP.get_response(url)
	case response
	when Net::HTTPSuccess
	    @cache[n_url] = response.body
	    return response.body
	when Net::HTTPRedirection
	    fetch(response['location'], limit - 1)
	else
	    response.error!
	end
    end
end
