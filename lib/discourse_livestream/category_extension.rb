# frozen_string_literal: true
module DiscourseLivestream
  module CategoryExtension
    extend ActiveSupport::Concern

    prepended do
      has_one :conference, class_name: "DiscourseLivestream::Conference", dependent: :destroy
    end
  end
end
