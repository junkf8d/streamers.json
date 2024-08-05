# frozen_string_literal: true

require 'json'

COMBINED_FILE_NAME = 'streamers.json'

desc '全てのスクレイピングを行う。'
task :scrape do
  puts ' * Scraping started ...'

  threads = Dir.glob('src/scrapers/*.rb').map do |s|
    Thread.new { ruby s }
  end

  threads.each(&:join)

  puts ' * Scraping completed!'
end

desc '実行結果を結合する'
task :combine do
  puts ' * Combining files started ...'
  combined = Dir.glob('results/*.json').map do |s|
    data = JSON[File.read(s)]
    puts "   * #{s}: #{data.length} items"
    data.map { |item| item.except('allLinks') }
  end.flatten
  json = JSON.pretty_generate(combined)
  File.write(COMBINED_FILE_NAME, json)
  puts " * Combining files completed! #{combined.length} items"
end

desc '全てを実行する'
task 'build' do
  %i[scrape combine].each do |task|
    Rake::Task[task].invoke
    puts
  end
end
