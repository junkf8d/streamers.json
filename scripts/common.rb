# frozen_string_literal: true

require 'net/http'
require 'fileutils'
require 'date'

CACHE_DIR = File.expand_path('../cache', __dir__)
RESULT_DIR = File.expand_path('../results', __dir__)

# 今日の日付のフォルダからキャッシュを読むか、ダウンロードしてくる
# ファイルパスの指定をかなり適当にやってるのでエラーになる場合はこのメソッド使わないこと
# urlからそのままファイルパスを作るのでhttps://foo.com/bar/をダウンロードしたいときは保存したい拡張子を指定すること (そのままだとbarフォルダと被るため)
def retrieve_and_cache(url, extension: '', cache: true)
  return File.read(path) unless cache

  uri = URI.parse(url)
  uri_path = "#{uri.host}/#{uri.path}".gsub(/[\\:*?"<>|]/, '_').sub(%r{/$}, '')

  path = File.join(CACHE_DIR, uri_path + extension)
  return File.read(path) if File.exist?(path)

  FileUtils.mkdir_p(File.dirname(path))

  sleep rand(3.0..8.0) # 負荷がかかりすぎないよう数秒スリープ
  Net::HTTP.get(uri).tap { |d| File.write(path, d) }
end
