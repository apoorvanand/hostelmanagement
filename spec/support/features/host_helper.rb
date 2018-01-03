# frozen_string_literal: true

# Allow requests to visit a particular subdomain / college. For more details
# see: https://robots.thoughtbot.com/acceptance-tests-with-subdomains
#
# @param college [College] the college to use, must be persisted!
def using_college(college)
  original_host = Capybara.app_host
  host = "http://#{college.subdomain}.lvh.me"
  Capybara.app_host = host

  yield
ensure
  Capybara.app_host = original_host
end
