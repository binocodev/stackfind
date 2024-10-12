require 'net/http'
require 'uri'
require 'nokogiri'

class PublicWWW
  BASE_URL = 'https://publicwww.com/websites/'

  def self.search(query)
    uri = URI.parse("#{BASE_URL}#{URI.encode_www_form_component(query)}")
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      parse_results(response.body)
    else
      []
    end
  end

  private

  def self.parse_results(html)
    doc = Nokogiri::HTML(html)
    results = []

    doc.css('table#results tr').each do |row|
      columns = row.css('td')
      next if columns.empty?

      results << {
        rank: columns[0].text.strip,
        url: columns[1].text.strip,
        snippet: columns[2].text.strip
      }
    end

    results
  end
end