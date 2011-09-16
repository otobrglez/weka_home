#!/usr/bin/env ruby
# encoding: UTF-8

# require "rubygems"
require "bundler/setup"
require "yql"
require "pp"
require "json"
require 'data_mapper'
require 'dm-migrations'
require 'digest/sha1'


DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/cache.db")

class Page
  include DataMapper::Resource
  property :id,         Serial    # An auto-increment integer key
  property :hash_key,   String    # A varchar type string, for short strings
  property :body,       Text      # A text block, for longer string data.
end

DataMapper.finalize
# DataMapper.auto_migrate!
DataMapper.auto_upgrade!


# Fetch records with YQL or from sqlite3 database
def get_yql(ql)

	hash_key = Digest::SHA1.hexdigest(ql)
	page = Page.first(:hash_key => hash_key)

	if page == nil
		yql = Yql::Client.new
		yql.format = "json"
		yql.query = ql
		
		body = yql.get.body
		pg = Page.create(:hash_key => hash_key, :body => body)
		
		return JSON.parse(body)["query"]["results"]["a"]
	else
		return JSON.parse(page.body)["query"]["results"]["a"]
	end
end

# Fetch records
def get_estates(page=1,q="stanovanje")
	get_yql "select content from html where
	url='http://www.gohome.si/nepremicnine.aspx?q=#{q}&str=#{page}'
	and xpath=\"//div[@id='results']/div[@class='JQResult item']//a[@class='JQEstateUrl main_link']\""
end

# Fetch number of records
def get_pages(q="stanovanje")
	get_yql("select href from html where
	url='http://www.gohome.si/nepremicnine.aspx?q=stanovanje'
	and xpath=\"//div[@id='paging']//span[last()]/a[last()]\"")["href"].split("=").last.to_i
end

# Fetch all records for specific key
def get_by_field(q="stanovanje")
	records = []
	(1..get_pages(q)).each do |i|
		records << row2row(get_estates(i,q))
	end
	records.flatten
end

# Reformat rows
def row2row(rows)
	rows.map! do |row|
		pa = row.split(",")
		{ 	Place: pa[0],
			Location: pa[1].strip,
			Price: (pa[pa.size-3].strip).split(" ").first.sub(".",""),
			Size: (pa[pa.size-2]+","+(pa.last.split(" ").first)).strip.sub(",",".") }
	end
end

# Get some records
data = [get_by_field("stanovanje"),get_by_field("hiša")].flatten!

# Start writing *.arff file for WEKA
f = File.new("gohome.arff", "w+") 

f.puts "@RELATION iris"
f.puts "@ATTRIBUTE Cena	REAL"
f.puts "@ATTRIBUTE Size REAL"
f.puts "@ATTRIBUTE Place {Stanovanje,Hiša}"

top_locations = %w(LJUBLJANA MARIBOR CELJE KRANJ VELENJE KOPER PTUJ TRBOVLJE KAMNIK)

lokacije = ((data.map { |l| l[:Location] }).uniq!.sort!).find_all {|l| top_locations.include? l }
f.puts "@ATTRIBUTE Lokacija {"+lokacije.join(",")+"}"

f.puts "@DATA"

data.each do |loc|
	if top_locations.include? loc[:Location]
		f.puts("#{loc[:Price]},#{loc[:Size]},#{loc[:Place]},#{loc[:Location]}")
	end
end

puts "Done."

