FactoryBot.define do
  factory :cran_package do
    name { "Package1"}
    version { "1.0.0"}
    details {
      {
        r_dependency: "R (>= 2.15.0)" ,
        dependencies:  ["xtable", "pbapply"] ,
        license:  "GPL (>= 2)",
        title:  "Some title",
        authors:  "Diana",
        maintainers:  "Diana <diana@mail.co>",
        publication_date:  "2013-02-07 10:00:27" 
      }
    }
    created_at {Time.now}
    updated_at {Time.now} 
  
    initialize_with do
      new(attributes)
    end
  end

end

