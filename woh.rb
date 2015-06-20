#!/usr/bin/env ruby

# Purpose: Compile everything to static status page
# Author : Anh K. Huynh
# Date   : 2015 Jun 19th
# License: MIT

require 'yaml'
require 'time'

# time > time > time > time > ...
def look_up_least_date(timestamp)
  cloned = ($events2.keys | [timestamp]).sort.reverse
  pos = cloned.index(timestamp)
  if (pos and (pos < cloned.size))
    return cloned[pos + 1]
  else
    return nil
  end
end

def get_status(timestamp)
  return nil if timestamp.nil?
  event = ($events2[timestamp] || {})
  if not event.empty?
    status = (event["status"] || "up")
    message = (event["message"] || "(empty message)")
    event = {"status" => status, "message" => message}
    return event
  end

  last_recored_date = look_up_least_date(timestamp)
  if last_recored_date
    event = Hash.new
    event["message"] = $events2[last_recored_date]["message"]
    event["status"] = $events2[last_recored_date]["status"]

    event["message"] = "#{event["message"]} (cf. #{Time.at(last_recored_date)})"
  else
    event = {"status" => "bug", "message" => "Unknown status"}
  end

  return event
end

########################################################################
# Main program
########################################################################

data = YAML.load_documents(STDIN.read)

$settings = {}
events = {}
$events2 = {}

data.each do |input|
  $settings.merge!(input["settings"] || {})
  events.merge!(input["events"] || {})
end

events.each do |datestring,details|
  begin
    timestamp = Time.parse(datestring).to_i
  rescue => e
    STDERR.puts ":: #{e}"
    next
  end

  if details.is_a?(String)
    details = {"status" => "up", "message" => details}
  end

  $events2[timestamp] ||= {}
  $events2[timestamp].merge!(details)
end

########################################################################
# Option 1: Print a row of statuses of a service
########################################################################

if ARGV.index("--option1")
  start_of_today = Time.now
  start_of_today = start_of_today - (start_of_today.hour * 3600 + start_of_today.min * 60 + start_of_today.sec)
  end_of_today = start_of_today + 24 * 3600

  link = "#"
  if service = ENV["SERVICE"]
    link = "#{service.downcase}.html"
  end

  display_name = ($settings["name"] || ENV["SERVICE"] || "Unknown")

  external = ""
  if $settings["url"]
    external = " <a href='#{$settings["url"]}'><img class='icon' src='./images/external.png' /></a>"
  end

  puts "  <td class=\"service\"><a href=\"#{link}\">#{display_name}</a>#{external}</td>"
  # Return the last known even (a week ago)
  %w{0 1 2 3 4 5 6}.map(&:to_i).each do |offset|
    timestamp = end_of_today.to_i - offset * 24 * 3600 - 1
    event = get_status(timestamp)
    puts "  <td class='status'><img class='icon' src='./images/#{event["status"]}.png' /></td>"
  end
  exit(0)
end

########################################################################
# Option 2: Print all statuses of a service
########################################################################

if ARGV.index("--option2")
  puts "<table>"
  count = 0
  $events2.keys.sort.reverse.each do |timestamp|
    next if timestamp > Time.now.to_i
    count += 1
    event = get_status(timestamp)
    puts "<tr>"
    puts "  <td class='timestamp'>#{Time.at(timestamp).strftime("%Y-%b-%d %H:%M:%S")}</td>"
    puts "  <td class='status'><img class='icon' src='./images/#{event["status"]}.png' /></td>"
    puts "  <td class='message'>#{event['message']}</td>"
    puts "</tr>"
  end
  if count == 0
    puts "<tr>"
    puts "  <td class='message'><strong>No event found</strong></td>"
    puts "</tr>"
  end
  puts "</table>"
  exit(0)
end

########################################################################
# Option 2: Print the last status of a service
########################################################################
if ARGV.index("--option3")
  event = get_status(look_up_least_date(Time.now.to_i))
  puts "#{event['status']}\t#{event['message']}"
  exit(0)
end

STDERR.puts ":: Syntax: $0 [--option1] [--option2]"
exit(1)
