class Code < ActiveRecord::Base
  require 'net/http'
  require 'uri'

  def computed_url
    h = get_best_medline_entry

    h.nil? ? "" : h['link']['href']
  end

  def computed_title
    h = get_best_medline_entry
    h.nil? ? "" : h['title']
  end

  def computed_summary
    h = get_best_medline_entry
    h.nil? ? "" : h['summary']
  end

  def get_best_medline_entry
    h = query_medline_plus
    return nil if h.nil?

    entries = h['feed']['entry']
    if entries.class.name == 'Array'
      return entries[0]
    else
      return entries
    end

  end

  def query_medline_plus
    return @medline_data if @medline_data

    uri = URI.parse("https://apps.nlm.nih.gov/medlineplus/services/mpconnect_service.cfm?mainSearchCriteria.v.cs=2.16.840.1.113883.6.103&mainSearchCriteria.v.c=#{self.code_as_decimal}")
    response = Net::HTTP.get_response(uri)
    @medline_data = Hash.from_xml(response.body)
  end

  def code_as_decimal
    if self.code.start_with?('V')
      dcode = self.code.dup
      return dcode.insert(3,'.')
    end

    dcode = code.to_f
    while dcode >= 1000
      dcode = dcode / 10.to_f
    end

    sprintf("%.2f", dcode)
  end
end
