class Dependency < Sequel::Model
  def find_by_name(name)
    Dry::Monads::Maybe(where(name: name).first)
  end

  def find_or_create(name)
    find_by_name(name: name)
      .value_or{
        begin
          create(name)
        rescue Sequel::Error => error
          find_by_name(name)
        end
      }
  end
end
