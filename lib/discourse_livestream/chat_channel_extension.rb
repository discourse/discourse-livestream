# frozen_string_literal: true
module DiscourseLivestream
  module ChatChannelExtension
    extend ActiveSupport::Concern

    prepended { belongs_to :topic }
  end
end
