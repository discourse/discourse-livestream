import Component from "@glimmer/component";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import ConferenceAgenda from "../conference-agenda";

export default class AgendaModal extends Component {
  model = this.args.model;

  <template>
    <DModal class="agenda-modal" @closeModal={{@closeModal}}>
      <:body>
        <div class="agenda">
          <ConferenceAgenda @agenda={{this.model}} />
        </div>
      </:body>
      <:footer>
        <DButton
          @icon="check"
          class="btn-primary"
          @action={{@closeModal}}
          @label="notifications.dismiss_confirmation.dismiss"
        />
      </:footer>
    </DModal>
  </template>
}
