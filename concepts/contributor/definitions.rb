module Contributors
  module RoleTypes
    AUTHOR = "AUTHOR".freeze
    MAINTAINER = "MAINTAINER".freeze
    FOUNDER = "FOUNDER".freeze
  end

  module CranRoleTypes
    AUTH = "auth".freeze
    CRE = "cre".freeze
    CTB = "ctb".freeze
    FND = "fnd".freeze
  end

  ROLE_CODE_INTERPRETER = {
    CranRoleTypes::AUTH => RoleTypes::AUTHOR,
    CranRoleTypes::CRE => RoleTypes::MAINTAINER,
    CranRoleTypes::FND => RoleTypes::FOUNDER
  }
end
