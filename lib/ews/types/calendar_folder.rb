module Viewpoint::EWS::Types
  class CalendarFolder
    include Viewpoint::EWS
    include Viewpoint::EWS::Types
    include Viewpoint::EWS::Types::GenericFolder

    # Fetch items between a given time period
    # @param [DateTime] start_date the time to start fetching Items from
    # @param [DateTime] end_date the time to stop fetching Items from
    def items_between(start_date, end_date)
      items do |obj|
        obj.restriction = { and: [
          comparison_clause('is_greater_than_or_equal_to', 'calendar:Start', start_date),
          comparison_clause('is_less_than_or_equal_to', 'calendar:Start', end_date)
        ] }
      end
    end

    # Creates a new appointment
    # @param attributes [Hash] Parameters of the calendar item. Some example attributes are listed below.
    # @option attributes :subject [String]
    # @option attributes :start [Time]
    # @option attributes :end [Time]
    # @return [CalendarItem]
    # @see Template::CalendarItem
    def create_item(attributes, to_ews_create_opts = {})
      template = Viewpoint::EWS::Template::CalendarItem.new attributes
      template.saved_item_folder_id = {id: self.id, change_key: self.change_key}
      rm = ews.create_item(template.to_ews_create(to_ews_create_opts)).response_messages.first
      if rm&.success?
        CalendarItem.new ews, rm.items.first[:calendar_item][:elems].first
      elsif rm
        raise EwsCreateItemError, "Could not create item in folder. #{rm.code}: #{rm.message_text}"
      else
        raise EwsCreateItemError,
          "No response from EWS for create: #{template.to_ews_create(to_ews_create_opts).to_json}"
      end
    end
  end
end
