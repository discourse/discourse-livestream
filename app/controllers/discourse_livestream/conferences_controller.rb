# frozen_string_literal: true
module ::DiscourseLivestream
  class ConferencesController < ::ApplicationController
    before_action :ensure_logged_in, only: [:register]
    before_action :set_conference_group, only: [:register]
    before_action :set_conference, only: [:register]
    skip_before_action :check_xhr, only: %i[index agenda]

    def index
      @title = SiteSetting.conference_meta_title
      @full_title = SiteSetting.conference_meta_title
      @description_meta = SiteSetting.conference_meta_description

      respond_to do |format|
        format.html { render :index }
        format.json { render json: success_json }
      end
    end

    def register
      if join_group!
        @conference.conference_attendees.create!(attendee_params.merge(user: current_user))
        send_webhook
        render json: success_json
      else
        render_json_error "There was a registration problem", status: :unprocessable_entity
      end
    end

    def agenda
      @title = SiteSetting.conference_agenda_meta_title
      @full_title = SiteSetting.conference_agenda_meta_title
      @description_meta = SiteSetting.conference_agenda_meta_description

      results = FinalDestination::HTTP.get(URI(SiteSetting.agenda_endpoint_url))

      respond_to do |format|
        format.html { render :index }
        format.json { render json: JSON.parse(results) }
      end
    end

    private

    def join_group!
      @group.add(current_user, automatic: true)
    end

    def send_webhook
      WebHook.enqueue_hooks(:user, :register_dev_days_conference, payload: webhook_payload.to_json)
    end

    def webhook_payload
      attendee_params.merge(
        user_id: current_user.id,
        username: current_user.username,
        name: current_user.name,
        email: current_user.email,
        sign_up_date: current_user.created_at.to_s,
      )
    end

    def attendee_params
      params.require(:data).permit(:company, :title, :selected_conference, :country)
    end

    def set_conference
      @conference =
        DiscourseLivestream::Conference.find_by_category_id(SiteSetting.conference_category_id)
      raise ActiveRecord::RecordNotFound unless @conference.present?
    end

    def set_conference_group
      @group = Group.find_by_name(SiteSetting.conference_group_name)
    rescue ActiveRecord::RecordNotFound
      render_json_error "conference group not found", status: :unprocessable_entity and return
    end

    def ensure_logged_in
      raise Discourse::NotLoggedIn.new unless current_user.present?
    end
  end
end
