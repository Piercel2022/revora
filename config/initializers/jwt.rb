Rails.application.config.x.jwt = {
  secret: ENV.fetch("REVORA_JWT_SECRET"),
  algorithm: "HS256",
  access_token_ttl: 15.minutes
}
