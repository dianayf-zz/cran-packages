module Cran
  class GetPackages < Operation
    def initialize(
      http_request_service: Faraday.new
      ) 
      @http_request_service = http_request
      super
    end

    step :request_packages
    map :clean_response

    def request_packages(input)
      begin
        result = @http_request_service.send(GET) do |req|
          req.url(Cran::RequestUrls::LIST)
        end

        Success(
          {
            response_headers: result.headers,
            status_code: result.status,
            response_body: result.body
          }
        )
      rescue e
        Failure(
          {
            response_body: nil,
            response_headers: nil,
            status_code: e.code
          }
        )
      end
    end

    def clean_response(input)
#      File.open('image.png', 'wb') { |fp| fp.write(response.body) }
      #{
      #  package_name: Package, 
      #  version: version, 
      #  r_dependency: , 
      #  dependencies: 
      #}
      puts body.inspect
    end
  end
end
