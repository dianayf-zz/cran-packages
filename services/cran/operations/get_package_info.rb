module Cran
  class GetPackageInfo < Operation
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
    map :decompress_response

    def request_packages(input)
      begin
        #http://cran.r-project.org/src/contrib/PKGNAME_PKGVERSION.tar.gz
        uri = URI("#{Cran::BASE_URL}#{package_name}_#{package_version}.tar.gz")
        result = @http_request_service.start(uri.host, uri.port) do |http|
          req = Net::HTTP::Get.new(uri)
          http.request(req)
        end
      
        sio = StringIO.new( result.body )
        gz = @zip_reader.new(sio)

        destination_file = File.join("services/resources", "packages_#{Time.now.strftime('%y%m%d')}")
        destination_directory = File.dirname(destination_file)
        File.open(destination_file, "wb") {|f| f.print gz.read}

        Success(
          {
            status_code: result.code,
            destination_file: destination_file
          }
        )
      rescue => e
        Failure(
          {
            status_code: e.code,
            destination_file: nil
          }
        )
      end
    end

    def decompress_response(input)
      control = @debian_control_file_parser.read(input.fetch(:destination_file))
      control.paragraphs.map do |paragrah|
        symbolize_keys = paragrah.deep_symbolize_keys

        {
        }
      end
    end

  end
end