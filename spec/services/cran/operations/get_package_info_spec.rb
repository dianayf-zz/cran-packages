RSpec.describe Cran::GetPackageInfo do

  let(:operation) { described_class.new() }
  let(:success_body) {Zlib::GzipWriter.new(StringIO.new("lalala")).close.string}
  let(:success_response) {{body: success_body, status: 200, headers: {}}}
  let(:failure_response) {{body: "", status: 404, headers: {}}}
  let(:package_name) {"A3"}
  let(:package_version) {"1.0.0"}
  let(:url_request) { URI("#{Cran::BASE_URL}/#{package_name}_#{package_version}.tar.gz")}
  let(:input) {{name: package_name, version: package_version}}

  describe "#call" do
    it "retuns R package info by name and version" do

      stub_request(:get, url_request)
        .with( headers: {'Accept'=>'*/*',
                         'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Host'=>'cran.r-project.org',
                         'User-Agent'=>'Ruby'})
        .to_return(success_response)

      result = operation.call(input)
      value = result.value!

      expect(result).to be_instance_of(Dry::Monads::Success)
      expect(value.keys).to include(:title, :authors, :maintainers, :publication_date)
      expect(value[:title]).not_to be_empty
    end

    it "returns Failure when R package info can not be getting" do
      stub_request(:get, url_request)
        .with( headers: {'Accept'=>'*/*',
                         'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Host'=>'cran.r-project.org',
                         'User-Agent'=>'Ruby'})
        .to_return(failure_response)

      result = operation.call(input)
      expect(result).to be_instance_of(Dry::Monads::Failure)
    end
  end
end

