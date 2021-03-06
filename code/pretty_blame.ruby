#!/usr/bin/env ruby

def pretty_blame(format, hash, commit, line)
  desc = format.
    gsub(/%H/, hash).
    gsub(/%h/, hash[0,8]).
    gsub(/%an/, commit[:author]).
    gsub(/%ae/, commit[:author_mail]).
    gsub(/%ad/, commit[:author_time].strftime("%d. %b %Y")).
    gsub(/%Cred/, "\033[31m").
    gsub(/%Cgreen/, "\033[32m").
    gsub(/%Cblue/, "\033[34m").
    gsub(/%Creset/, "\033[0m")
  puts desc + "\t" + line
end

path = ARGV[0]
format = "%Cred%h%Cblue (%ad) %Cgreen%an%Creset"

hash = ""
commits = {}
`git blame -p #{path}`.split("\n").each do |line|
  if line =~ /^([0-9a-f]{39,40})\s.*/
    hash = $1
    commits[hash] = {} unless commits[hash]
  elsif line =~ /^author (.+)/
    commits[hash][:author] = $1.strip
  elsif line =~ /^author-mail (.+)/
    commits[hash][:author_mail] = $1.strip
  elsif line =~ /^author-time (.+)/
    commits[hash][:author_time] = Time.at($1.strip.to_i)
  elsif line =~ /^author-tz (.+)/
    commits[hash][:author_tz] = $1.strip
  elsif line =~ /^committer (.+)/
    commits[hash][:committer] = $1.strip
  elsif line =~ /^committer-mail (.+)/
    commits[hash][:committer_mail] = $1.strip
  elsif line =~ /^committer-time (.+)/
    commits[hash][:committer_time] = Time.at($1.strip.to_i)
  elsif line =~ /^committer-tz (.+)/
    commits[hash][:committer_tz] = $1.strip
  elsif line =~ /^summary (.+)/
    commits[hash][:summary] = $1.strip
  elsif line =~ /^previous (.+)/
    commits[hash][:previous] = $1.strip
  elsif line =~ /^filename (.+)/
    commits[hash][:filename] = $1.strip
  elsif line =~ /^\t(.*)/
    pretty_print(format, hash, commits[hash], $1)
  end
end