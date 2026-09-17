require "test_helper"

class JwtServiceTest < ActiveSupport::TestCase
  test "encodes and decodes a user token" do
    user = users(:owner)

    token = JwtService.encode(user)
    payload = JwtService.decode(token)

    assert_equal user.id, payload[:sub]
    assert_equal user.organization_id, payload[:organization_id]
    assert_equal user.role, payload[:role]
    assert payload[:exp].present?
  end

  test "rejects an invalid token" do
    assert_raises(JwtService::Error) do
      JwtService.decode("invalid.token.value")
    end
  end
end
