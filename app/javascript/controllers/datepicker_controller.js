import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  connect() {
    const maxAttr = this.element.getAttribute("max");

    this.fp = flatpickr(this.element, {
      altInput: true,
      altFormat: "d/m/Y",
      dateFormat: "Y-m-d",
      maxDate: maxAttr || "today",
      locale: {
        firstDayOfWeek: 1,
        weekdays: {
          shorthand: ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa'],
          longhand: ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'],
        },
        months: {
          shorthand: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
          longhand: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
        },
      }
    });
  }

  disconnect() {
    if (this.fp) {
      this.fp.destroy();
    }
  }
}
