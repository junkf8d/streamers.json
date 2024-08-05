# frozen_string_literal: true

require 'json'

COMBINED_FILE_NAME = 'liver.json'

desc '全てスクレイピングする'
task :scrape_all do
  Dir.glob('scripts/scrapers/*.rb') do |s|
    ruby s
  end
end

desc '実行結果を結合する'
task :combine_results do
  combined = Dir.glob('results/*.json').map do |s|
    data = JSON[File.read(s)]
    data.map { |item| item.except('allLinks') }
  end
  json = JSON.pretty_generate(combined)
  File.write(COMBINED_FILE_NAME, json)
end

desc '全てを実行する'
task 'build' do
  %i[scrape_all combine_results].each do |task|
    Rake::Task[task].invoke
  end
end
