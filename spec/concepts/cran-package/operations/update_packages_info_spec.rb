RSpec.describe CranPackage::UpdatePackagesInfo do
  let(:package) { build(:crain_package) }
  let(:get_packages_operation) {instance_double("Cran::GetPackages")}
  let(:get_package_info) {instance_double("Cran::GetPackageInfo")}
  let(:package_repository) {instance_double("CranPackageRepository")}
  let(:packages_list) do
    [
      {
        name: "A3",
        version: "1.0.0",
        r_dependency: "R (>= 2.15.0)",
        dependencies:  ["xtable", "pbapply"],
        license: "GPL (>= 2)"
      },
      {
        name: "aaSEA",
        version: "1.1.0",
        r_dependency: "R (>= 3.4.0)",
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
      get_package_info: get_package_info,
      package_repository: package_repository
    )
  }
  

  describe "#call" do
    it "update R package info successfully" do
      allow(get_packages_operation).to receive(:call) {Dry::Monads::Success(packages_list)}
      allow(get_package_info_operation).to receive(:call).with(name: packages_list[0][:name], version:  packages_list[0][:version]) {Dry::Monads::Success(first_package_info)}
      allow(get_package_info_operation).to receive(:call).with(name: packages_list[1][:name], version:  packages_list[1][:version]) {Dry::Monads::Success(second_package_info)}
      allow(package_repository).to receive(:find_or_create) {Dry::Some.new(crain_package)}

      result = operation.call
      value = result.value!

      expect(result).to be_instance_of(Dry::Monads::Success)
    end

    it "returns Failure when R package info can not be updated" do
      result = operation.call
      expect(result).to be_instance_of(Dry::Monads::Failure)
    end
  end
end

