RSpec.describe CranPackages::FindOrCreatePackage do
  let(:package) { build(:cran_package) }
  let(:get_package_info_operation) {instance_double("Cran::GetPackageInfo")}
  let(:package_repository) {double("CranPackage")}
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

  let(:input) do 
    {
      name: packages_list[0][:name],
      version: packages_list[0][:version]
    }
  end

  let(:operation) do
    described_class.new(
      get_package_info_operation: get_package_info_operation,
      package_repository: package_repository
    )
  end
  

  describe "#call" do
    it "update R package info successfully" do
      allow(get_package_info_operation).to receive(:call).with(name: packages_list[0][:name], version:  packages_list[0][:version]) {Dry::Monads::Success(first_package_info)}
      allow(package_repository).to receive(:find_or_create) {package}

      result = operation.call(input)
      value = result.value!

      expect(result).to be_instance_of(Dry::Monads::Success)
      expect(value).to be_instance_of(CranPackage)
    end

    it "raise and error whhen R packages can not retrived" do
      allow(get_package_info_operation).to receive(:call).with(name: packages_list[0][:name], version:  packages_list[0][:version]) {Dry::Monads::Failure()}
      expect{operation.call(input)}.to raise_error("package information can not retrieved")
    end
  end
end

