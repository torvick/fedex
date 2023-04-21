# frozen_string_literal: true

require_relative "fedex/version"
require_relative "fedex/client"
require_relative "fedex/rates"

module Fedex
  class Error < StandardError; end
end