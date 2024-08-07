# frozen_string_literal: true

require 'nokogiri'
require 'json'
require_relative '../common'

GROUP_NAME = 'ZETA DIVISION'
GROUP_SLUG = 'zeta'

UPDATE_LIST = ARGV[0] == 'update_list'

def get_streamer_list
  url = 'https://zetadivision.com/members'
  html = retrieve_and_cache(url, extension: '.html', cache: !UPDATE_LIST)
  doc = Nokogiri::HTML.parse(html)
  doc.css('a.memberCard').map { |a| a['href'] }
end

def get_streamer_detail(url)
  html = retrieve_and_cache(url)
  doc = Nokogiri::HTML.parse(html)

  name = doc.at_css('.profile__name').text.strip
  urls = doc.css('a.profile__snsLink').map { |a| a[:href] }

  attribute = doc.at_css('.profile__attribute').text.strip
  belong = doc.css('.teamNav__link--belong').map { |a| a.text.strip }

  { name: name, links: create_link_map(urls), tags: [GROUP_NAME, attribute, *belong].uniq, page: url }
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
