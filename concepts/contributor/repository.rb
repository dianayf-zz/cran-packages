class Contributor < Sequel::Model

  def find_by_name_and_email(name:, email:)
    Dry::Monads::Maybe(where(name: name, email: email).first)
  end

  def find_or_create(**attrs)
    name = attrs[:name]
    email = attrs[:email]
    find_by_name_and_email(name: name, email: email)
      .value_or{
        begin
          create(**attrs)
        rescue Sequel::Error => error
          find_by_name_and_email(name: name, email: email)
        end
      }
  end
end
