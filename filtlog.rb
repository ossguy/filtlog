#!/usr/bin/env ruby
#
# filtlog.rb - filters web server log files; shows total page views and referers
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
	warn "Usage: #{$0} <log_files(s)>"
	warn ""
	warn "Log files must be in Apache Combined Log Format."
	warn ""

	exit 1
end

views = Hash.new(0)
referers = Hash.new(0)

num_pages = 0
num_referers = 0
ignore_prefixes = []
bot_ids = []
page_names = {}

conf_file = 'filtlog.conf'
if File.readable? conf_file
	eval File.read(conf_file)
end

ARGV.each do|arg|
	File.foreach(arg) do|line|
		catch :OUTER do
			page = line.split(' ')[6]
			ignore_prefixes.each {|prefix|
				throw :OUTER if page.start_with? prefix
			}
			user_agent = line.split('"')[5]
			bot_ids.each {|id|
				throw :OUTER if user_agent.include? id
			}
			referer = line.split('"')[3]
			views[page] += 1
			if 0 == referers[page]
				referers[page] = Hash.new(0)
			end
			referers[page][referer] += 1
		end
	end
end

sorted_views = views.sort{|a,b| b[1] <=> a[1]}
if num_pages > 0
	sorted_views = sorted_views[0, num_pages]
end

sorted_views.each{|a,b|
	puts "%-8s%s %s" % [b, a, page_names[a]]

	sorted_referers = referers[a].sort{|a,b| b[1] <=> a[1]}
	if num_referers > 0
		sorted_referers = sorted_referers[0, num_referers]
	end

	sorted_referers.each{|a,b|
		puts "    %-8s%s" % [b, a]
	}
}
