require 'dry-struct'
module Types
  include Dry.Types()
  Dry::Types.load_extensions(:maybe)
end

class Operation
  include Dry::Transaction
  include Dry::Core::Constants

  def initialize(*args)
    super(*args)
  end

  def call(*args)
    super(*args)
  end

  def check_schema_validation(validation)
    if validation.success?
      Success(validation.to_h)
    else
      Failure(type: :input_validation_error, messages: validation.errors(full: true).to_h)
    end
  end

  def fail_with_validation_error(messages)
    Failure(type: :input_validation_error, messages: messages)
  end

  def fail_with_not_found(reason: "La entidad no existe")
    Failure(type: :not_found, reason: reason)
  end

  def fail_with_unauthorized(reason: "No autorizado")
    Failure(type: :unauthorized, reason: reason)
  end

  def fail_with_forbidden(reason: "Prohibido")
    Failure(type: :forbidden, reason: reason)
  end

  def fail_with_unprocessable(reason: "Solicitud no procesable")
    Failure(type: :unprocessable, reason: reason)
  end
end
