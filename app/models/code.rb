class Code < ActiveRecord::Base
  require 'net/http'
  require 'uri'

  def computed_url
    h = query_medline_plus
    h.nil? ? "" : h['feed']['entry'][0]['link']['href']
  end

  def computed_title
    h = query_medline_plus
    h.nil? ? "" : h['feed']['entry'][0]['title']
  end

  def computed_summary
    h = query_medline_plus
    h.nil? ? "" : h['feed']['entry'][0]['summary']
  end

  def query_medline_plus
    return @medline_data if @medline_data

    uri = URI.parse("https://apps.nlm.nih.gov/medlineplus/services/mpconnect_service.cfm?mainSearchCriteria.v.cs=2.16.840.1.113883.6.103&mainSearchCriteria.v.c=#{self.code_as_decimal}")
    response = Net::HTTP.get_response(uri)
    @medline_data = Hash.from_xml(response.body)
  end

  def code_as_decimal
    dcode = code.to_f
    while dcode >= 1000
      dcode = dcode / 10.to_f
    end

    sprintf("%.2f", dcode)
  end
end
