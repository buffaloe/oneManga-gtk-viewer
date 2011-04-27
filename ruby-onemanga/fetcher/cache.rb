# Cache stuff, it currently just cache stuff in the ./cache directory
#
require 'digest/md5'
require 'fileutils'

class Cache
    def initialize
	@cache_dir = './cache'

	# Make sure the cache directory exists
	if File.exist?(@cache_dir)
	    if File.directory?(@cache_dir)
		puts "We are good to go"
	    else
		puts "Its a file, exit"
		exit 1
	    end
	else
	    FileUtils.mkdir(@cache_dir)
	end
    end

    # Hash operation for storing a string into a "key"
    def [](key)
	hash = hash(key)

	value = nil
	if File.exist?(File.join(@cache_dir, hash))
	    value = ''
	    File.open(File.join(@cache_dir, hash), 'rb') { |f|
		value += f.read
	    }
	end

	return value
    end

    def []=(key, value)
	hash = hash(key)

	File.open(File.join(@cache_dir, hash), 'wb') { |f|
	    f.write(value)
	}
    end

    def has_key?(key)
	hash = hash(key)

	return File.exist?(File.join(@cache_dir, hash))
    end

    private
    def hash(string)
	return Digest::MD5.hexdigest(string)
    end
end
