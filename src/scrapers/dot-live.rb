# frozen_string_literal: true

require 'nokogiri'
require 'json'
require_relative '../common'

GROUP_NAME = '.LIVE'
GROUP_SLUG = 'dot-live'

MEMBER_LIST_URL = 'https://appland.co.jp/talents/'

UPDATE_LIST = ARGV[0] == 'update_list'

def main
  puts " * [#{Time.now}] [#{GROUP_NAME}] Starting to retrieve data..."
  url = MEMBER_LIST_URL
  html = retrieve_and_cache(url, extension: '.html', cache: !UPDATE_LIST)
  doc = Nokogiri::HTML.parse(html)

  streamer_list = doc.css('.post_content .swell-block-column')
  puts " * [#{Time.now}] [#{GROUP_NAME}] Parsing Streamer list completed."

  len = streamer_list.length
  result = streamer_list.map.with_index do |streamer, i|
    name = streamer.at_css('p').text.strip
    puts format("   * [#{Time.now}] [#{GROUP_NAME}] %03d/%03d (%.2f%%) parsing: %s", i, len, i.to_f / len, name)

    urls = streamer.css('.wp-block-group a').map { |a| a['href'] }
    { name: name, links: create_link_map(urls), tags: [GROUP_NAME], page: url }
  end

  file_path = File.join(RESULT_DIR, "#{GROUP_SLUG}.json")
  File.open(file_path, 'w') do |file|
    file.write(JSON.pretty_generate(result))
  end

  puts " * [#{Time.now}] [#{GROUP_NAME}] Data retrieval completed!"
end

main
