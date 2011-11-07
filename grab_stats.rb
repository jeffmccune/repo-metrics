#!/usr/bin/env ruby

# What does it do?
#
#   This script will loop over the repositories defined in the
#   REPOSITORIES_TO_CHECK constant, and grab the timestamp of the
#   oldest (by creation date) open pull request, as well as the count
#   of open pull requests.
#
#   REPOSITORIES_TO_CHECK is an array of arrays, where the inner array
#   is the GitHub user/organization name, followed by the repository
#   name.  For example:
#
#       REPOSITORIES_TO_CHECK = [
#         ['puppetlabs', 'puppet'],
#         ['puppetlabs', 'facter'],
#         ['puppetlabs', 'puppet-dashboard']
#       ]
#
# What does its output look like?
#
#   At the time of writing this:
#
#       % ruby ./grab_stats.rb
#       Retrieving repo data for puppetlabs/puppet
#       Found 63 open pull requests: ...............................................................
#       Retrieving repo data for puppetlabs/facter
#       Found 6 open pull requests: ......
#       Retrieving repo data for puppetlabs/puppet-dashboard
#       Found 4 open pull requests: ....
#
#       puppetlabs/facter:
#         oldest open:   Thu Oct 06 15:02:39 UTC 2011
#         open requests: 6
#
#       puppetlabs/puppet:
#         oldest open:   Thu Jun 23 17:28:29 UTC 2011
#         open requests: 63
#
#       puppetlabs/puppet-dashboard:
#         oldest open:   Mon Oct 31 22:53:03 UTC 2011
#         open requests: 4

require 'rubygems'
require 'octocat_herder'
require 'octocat_herder/pull_request'

REPOSITORIES_TO_CHECK = [
  ['puppetlabs', 'puppet'],
  ['puppetlabs', 'facter'],
  ['puppetlabs', 'puppet-dashboard']
]

metrics = {}
REPOSITORIES_TO_CHECK.each do |repo_data|
  oldest_created_date = Time.now
  repo_key = repo_data.join('/')
  puts "Retrieving repo data for #{repo_key}"

  pull_requests = OctocatHerder::PullRequest.find_open_for_repository(*repo_data)
  print "Found #{pull_requests.length} open pull requests: "
  pull_requests.each do |pull_req|
    print "."
    pull_req.get_detail
    oldest_created_date = pull_req.created_at if pull_req.created_at < oldest_created_date
  end

  metrics[repo_key] = {
    :oldest_open   => oldest_created_date,
    :open_requests => pull_requests.length
  }

  puts ""
end

metrics.keys.sort.each do |repo|
  puts "\n#{repo}:"
  max_length = metrics[repo].keys.inject(0) {|x,k| x = "#{k}".length if "#{k}".length > x}

  metrics[repo].keys.map(&:to_s).sort.each do |metric|
    metric_name = metric.gsub('_', ' ')
    puts sprintf("  %-#{max_length + 1}s %s", "#{metric_name}:", metrics[repo][metric.to_sym])
  end
end
