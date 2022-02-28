RSpec.describe Cran::GetPackages do

  let(:zip_reader) {double("Zlib::GzipReader")}
  let(:zip_reader_instance) {instance_double("Zlib::GzipReader")}
  let(:operation) { described_class.new(zip_reader: zip_reader) }
  let(:success_body) {Zlib::GzipWriter.new(StringIO.new("lala")).close.string}
  let(:success_response) {{body: success_body, status: 200}}
  let(:failure_response) {{body: "", status: 404}}
  let(:url_request) { URI("#{Cran::BASE_URL}#{Cran::RequestUrls::LIST}")}

  describe "#call" do
    it "retuns R packages" do
      allow(zip_reader).to receive(:new) {zip_reader_instance} 
      allow(zip_reader_instance).to receive(:read) {success_body}
      stub_request(:get, url_request).
        to_return(success_response)

      result = operation.call
      expect(result).to be_instance_of(Dry::Monads::Success)
      expect(result.value![0]).to include(:package_name, :version, :r_dependency, :dependencies, :licencse)
    end

    it "returns Failure when R package can not be getting" do
      stub_request(:get, url_request).
        to_return(failure_response)
      result = operation.call
      expect(result).to be_instance_of(Dry::Monads::Failure)
    end
  end
end

