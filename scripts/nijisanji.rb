# frozen_string_literal: true

require 'nokogiri'
require 'json'
require_relative 'common'

GROUP_NAME = 'にじさんじ'
GROUP_SLUG = 'nijisanji'

def fetch_build_id
  url = 'https://www.nijisanji.jp/talents'
  html = retrieve_and_cache(url)
  doc = Nokogiri::HTML.parse(html)

  script_tag = doc.at_xpath('//script[contains(@src, "/_next/static/") and contains(@src, "_buildManifest.js")]')
  script_tag['src'].match(%r{/_next/static/([^/]+)/_buildManifest\.js})[1]
end

def get_liver_list(build_id)
  url = "https://www.nijisanji.jp/_next/data/#{build_id}/ja/talents.json"
  json = retrieve_and_cache(url)
  hash = JSON[json]
  hash['pageProps']['allLivers']
end

def get_liver_detail(build_id, liver_id)
  url = "https://www.nijisanji.jp/_next/data/#{build_id}/ja/talents/l/#{liver_id}.json"
  json = retrieve_and_cache(url)
  hash = JSON[json]
  detail = hash['pageProps']['liverDetail']

  name = detail['name']
  links = detail['socialLinks'].except('fieldId')

  { name: name, links: links, tags: [GROUP_NAME] }
end

def main
  puts " * [#{Time.now}] start retrieving #{GROUP_NAME} data..."

  build_id = fetch_build_id
  liver_list = get_liver_list(build_id)
  puts " * [#{Time.now}] parse liver list completed."

  len = liver_list.length
  result = liver_list.map.with_index(1) do |liver, i|
    id = liver['slug']
    puts format("   * [#{Time.now}] %03d/%03d (%.2f%%) parsing: %s", i, len, i.to_f / len, id)
    get_liver_detail(build_id, id)
  end

  file_path = File.join(RESULT_DIR, "#{GROUP_SLUG}.json")
  File.open(file_path, 'w') do |file|
    file.write(JSON.pretty_generate(result))
  end

  puts " * [#{Time.now}] retrieving #{GROUP_NAME} data completed!"
end

main
