#!/usr/bin/env ruby

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
