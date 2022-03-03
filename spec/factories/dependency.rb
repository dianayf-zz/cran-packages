FactoryBot.define do
  factory :dependency do
    name {"html-tools"}
  
    initialize_with do
      new(attributes)
    end
  end

end

