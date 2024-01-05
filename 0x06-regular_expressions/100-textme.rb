#!/usr/bin/env ruby
matches = ARGV[0].scan(/(?<=\bfrom:|\bto:|\bflags:)(?:[^]\s]+)/).map(&:chomp)
puts matches.join(",")