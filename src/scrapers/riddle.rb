# frozen_string_literal: true

require 'nokogiri'
require 'json'
require_relative '../common'

GROUP_NAME = 'RIDDLE'
GROUP_SLUG = 'riddle'

UPDATE_LIST = ARGV[0] == 'update_list'

def get_streamer_list
  url = 'https://riddle.info/members/'
  html = retrieve_and_cache(url, extension: '.html', cache: !UPDATE_LIST)
  doc = Nokogiri::HTML.parse(html)
  doc.css('.p-members__list a').map { |a| a['href'] }
end

def get_streamer_detail(url)
  html = retrieve_and_cache(url)
  doc = Nokogiri::HTML.parse(html)

  name = doc.at_css('h1').text.strip
  urls = doc.css('.p-members__profile-sns a').map { |a| a[:href] }

  group = doc.at_xpath('//a[contains(@href, "group_category")]').text

  { name: name, links: create_link_map(urls), tags: [GROUP_NAME, group].uniq, page: url }
end

def main
  puts " * [#{Time.now}] [#{GROUP_NAME}] Starting to retrieve data..."

  streamer_list = get_streamer_list
  puts " * [#{Time.now}] [#{GROUP_NAME}] Parsing Streamer list completed."

  len = streamer_list.length
  result = streamer_list.map.with_index(1) do |url, i|
    puts format("   * [#{Time.now}] [#{GROUP_NAME}] %03d/%03d (%.2f%%) parsing: %s", i, len, i.to_f / len, url)
    get_streamer_detail(url)
  end

  file_path = File.join(RESULT_DIR, "#{GROUP_SLUG}.json")
  File.open(file_path, 'w') do |file|
    file.write(JSON.pretty_generate(result))
  end

  puts " * [#{Time.now}] [#{GROUP_NAME}] Data retrieval completed!"
end

main
