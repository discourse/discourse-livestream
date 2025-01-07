import { modifier } from "ember-modifier";

export default modifier((element, [isVisible, className]) => {
  if (isVisible) {
    element.classList.add(className);
  } else {
    element.classList.remove(className);
  }
});
