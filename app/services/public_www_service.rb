require 'net/http'
require 'uri'
require 'csv'

class PublicWwwService
  BASE_URL = 'https://publicwww.com/websites/'
  API_KEY = '816c985dace6d8230606dab0b09baeb5'

  def initialize(query)
    @query = query
  end

  def search
    uri = URI("#{BASE_URL}#{URI.encode_www_form_component(@query)}")
    params = {
      export: 'csvu',
      key: API_KEY,
      delimiterColumns: '|||',
      delimiterSnippets: '...'
    }
    uri.query = URI.encode_www_form(params)

    response = fetch(uri)

    if response.is_a?(Net::HTTPSuccess)
      parse_csv(response.body)
    else
      Rails.logger.error "Error from PublicWWW API: #{response.code} #{response.message}"
      Rails.logger.error "Response body: #{response.body}"
      []
    end
  rescue StandardError => e
    Rails.logger.error "Error in PublicWwwService: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    []
  end

  private

  def fetch(uri, limit = 10)
    Rails.logger.info "Fetching URL: #{uri}"

    raise ArgumentError, 'Too many HTTP redirects' if limit == 0

    response = Net::HTTP.get_response(uri)
    Rails.logger.info "Response Code: #{response.code}"
    Rails.logger.info "Response Message: #{response.message}"
    Rails.logger.info "Response Headers: #{response.to_hash}"

    case response
    when Net::HTTPSuccess
      response
    when Net::HTTPRedirection
      location = response['location']
      Rails.logger.info "Redirected to #{location}"
      fetch(URI(location), limit - 1)
    else
      response.value
    end
  end

  def parse_csv(csv_string)
    Rails.logger.info "Parsing CSV response"
    Rails.logger.debug "CSV content: #{csv_string}"

    CSV.parse(csv_string, col_sep: '|||', headers: true).map do |row|
      {
        rank: row['Rank'],
        url: row['URL'],
        snippet: row['Snippet']
      }
    end
  end
end