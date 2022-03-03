RSpec.describe CranPackages::GetPackages do
  let(:first_package) { build(:cran_package, name: "package 1").to_hash }
  let(:second_package) { build(:cran_package, name: "package 2").to_hash }
  let(:get_packages_operation) {instance_double("Cran::GetPackages")}
  let(:find_or_create_package) {instance_double("CranPackages::FindOrCreatePackage")}
  let(:packages_list) do
    [
      {
        name: "A3",
        version: "1.0.0",
        r_version_needed: "R (>= 2.15.0)",
        dependencies:  ["xtable", "pbapply"],
        license: "GPL (>= 2)"
      },
      {
        name: "aaSEA",
        version: "1.1.0",
        r_version_needed: "R (>= 3.4.0)",
        dependencies:  [],
        license: "GPL-3"
      }
    ]
  end

  let(:first_package_info) do
    {
      title: "Some title",
      authors: "Diana",
      maintainers: "Diana <diana@mail.co>",
      publication_date: "2013-02-07 10:00:27"
    }
  end

  let(:second_package_info) do
    {
      title: "Some title",
      authors: "Diana",
      maintainers: "Diana <diana@mail.co>",
      publication_date: "2013-02-07 10:00:27"
    }
  end

  let(:operation) do
    described_class.new(
      get_packages_operation: get_packages_operation,
      find_or_create_package: find_or_create_package
    )
  end
  

  describe "#call" do
    it "Get all available R packages and persist information" do
      allow(get_packages_operation).to receive(:call) {Dry::Monads::Success(packages_list)}
      expect(find_or_create_package).to receive(:call)
        .with(packages_list[0]) {Dry::Monads::Success(first_package)}

      expect(find_or_create_package).to receive(:call)
        .with(packages_list[1]) {Dry::Monads::Success(second_package)}

      result = operation.call
      value = result.value!

      expect(result).to be_instance_of(Dry::Monads::Success)
    end

    it "raise an error when R packages can not be retrieved" do
      allow(get_packages_operation).to receive(:call) {Dry::Monads::Failure()}
      expect{operation.call}.to raise_error("packages can not retrieved")
    end
  end
end

