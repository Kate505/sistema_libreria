import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    timeout: Number,
  };

  connect() {
    const timeout = this.timeoutValue || 3000;
    this.timerIds = [];

    this.element.querySelectorAll("[data-flash-message]").forEach((message) => {
      // Start dismiss sequence after timeout
      const timerId = setTimeout(() => {
        // Fade out
        message.style.transition = "opacity 0.4s ease";
        message.style.opacity = "0";

        // Remove after fade completes (no transitionend dependency)
        const removeId = setTimeout(() => {
          if (message.parentNode) message.remove();
        }, 450);

        this.timerIds.push(removeId);
      }, timeout);

      this.timerIds.push(timerId);
    });
  }

  disconnect() {
    if (!this.timerIds) return;
    this.timerIds.forEach((id) => clearTimeout(id));
    this.timerIds = [];
  }
}
