import { Application } from "@hotwired/stimulus"

// Démarrage de Stimulus
const application = Application.start()

// Configuration de l'expérience de développement Stimulus
application.debug = false
window.Stimulus = application

export { application }

// Scroll initial et gestion du focus
document.addEventListener("turbo:load", () => {
  const container = document.getElementById("messages-container")
  const input = document.getElementById("chat-input")
  const button = document.getElementById("send-btn")

  // Scroll smooth automatique vers le bas des messages au chargement
  if (container) {
    container.scrollTo({ top: container.scrollHeight, behavior: "smooth" })
  }

  // Focus automatique sur l'input (surtout après l'envoi d'un message)
  if (input) input.focus()

  // Activation/désactivation du bouton d'envoi si input vide
  if (input && button) {
    button.disabled = input.value.trim() === ""
    input.addEventListener("input", () => {
      button.disabled = input.value.trim() === ""
    })
  }
})


// Scroll après un rendu Turbo -> envoi de mesage

document.addEventListener("turbo:render", () => {
  const container = document.getElementById("messages-container")

  // Scroll instantané vers le bas pour garder la position actuelle
  if (container) {
    container.scrollTop = container.scrollHeight
  }
})
