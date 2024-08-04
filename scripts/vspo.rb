# frozen_string_literal: true

require 'nokogiri'
require 'json'
require_relative 'common'

def main
  puts " * [#{Time.now}] start retrieving vspo data..."
  url = 'https://vspo.jp/member/'
  html = retrieve_and_cache(url)
  doc = Nokogiri::HTML.parse(html)

  liver_list = doc.css('.member__profile')

  result = liver_list.map.with_index do |liver, i|
    name = liver.at_css('.member__name img')['alt']
    puts format("   * [#{Time.now}] %03d/%03d (%.2f%%) parsing: #{name}",
                i,
                liver_list.length,
                i.to_f / liver_list.length)

    links = liver.css('.member__sns__item a').map do |item|
      url = item['href']
      uri = URI.parse(url)
      host = uri.hostname
      key = host.split('.')[-2]
      [key, url]
    end.to_h

    { name: name, links: links }
  end

  file_path = File.join(RESULT_DIR, 'vspo.json')
  File.open(file_path, 'w') do |file|
    file.write(JSON.pretty_generate(result))
  end

  puts " * [#{Time.now}] retrieving vspo data completed!"
end

main
