# frozen_string_literal: true

require 'nokogiri'
require 'json'
require_relative '../common'

GROUP_NAME = 'ネオポルテ'
GROUP_SLUG = 'neo-porte'

MEMBER_LIST_URL = 'https://neo-porte.jp/talent/'

UPDATE_LIST = ARGV[0] == 'update_list'

def get_streamer_list(url)
  html = retrieve_and_cache(url, extension: '.html', cache: !UPDATE_LIST)
  doc = Nokogiri::HTML.parse(html)

  doc.css('.artist_box').map do |group|
    cat = group
    cat = cat.previous until cat&.name == 'h5'
    category_name = cat.text.strip

    group.css('a').map do |a|
      url = a['href']
      { category_name: category_name, url: url }
    end
  end.flatten
end

def get_streamer_detail(url, category_name)
  html = retrieve_and_cache(url)
  doc = Nokogiri::HTML.parse(html)

  name = doc.at_css('h3').text.strip.split('/')[0]
  urls = doc.css('.sns_list a').map { |a| a[:href] }

  { name: name, links: create_link_map(urls), tags: [GROUP_NAME, category_name].uniq, page: url }
end

def main
  puts " * [#{Time.now}] [#{GROUP_NAME}] Starting to retrieve data..."

  streamer_list = get_streamer_list(MEMBER_LIST_URL)
  puts " * [#{Time.now}] [#{GROUP_NAME}] Parsing Streamer list completed."

  len = streamer_list.length
  result = streamer_list.map.with_index(1) do |member, i|
    url = member[:url]
    category_name = member[:category_name]
    puts format("   * [#{Time.now}] [#{GROUP_NAME}] %03d/%03d (%.2f%%) parsing: %s", i, len, i.to_f / len, url)
    get_streamer_detail(url, category_name)
  end

  file_path = File.join(RESULT_DIR, "#{GROUP_SLUG}.json")
  File.open(file_path, 'w') do |file|
    file.write(JSON.pretty_generate(result))
  end

  puts " * [#{Time.now}] [#{GROUP_NAME}] Data retrieval completed!"
end

main
