# frozen_string_literal: true

# Helper methods for the Users views
module UsersHelper
  # Generate a form field for a profile attribute. Should be disabled if the
  # attribute is defined on the passed user object, and should include a hidden
  # field if disabled.
  #
  # @param form [SimpleForm::FormBuilder] the form object
  # @param user [User] the user record
  # @param field [Symbol] the field / attribute
  # @return [String] the form field, optionally disabled with a hidden field for
  #   the form to submit data
  def profile_field(form:, user:, field:)
    if user.send(field).nil? || user.send(field).to_s.empty?
      form.input(field, disabled: false)
    else
      form.input(field, disabled: true) + "\n" +
        form.input(field, as: :hidden)
    end
  end
end
