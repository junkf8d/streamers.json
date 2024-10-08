# frozen_string_literal: true

require 'net/http'
require 'fileutils'
require 'date'
require 'nokogiri'

CACHE_DIR = File.expand_path('../cache', __dir__)
RESULT_DIR = File.expand_path('../results', __dir__)

# 今日の日付のフォルダからキャッシュを読むか、ダウンロードしてくる
# ファイルパスの指定をかなり適当にやってるのでエラーになる場合はこのメソッド使わないこと
# urlからそのままファイルパスを作るのでhttps://foo.com/bar/をダウンロードしたいときは保存したい拡張子を指定すること (そのままだとbarフォルダと被るため)
def retrieve_and_cache(url, extension: '', cache: true, replace: {})
  uri = URI.parse(url)
  uri_path = "#{uri.host}#{uri.path}".gsub(/[\\:*?"<>|]/, '_').sub(%r{/$}, '')

  # パスとして保存したくない文字列を置換
  replace.each do |k, v|
    uri_path = uri_path.sub(k, v)
  end

  path = File.join(CACHE_DIR, uri_path + extension)
  return File.read(path) if File.exist?(path) && cache

  FileUtils.mkdir_p(File.dirname(path))

  sleep rand(3.0..8.0) # 負荷がかかりすぎないよう数秒スリープ
  Net::HTTP.get(uri).tap { |d| File.write(path, d) }
end

def create_link_map(url_list)
  url_list.map do |url|
    uri = URI.parse(url)
    uri.query = nil

    key = case uri.hostname
          when 'x.com'
            'twitter'
          when 'youtu.be'
            'youtube'
          else
            uri.hostname.split('.')[-2]
          end

    [key, uri.to_s]
  end.to_h
end
