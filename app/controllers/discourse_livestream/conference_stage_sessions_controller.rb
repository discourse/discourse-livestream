# frozen_string_literal: true
module ::DiscourseLivestream
  class ConferenceStageSessionsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    before_action :ensure_logged_in
    before_action :set_stream_and_stage, only: %i[create index]
    before_action :ensure_admin, only: [:create]

    def index
      if params[:status].present?
        statuses = params[:status].split(",")
        @stage_sessions = ConferenceStageSession.where(status: statuses)
      else
        @stage_sessions = ConferenceStageSession.all
      end

      @stage_sessions = @stage_sessions.order(:status)
      render json: serialize_data(@stage_sessions, ConferenceStageSessionSerializer)
    end

    def create
      ActiveRecord::Base.transaction do
        usernames = params[:stage_session].delete(:speakers)
        speakers = User.where("LOWER(username) IN (?)", usernames.split(",").map(&:downcase))

        # Set the previous live session to completed, if any
        @stage.stage_sessions.live.each { |session| session.update!(status: :completed) }

        # Create the new session
        new_session = @stage.stage_sessions.new(stage_session_params)
        new_session.status = :live # Set the new session to live

        if new_session.save!
          new_session.speakers << speakers if speakers.present?
        end
        serialized_data = serialize_data(@stream, ConferenceStreamSerializer)

        MessageBus.publish("/update_stream", serialized_data)

        render json: serialized_data
      end
    end

    private

    def set_stream_and_stage
      @stream = ConferenceStream.find_by_id(params[:stream_id])
      @stage = ConferenceStage.find_by_id(params[:stage_id])
      raise Discourse::InvalidAccess.new if @stream.nil? || @stage.nil?
    end

    def stage_session_params
      params.require(:stage_session).permit(
        :title,
        :external_id,
        :start_time,
        :end_time,
        :description,
      )
    end
  end
end
