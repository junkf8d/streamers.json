# frozen_string_literal: true

require 'nokogiri'
require 'json'
require_relative '../common'

GROUP_NAME = 'ぶいすぽ'
GROUP_SLUG = 'vspo'

def main
  puts " * [#{Time.now}] start retrieving #{GROUP_NAME} data..."
  url = 'https://vspo.jp/member/'
  html = retrieve_and_cache(url)
  doc = Nokogiri::HTML.parse(html)

  streamer_list = doc.css('.member__profile')

  len = streamer_list.length
  result = streamer_list.map.with_index do |streamer, i|
    name = streamer.at_css('.member__name img')['alt']
    puts format("   * [#{Time.now}] %03d/%03d (%.2f%%) parsing: %s", i, len, i.to_f / len, name)

    urls = streamer.css('.member__sns__item a').map { |a| a['href'] }
    { name: name, links: create_link_map(urls), tags: [GROUP_NAME], page: url }
  end

  file_path = File.join(RESULT_DIR, "#{GROUP_SLUG}.json")
  File.open(file_path, 'w') do |file|
    file.write(JSON.pretty_generate(result))
  end

  puts " * [#{Time.now}] retrieving #{GROUP_NAME} data completed!"
end

main
