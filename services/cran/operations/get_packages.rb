require 'active_support/core_ext/hash/keys'
module Cran
  class GetPackages < Operation
    def initialize(
      http_request_service: Net::HTTP,
      zip_reader: Zlib::GzipReader,
      debian_control_file_parser: DebControl::ControlFileBase
      ) 
      @http_request_service = http_request_service
      @zip_reader = zip_reader
      @debian_control_file_parser = debian_control_file_parser
      super
    end

    step :request_packages
    map :parse_and_transform_response

    def request_packages(input)
      begin
        uri = URI("#{Cran::BASE_URL}#{Cran::RequestUrls::LIST}")
        result = @http_request_service.start(uri.host, uri.port) do |http|
          req = Net::HTTP::Get.new(uri)
          http.request(req)
        end
      
        destination_file = File.join("services/resources", "packages_#{Time.now.strftime('%y%m%d')}")
        destination_directory = File.dirname(destination_file)

        decompress_and_save_file(body: result.body, destination_file: destination_file)

        Success(
          {
            status_code: result.code,
            destination_file: destination_file
          }
        )
      rescue *API::Wrapper::NET_HTTP_EXCEPTIONS => error
        Failure(
          {
            status_code: error.code || error,
            destination_file: nil
          }
        )
      end
    end

    def parse_and_transform_response(input)
      control = @debian_control_file_parser.read(input.fetch(:destination_file))
      control.paragraphs.map do |paragrah|
        symbolize_keys = paragrah.deep_symbolize_keys
        dependencies = symbolize_keys.fetch(:Depends, " ")
        clean_dependencies = dependencies.split(",")
        imports = symbolize_keys.fetch(:Imports, "")

        {
          name: symbolize_keys[:Package],
          version: symbolize_keys[:Version],
          r_version_needed: clean_dependencies[0],
          dependencies: imports.split(","),
          license: symbolize_keys[:License]
        }
      end
    end

    def decompress_and_save_file(body:, destination_file:)
      sio = StringIO.new(body)
      gz = @zip_reader.new(sio)
      File.open(destination_file, "wb") {|f| f.print gz.read}
    end
  end
end
