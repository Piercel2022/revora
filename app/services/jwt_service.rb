class JwtService
  class Error < StandardError
  end

  ALGORITHM = Rails.application.config.x.jwt[:algorithm]
  SECRET = Rails.application.config.x.jwt[:secret]
  ACCESS_TOKEN_TTL = Rails.application.config.x.jwt[:access_token_ttl]

  def self.encode(user)
    payload = {
      sub: user.id,
      organization_id: user.organization_id,
      role: user.role,
      exp: ACCESS_TOKEN_TTL.from_now.to_i
    }

    JWT.encode(payload, SECRET, ALGORITHM)
  end

  def self.decode(token)
    payload, = JWT.decode(token, SECRET, true, { algorithm: ALGORITHM })
    payload.with_indifferent_access
  rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError => e
    raise Error, e.message
  end

  private_class_method :new
end
