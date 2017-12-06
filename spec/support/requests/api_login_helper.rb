# frozen_string_literal: true

def api_login(user)
  post user_session_path, params: { user: { email: user.email,
                                            password: user.password } }
end
