module WorkflowValidation
  def valid?
    validate[:valid]
  end

  def invalid?
    not valid?
  end

  def errors
    validate[:errors]
  end

  private

  VALIDATION_METHODS = [
    :dummy_validation,
  ]

  def validate
    results = VALIDATION_METHODS.map { |v| method(v).call }
    valid = results.reduce(true) { |bool, result| bool & result[:valid] }
    error_messages = results.each_with_object([]) do |result, array|
      array << result[:message] unless result[:valid]
    end.compact

    {
      valid: valid,
      errors: error_messages,
    }
  end

  def dummy_validation
    {valid: @dummy_validation, message: 'dummy'}
  end
end