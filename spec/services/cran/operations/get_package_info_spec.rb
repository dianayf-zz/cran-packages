RSpec.describe Cran::GetPackageInfo do

  let(:zip_reader) {double("Zlib::GzipReader")}
  let(:mini_tar_reader) {double("Minitar::Reader")}
  let(:zip_reader_instance) {instance_double("Zlib::GzipReader")}
  let(:mini_tar_reader_instance) {instance_double("Minitar::Reader")}
  #let(:operation) { described_class.new(zip_reader: zip_reader) }
  let(:operation) { described_class.new() }
  let(:success_body) {Zlib::GzipWriter.new(StringIO.new("lala")).close.string}
  let(:success_response) {{body: success_body, status: 200}}
  let(:failure_response) {{body: "", status: 404}}
  let(:package_name) {"A3"}
  let(:package_version) {"1.0.0"}
  let(:url_request) { URI("#{Cran::BASE_URL}#{package_name}_#{package_version}.tar.gz")}
  let(:input) {{name: package_name, version: package_version}}

  describe "#call" do
    it "retuns R package info by name and version" do
      allow(zip_reader).to receive(:new) {zip_reader_instance} 
      allow(zip_reader_instance).to receive(:read) {success_body}
#      allow(mini_tar_reader).to receive(:new) {mini_tar_reader_instance} 
      #<InstanceDouble(Zlib::GzipReader) (anonymous)> received unexpected message :pos with (no args)
=begin
      stub_request(:get, url_request).
        to_return(success_response)
=end

      result = operation.call(input)
      value = result.value!

      expect(result).to be_instance_of(Dry::Monads::Success)
      expect(value.keys).to include(:title, :authors, :maintainers, :publication_date)
      expect(value[:title]).not_to be_empty
    end

    it "returns Failure when R package info can not be getting" do
      stub_request(:get, url_request).
        to_return(failure_response)
      result = operation.call(input)
      expect(result).to be_instance_of(Dry::Monads::Failure)
    end
  end
end

