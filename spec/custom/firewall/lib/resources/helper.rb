module Serverspec::Helper::Type
  def firewalld
    Serverspec::Type::Firewalld.new
  end
end
