# frozen_string_literal: true

require 'nokogiri'
require 'json'
require_relative '../common'

GROUP_NAME = 'にじさんじ'
GROUP_SLUG = 'nijisanji'

def fetch_build_id
  url = 'https://www.nijisanji.jp/talents'
  html = retrieve_and_cache(url)
  doc = Nokogiri::HTML.parse(html)

  script_tag = doc.at_xpath('//script[contains(@src, "/_next/static/") and contains(@src, "_buildManifest.js")]')
  script_tag['src'].match(%r{/_next/static/([^/]+)/_buildManifest\.js})[1]
end

def get_streamer_list(build_id)
  url = "https://www.nijisanji.jp/_next/data/#{build_id}/ja/talents.json"
  json = retrieve_and_cache(url)
  hash = JSON[json]
  hash['pageProps']['allLivers']
end

def get_streamer_detail(build_id, streamer_id)
  url = "https://www.nijisanji.jp/talents/l/#{streamer_id}"

  json_url = "https://www.nijisanji.jp/_next/data/#{build_id}/ja/talents/l/#{streamer_id}.json"
  json = retrieve_and_cache(json_url)
  hash = JSON[json]
  detail = hash['pageProps']['liverDetail']

  name = detail['name']
  allLinks = detail['socialLinks'].except('fieldId')
  links = create_link_map(allLinks.values).slice(*%w[twitter youtube bilibili twitch])

  affiliation = detail['profile']['affiliation']

  { name: name, allLinks: allLinks, links: links, tags: [GROUP_NAME, *affiliation].uniq, page: url }
end

def main
  puts " * [#{Time.now}] [#{GROUP_NAME}] Starting to retrieve data..."

  build_id = fetch_build_id
  streamer_list = get_streamer_list(build_id)
  puts " * [#{Time.now}] [#{GROUP_NAME}] Parsing Streamer list completed."

  len = streamer_list.length
  result = streamer_list.map.with_index(1) do |streamer, i|
    id = streamer['slug']
    puts format("   * [#{Time.now}] [#{GROUP_NAME}] %03d/%03d (%.2f%%) parsing: %s", i, len, i.to_f / len, id)
    get_streamer_detail(build_id, id)
  end

  file_path = File.join(RESULT_DIR, "#{GROUP_SLUG}.json")
  File.open(file_path, 'w') do |file|
    file.write(JSON.pretty_generate(result))
  end

  puts " * [#{Time.now}] [#{GROUP_NAME}] Data retrieval completed!"
end

main
