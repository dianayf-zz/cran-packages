RSpec.describe CranPackages::FindOrCreatePackage do

  let(:package) { build(:cran_package).save }
  let(:dependency) { build(:dependency, name: "xtable").save }
  let(:dependency_2) { build(:dependency, name: "pbapply").save }
  let(:contributor_name) {"Diana"}
  let(:contributor) { build(:contributor, name: contributor_name).save }
  let(:cran_packages_dependency) { build(:cran_packages_dependency,  package_id: package.id, dependency_id: dependency.id ) }
  let(:cran_packages_contributor) { build(:cran_packages_contributor,  package_id: package.id, contributor_id: contributor.id ) }
  let(:cran_packages_contributor) { build(:cran_packages_contributor,  package_id: package.id, contributor_id: contributor.id ) }

  let(:get_package_info_operation) {instance_double("Cran::GetPackageInfo")}
  let(:package_repository) {double("CranPackage")}
  let(:dependency_repository) {double("Dependency")}
  let(:contributor_repository) {double("Contributor")}
  let(:cran_package_dependency_repository) {double("CranPackagesDependency")}
  let(:cran_package_contributor_repository) {double("CranPackagesContributor")}

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
      authors: [{name: contributor_name,  email: "diana@email.com", role: []}],
      maintainers: [{name: "Diana", email: "diana@mail.co", role: ["cre"]}],
      publication_date: "2013-02-07 10:00:27"
    }
  end

  let(:second_package_info) do
    {
      title: "Some title",
      authors: [{name: "Diana", email: "diana@email.com", role: []}],
      maintainers: [{name: "Diana", email: "diana@mail.co", role: ["cre"]}],
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
      package_repository: package_repository,
      dependency_repository: dependency_repository,
      contributor_repository: contributor_repository,
      cran_package_dependency_repository: cran_package_dependency_repository,
      cran_package_contributor_repository: cran_package_contributor_repository

    )
  end
  
  before (:each) { clear_db_tables }

  describe "#call" do
    it "update R package info successfully" do
      allow(get_package_info_operation).to receive(:call).with(name: packages_list[0][:name], version:  packages_list[0][:version]) {Dry::Monads::Success(first_package_info)}
      allow(package_repository).to receive(:find_or_create) {package}
      allow(dependency_repository).to receive(:find_or_create).with(name: packages_list[0][:dependencies][0]) {dependency}
      allow(dependency_repository).to receive(:find_or_create).with(name: packages_list[0][:dependencies][1]) {dependency_2}
      expect(cran_package_dependency_repository).to receive(:find_or_create)
        .with(cran_package_id: package.id, dependency_id: dependency.id) {cran_packages_dependency}

      expect(cran_package_dependency_repository).to receive(:find_or_create)
        .with(cran_package_id: package.id, dependency_id: dependency_2.id) {cran_packages_dependency}
      allow(contributor_repository).to receive(:find_or_create) {contributor}
      expect(cran_package_contributor_repository).to receive(:find_or_create)
        .with(cran_package_id: package.id, contributor_id: contributor.id, role: Dependencies::RoleTypes::AUTHOR)
        .once {cran_packages_contributor}

      expect(cran_package_contributor_repository).to receive(:find_or_create)
        .with(cran_package_id: package.id, contributor_id: contributor.id, role: Dependencies::RoleTypes::MAINTAINER)
        .once{cran_packages_contributor}

      result = operation.call(input.merge(dependencies: packages_list[0][:dependencies]))
      value = result.value!

      expect(result).to be_instance_of(Dry::Monads::Success)
      expect(value).to eq(package.to_hash)
    end

    it "raise and error whhen R packages can not retrived" do
      allow(get_package_info_operation).to receive(:call).with(name: packages_list[0][:name], version:  packages_list[0][:version]) {Dry::Monads::Failure()}
      expect{operation.call(input)}.to raise_error("package information can not retrieved")
    end
  end
end

