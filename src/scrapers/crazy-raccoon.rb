# frozen_string_literal: true

require 'nokogiri'
require 'json'
require_relative '../common'

GROUP_NAME = 'Crazy Raccoon'
GROUP_SLUG = 'crazy-raccoon'

MEMBER_LIST_URL = 'https://crazyraccoon.jp/member/'

UPDATE_LIST = ARGV[0] == 'update_list'

def get_streamer_list(url)
  html = retrieve_and_cache(url, extension: '.html', cache: !UPDATE_LIST)
  doc = Nokogiri::HTML.parse(html)
  doc.css('.member_item a').map { |a| a['href'] }
end

def get_streamer_detail(url)
  html = retrieve_and_cache(url)
  doc = Nokogiri::HTML.parse(html)

  name = doc.at_css('.name .main').text.strip
  urls = doc.css('.sns a').map { |a| a[:href] }.reject(&:empty?) # なんかURLが空のがある

  group = doc.at_css('.team').text

  { name: name, links: create_link_map(urls), tags: [GROUP_NAME, group].uniq, page: url }
end

def main
  puts " * [#{Time.now}] [#{GROUP_NAME}] Starting to retrieve data..."

  streamer_list = get_streamer_list(MEMBER_LIST_URL)
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
