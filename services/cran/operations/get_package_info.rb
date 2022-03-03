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
    map :parse_and_transform_response

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
        validate_result_code_and_body(result: result, name: name, version: version)
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
      content = control.paragraphs[0]
      symbolize_keys = content.deep_symbolize_keys
      maintainer = get_maintainer_data(symbolize_keys[:Maintainer])

      {
        title: symbolize_keys.fetch(:Title).gsub("\n", " "),
        authors: get_author_information(data: symbolize_keys, maintainer: maintainer),
        maintainers: [maintainer],
        publication_date: symbolize_keys.fetch(:"Date/Publication")
      }
    end

    def decompress_and_save_file(body:, destination_file:, package_name:)
       sio = StringIO.new(body)
       tgz = @zip_reader.new(sio)
       reader = @mini_tar_reader.new(tgz)
       reader.rewind
       reader.each_entry{|e| File.open(destination_file, "wb") {|f| f.print e.read} if e.full_name == "#{package_name}/DESCRIPTION"}
    end

    def get_author_information(data:, maintainer:)
      return [maintainer] if !data.fetch(:Author).nil?
      authors = data[:'Authors@R']
      person = authors.split("person")
      person_details = person[1..-1].flat_map{|element| element.split(",").join(",").gsub(/\(|email =|role =| c\(|\)/, "")}
      person_details.map do |element|
        element = o.split(",")
        {name: body[0..1].join(",").gsub(",",""), email: body[2].gsub(">"," ").strip, role: body[3..-1]}
      end
    end

    def get_maintainer_data(data)
      name, email = data.split("<").map{|element| element.gsub(">", "").strip}
      {name: name, email: email, role: []}
    end

    def validate_result_code_and_body(result:, name:, version:)
       if result.code.to_i == 200
         destination_file = File.join("services/resources", "package_#{name}_#{version}_#{Time.now.strftime('%y%m%d')}")
         destination_directory = File.dirname(destination_file)
         decompress_and_save_file(body: result.body, destination_file: destination_file, package_name: name)
         Success(
           {
             status_code: result.code,
             destination_file: destination_file
           }
         )
       else
         Failure(
           {
             status_code: result.code,
             destination_file: nil
           }
         )
       end
    end
  end
end
