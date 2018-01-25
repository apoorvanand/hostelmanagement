# frozen_string_literal: true

# Middleware layer to rescue from a missing tenant (invalid subdomain)
# Inspired by https://stackoverflow.com/a/28233828/2187922
module RescuedApartmentMiddleware
  def call(*args)
    super
  rescue Apartment::TenantNotFound
    # currently only returning "public" which is kinda meaningless, but maybe we
    # just don't log the error. I'd also like to ultimately redirect regardless.
    Rails.logger.error "Error: #{Apartment::Tenant.current} college not found"
    # we really want to return a 301 I think to the subdomain-less host, which
    # should just display a public page with links to all known tenants.
    return [
      404,
      {"Content-Type" => "text/html"},
      [File.read(Rails.root.to_s + '/public/404.html')]
    ]
  end
end
