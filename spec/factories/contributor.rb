FactoryBot.define do
  factory :contributor do
    name {"Juan Perez"}
    email {"juanito@email.com"}

    created_at {Time.now}
    updated_at {Time.now} 
  
    initialize_with do
      new(attributes)
    end
  end
end

