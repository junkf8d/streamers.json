# frozen_string_literal: true

require 'nokogiri'
require 'json'
require_relative '../common'

GROUP_NAME = 'ホロライブ'
GROUP_SLUG = 'hololive'

UPDATE_LIST = ARGV[0] == 'update_list'

def get_streamer_list
  url = 'https://hololive.hololivepro.com/talents/'
  html = retrieve_and_cache(url, extension: '.html', cache: !UPDATE_LIST)
  doc = Nokogiri::HTML.parse(html)
  doc.css('.talent_list > li').map { |li| li.at_css('a')['href'] }
end

def get_streamer_detail(url)
  html = retrieve_and_cache(url)
  doc = Nokogiri::HTML.parse(html)

  card = doc.at_css('.bg_box')
  name = card.at_css('h1').children.first.text.strip
  allLinks = card.css('.t_sns a').map do |link|
    [link.text.strip.sub(/Tik Tok/, 'TikTok'), link['href']]
  end.to_h
  links = create_link_map(allLinks.slice(*%w[YouTube X Twitter Twitch TikTok Instagram]).values)

  unit = doc.at_xpath('//dt[contains(text(), "ユニット")]/following-sibling::dd').text

  { name: name, allLinks: allLinks, links: links, tags: [GROUP_NAME, unit].uniq, page: url }
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

puts main
