# frozen_string_literal: true

require 'nokogiri'
require 'json'
require_relative '../common'

GROUP_NAME = '個人'
GROUP_SLUG = 'independent'

UPDATE_LIST = ARGV[0] == 'update_list'

def main
  puts " * [#{Time.now}] [#{GROUP_NAME}] Starting to retrieve data..."
  url = 'https://5th.uishigure.com/'
  html = retrieve_and_cache(url, extension: '.html', cache: !UPDATE_LIST)
  doc = Nokogiri::HTML.parse(html)

  urls = doc.css('.nav-snslinks a').map { |a| a['href'] }

  name = 'しぐれうい'
  result = [{ name: name, links: create_link_map(urls), tags: [GROUP_NAME], page: url }]

  file_path = File.join(RESULT_DIR, "#{GROUP_SLUG}.json")
  File.open(file_path, 'w') do |file|
    file.write(JSON.pretty_generate(result))
  end

  puts " * [#{Time.now}] [#{GROUP_NAME}] Data retrieval completed!"
end

main
