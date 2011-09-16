#!/usr/bin/env ruby
# encoding: UTF-8

# require "rubygems"
require "bundler/setup"
require "yql"
require "pp"
require "json"

# Fetch records with YQL
def get_yql(ql)
	yql = Yql::Client.new
	yql.format = "json"
	yql.query = ql
	JSON.parse(yql.get.body)["query"]["results"]["a"]
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
	(1..get_pages(q)).each { |i| records << get_estates(i,q) }
	records.flatten
end

s1 = get_by_field("stanovanje")
s2 = get_by_field("hiša")

pp s2