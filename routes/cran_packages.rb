module CranPackages
  Router = Syro.new(API::Wrapper) do
    get do
      operation = CranPackages::Index.new
      handle_result operation.call, success_status: :ok
    end
  end
end
