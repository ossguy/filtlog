#!/usr/bin/env ruby
#
# user_agent.rb - lists user agents by number of accesses in web server log file
# This file is part of filtlog.
#
# Copyright (c) 2009, Denver Gingerich <denver@ossguy.com>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.


views = Hash.new(0)

ignore_prefixes = [
	'/?feed=',
	'/wp-',
	'/favicon.ico',
	'/avatar',
	'/robots.txt',
	'/css'
]

ARGV.each do|arg|
	File.foreach(arg) do|line|
		catch :OUTER do
			page = line.split(' ')[6]
			ignore_prefixes.each {|prefix|
				throw :OUTER if page.start_with? prefix
			}
			user_agent = line.split('"')[5]
			views[user_agent] += 1
		end
	end
end

views.sort{|a,b| b[1] <=> a[1]}.each{|a,b|
	puts "%-8s%s" % [b, a]
}
