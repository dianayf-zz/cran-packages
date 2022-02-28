module Cran
  class GetPackageInfo < Operation
    def initialize(
      debian_control_file_parser: DebControl::ControlFileBase,
      http_request_service: Net::HTTP,
      mini_tar_reader: Minitar::Reader,
      zip_reader: Zlib::GzipReader
      ) 
      @debian_control_file_parser = debian_control_file_parser
      @http_request_service = http_request_service
      @zip_reader = zip_reader
      @mini_tar_reader = mini_tar_reader
      super
    end

    step :request_package
    map :decompress_response

    def request_package(input)
      name = input.fetch(:name)
      version = input.fetch(:version)
      begin
        #https://cran.r-project.org/src/contrib/A3_1.0.0.tar.gz
        uri = URI("#{Cran::BASE_URL}/#{name}_#{version}.tar.gz")
        result = @http_request_service.start(uri.host, uri.port) do |http|
          req = Net::HTTP::Get.new(uri)
          http.request(req)
        end

       destination_file = File.join("services/resources", "package_#{name}_#{version}_#{Time.now.strftime('%y%m%d')}")
       destination_directory = File.dirname(destination_file)
      
       sio = StringIO.new( result.body )
       tgz = @zip_reader.new(sio)
       reader = @mini_tar_reader.new(tgz)
       reader.rewind
       reader.each_entry{|e| File.open(destination_file, "wb") {|f| f.print e.read} if e.full_name == "#{name}/DESCRIPTION"}

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
      content = control.paragraphs[0]
      symbolize_keys = content.deep_symbolize_keys
        {
          title: symbolize_keys.fetch(:Title),
          authors: symbolize_keys.fetch(:Author),
          maintainers: symbolize_keys[:Maintainer] || symbolize_keys[:Maintainers],
          publication_date: symbolize_keys.fetch(:"Date/Publication")
        }
    end

  end
end
