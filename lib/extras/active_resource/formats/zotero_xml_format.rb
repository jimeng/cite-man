require 'active_support/core_ext/hash/conversions'
require 'json'

module ActiveResource
  module Formats
    module ZoteroXmlFormat
      extend self

      def extension
        "xml"
      end

      def mime_type
        "application/atom+xml"
      end

      def encode(hash, options={})
        hash.to_xml(options)
      end

      def decode(xml)
        # debugger
        #Rails.logger.info("ActiveResource::Formats::ZoteroXmlFormat.decode")
        ##Rails.logger.info(xml)

        #debugger
        json = extractEntries(xml)
        #Rails.logger.info(json)

        items = []
        json.each do |item|
          items.push(item)
        end

        return items
      end

      private
        def extractEntries(xml) 
          require 'rexml/document'
          include REXML

          json = "[\n"
          first = true
          xmldoc = Document.new(xml)
          xmldoc.elements.each("feed/entry/content") {
            |entry|
            json += ",\n" unless first
            first = false
            json += entry.text
          }
          json += "\n]\n"
          #Rails.logger.info(json)
          return JSON.parse(json)
        end
    end
  end
end