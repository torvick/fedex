require 'httparty'
require 'nokogiri'

module Fedex
  class Rates
    include HTTParty
    debug_output $stdout
    base_uri 'https://wsbeta.fedex.com:443'

    def self.get(client, quote_params)
      validation = validate_quote_params(quote_params)
      if validation[:valid]
        request_body = build_request_body(client, quote_params)
        response = self.post('/xml', body: request_body, :headers => {'Content-type' => 'application/xml'})
        if response.success?
          parse_response(response.parsed_response)
        else
          { valid: false, message: "Error #{response.code}: #{response.message}" }
        end
      else
        { valid: false, message: validation[:message] }
      end
    end

    private

    def self.build_request_body(credentials, quote_params)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.RateRequest(xmlns: 'http://fedex.com/ws/rate/v13') do
          xml.WebAuthenticationDetail do
            xml.UserCredential do
              xml.Key credentials[:key]
              xml.Password credentials[:password]
            end
          end
          xml.ClientDetail do
            xml.AccountNumber credentials[:account_number]
            xml.MeterNumber credentials[:meter_number]
            xml.Localization do
              xml.LanguageCode 'es'
              xml.LocaleCode 'mx'
            end
          end
          xml.Version do
            xml.ServiceId "crs"
            xml.Major "13"
            xml.Intermediate "0"
            xml.Minor "0"
          end
          xml.ReturnTransitAndCommit true
          xml.RequestedShipment do
            xml.DropoffType "REGULAR_PICKUP"
            xml.PackagingType "YOUR_PACKAGING"
            xml.Shipper do
              xml.Address do
                xml.StreetLines 
                xml.City 
                xml.StateOrProvinceCode "XX"
                xml.PostalCode quote_params[:address_from][:zip]
                xml.CountryCode quote_params[:address_from][:country]
              end
            end
            xml.Recipient do
              xml.Address do
                xml.StreetLines 
                xml.City 
                xml.StateOrProvinceCode "XX"
                xml.PostalCode quote_params[:address_to][:zip]
                xml.CountryCode quote_params[:address_to][:country]
                xml.Residential false
              end
            end
            xml.ShippingChargesPayment do
              xml.PaymentType "SENDER"
            end
            xml.RateRequestTypes "ACCOUNT"
            xml.PackageCount 1
            xml.RequestedPackageLineItems do
              xml.SequenceNumber 1
              xml.GroupPackageCount 1
              xml.Weight do
                xml.Units quote_params[:parcel][:mass_unit].to_s.upcase
                xml.Value quote_params[:parcel][:weight]
              end
              xml.Dimensions do
                xml.Length quote_params[:parcel][:length].to_i
                xml.Width quote_params[:parcel][:width].to_i
                xml.Height quote_params[:parcel][:height].to_i
                xml.Units quote_params[:parcel][:distance_unit].to_s.upcase
              end
            end
          end
        end
      end
      builder.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::NO_DECLARATION).strip
    end

    def self.parse_response(response_body)
      rates = []
      response_body['RateReply']['RateReplyDetails'].each do |rate_reply_detail|
        rate = {}
        rate_reply_detail['RatedShipmentDetails'].each do |rated_shipment_details|
          rate[:price] = rated_shipment_details['ShipmentRateDetail']['TotalNetChargeWithDutiesAndTaxes']['Amount']
          rate[:currency] = rated_shipment_details['ShipmentRateDetail']['TotalNetChargeWithDutiesAndTaxes']['Currency']
        end
        rate[:service_level] = {
          name: rate_reply_detail['ServiceType'].to_s.split("_").map(&:capitalize).join(" "), 
          token: rate_reply_detail['ServiceType'].to_s
        }
        rates << rate
      end
      rates
    end

    def self.validate_quote_params(quote_params)
      # Verificar si quote_params contiene los valores esperados
      unless quote_params[:address_from] && quote_params[:address_to] && quote_params[:parcel]
        return { valid: false, message: "Los parámetros address_from, address_to y parcel son requeridos." }
      end
    
      unless quote_params[:address_from][:zip] && quote_params[:address_from][:country] &&
             quote_params[:address_to][:zip] && quote_params[:address_to][:country] &&
             quote_params[:parcel][:mass_unit] && quote_params[:parcel][:weight] &&
             quote_params[:parcel][:length] && quote_params[:parcel][:width] &&
             quote_params[:parcel][:height] && quote_params[:parcel][:distance_unit]
        return { valid: false, message: "Los parámetros address_from[:zip], address_from[:country], address_to[:zip], address_to[:country], parcel[:mass_unit], parcel[:weight], parcel[:length], parcel[:width], parcel[:height] y parcel[:distance_unit] son requeridos." }
      end
    
      { valid: true }
    end

  end
end