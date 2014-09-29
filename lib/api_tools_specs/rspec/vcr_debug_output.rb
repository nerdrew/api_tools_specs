VCR::Errors::UnhandledHTTPRequestError.module_eval do
  def request_description_with_sk_debug
    output = request_description_without_sk_debug
    output << "\n"
    output << request.body if VCR.current_cassette && VCR.current_cassette.match_requests_on.include?(:body)
    output
  end
  alias_method_chain :request_description, :sk_debug

  def cassette_description_with_sk_debug
    if cassette = VCR.current_cassette
      output = ["VCR is currently using the following cassettes:"]

      add_output = lambda do |interaction_list|
        break if (interactions = interaction_list.send(:interactions)).empty?
        output += [
          "  - #{cassette.file}",
          "  - :record => #{cassette.record_mode.inspect}",
          "  - :match_requests_on => #{cassette.match_requests_on.inspect}"
        ]
        interactions.each do |interaction|
          recorded_request = interaction.request
          cassette.match_requests_on.each do |match|
            if match == :body
              output << "  - :body => \n#{recorded_request.body}" if recorded_request.body.present?
            else
              output << "  - #{match.inspect} => #{recorded_request.send(match).inspect}"
            end
          end
          output << nil
        end
      end

      add_output.call(cassette.send(:http_interactions))
      parent_list = cassette.send(:http_interactions)
      while parent_list = parent_list.parent_list
        break if VCR::Cassette::HTTPInteractionList::NullList === parent_list
        add_output.call parent_list
      end

      output += [
        "Under the current configuration VCR can not find a suitable HTTP interaction",
        "to replay and is prevented from recording new requests. There are a few ways",
        "you can deal with this:\n"
      ]
      output.join "\n"
    else
      ["There is currently no cassette in use. There are a few ways",
       "you can configure VCR to handle this request:\n"].join("\n")
    end
  end
  alias_method_chain :cassette_description, :sk_debug
end
