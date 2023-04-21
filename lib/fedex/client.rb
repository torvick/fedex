module Fedex
  class Client
    attr_reader :credentials

    def initialize(key, password, account_number, meter_number)
      @credentials = {
        key: key,
        password: password,
        account_number: account_number,
        meter_number: meter_number
      }
    end
  end
end