RSpec.describe Cran::GetPackages do
  let(:operation) { described_class.new() }

  describe "#call" do
    it "retuns R packages" do
      expect(external_request_repo).to receive(:validate_and_create)
        .and_return(external_request)
      result = operation.call
      expect(result.value).to eq(
      {
        package_name: '00Archive', 
        version:  '1.0`', 
        r_dependency:  "v 1.3", 
        dependencies:  'blabal'
      })
    end

    it "returns Failure when R package can not be getting" do
      result = operation.call
    end
  end
end

