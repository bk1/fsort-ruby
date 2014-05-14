#!/usr/bin/ruby

require_relative 'fsort.rb'

a = (0..1000).to_a.shuffle

b = a.fsort

puts "b=#{b.inspect}"

c = a.sort

puts "ok? #{b==c}"
