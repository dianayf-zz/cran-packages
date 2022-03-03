RSpec.describe Cran::GetPackages do

  let(:operation) { described_class.new() }
  let(:success_body) {Zlib::GzipWriter.new(StringIO.new("lala")).close.string}
  let(:success_response) {{body: success_body, status: 200, headers: {}}}
  let(:failure_response) {{body: "", status: 404, headers: {}}}
  let(:url_request) { URI("#{Cran::BASE_URL}#{Cran::RequestUrls::LIST}")}

  describe "#call" do
    it "retuns R packages" do
      stub_request(:get, url_request)
        .with( headers: {'Accept'=>'*/*',
                         'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Host'=>'cran.r-project.org',
                         'User-Agent'=>'Ruby'})
        .to_return(success_response)

      result = operation.call
      expect(result).to be_instance_of(Dry::Monads::Success)
    end

    it "returns Failure when R package can not be getting" do
      stub_request(:get, url_request)
        .with( headers: {'Accept'=>'*/*',
                         'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Host'=>'cran.r-project.org',
                         'User-Agent'=>'Ruby'})
        .to_return(failure_response)

      result = operation.call
      expect(result).to be_instance_of(Dry::Monads::Failure)
    end
  end
end

