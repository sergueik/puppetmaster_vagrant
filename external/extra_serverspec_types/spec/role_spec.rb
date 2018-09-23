require 'spec_helper'

describe property[:target] do
  property[:roles].each do |role|
    if role.is_a?(Hash)
      context role[:description] do
        include_examples role[:name]
      end
    else
      include_examples role
    end
  end
end
