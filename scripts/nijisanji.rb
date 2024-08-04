require 'nokogiri'
require 'json'
require_relative 'common'

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
  hash['pageProps']['liverDetail']
end

def main
  build_id = fetch_build_id
  puts " * [#{Time.now}] start retrieving nijisanji data... [#{build_id}]"

  liver_list = get_liver_list(build_id)
  puts " * [#{Time.now}] parse liver list completed."

  result = liver_list.map.with_index(1) do |liver, i|
    id = liver['slug']
    puts format("   * [#{Time.now}] %03d/%03d (%.2f%%) parsing: #{id}",
                i,
                liver_list.length,
                i.to_f / liver_list.length)

    detail = get_liver_detail(build_id, id)

    name = detail['name']
    youtube, twitter = detail['socialLinks'].values_at('youtube', 'twitter')

    { name: name, youtube: youtube, twitter: twitter }
  end

  file_path = File.join(RESULT_DIR, 'nijisanji.json')
  File.open(file_path, 'w') do |file|
    file.write(JSON.pretty_generate(result))
  end

  puts " * [#{Time.now}] retrieving nijisanji data completed! [#{build_id}]"
end

main
