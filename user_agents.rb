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


if ARGV.empty?
	warn ""
	warn "filtlog user agent summarizer"
	warn "Copyright 2009 Denver Gingerich"
	warn ""
	warn "This program is free software; you may redistribute it under the"
	warn "terms of the ISC licence as shown at the top of user_agents.rb."
	warn ""
	warn "Usage: #{$0} <log_files(s)>"
	warn ""
	warn "This program creates a list of all user agents who accessed a web"
	warn "site given the web server logs.  The list shows how many accesses"
	warn "each user agent made, going from highest to lowest.  This is"
	warn "useful for finding bots which can be added to the bot exclusion"
	warn "list (bot_ids) in filtlog.conf.  Log files are assumed to be in"
	warn "Apache Combined Log Format."
	warn ""

	exit 1
end

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
