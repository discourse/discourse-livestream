# frozen_string_literal: true
module ::DiscourseLivestream
  class ConferenceStreamsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    before_action :ensure_logged_in
    before_action :set_stream, only: [:show]
    before_action :ensure_admin, only: [:create]

    def show
      render json:
               serialize_data(
                 @stream,
                 ConferenceStreamSerializer,
                 conference_group: @conference_group,
               )
    end

    def create
      @stream = ConferenceStream.new(stream_params)

      if @stream.save
        render_serialized(@stream, ConferenceStreamSerializer)
      else
        render_json_error(@stream)
      end
    end

    private

    def set_stream
      @stream = ConferenceStream.find(params[:stream_id])
      @conference_group = Group.find_by_name(SiteSetting.conference_group_name)
      raise Discourse::InvalidAccess.new unless @stream.present?
    end

    def stream_params
      params.require(:conference_stream).permit(
        :start_date,
        :end_date,
        :name,
        :description,
        :discourse_conference_id,
      )
    end
  end
end
