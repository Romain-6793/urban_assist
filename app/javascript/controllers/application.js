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

  if (input) {
    const form = input.closest("form")
    input.addEventListener("keydown", (e) => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault()       // empêche le saut de ligne
        form.requestSubmit()     // soumet le formulaire (Turbo compatible)
      }
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

// Gestion du mode édition pour renommer un chat
document.addEventListener("click", function(e) {
  const btn = e.target.closest(".sidebar__icon-btn[title='Renommer']")
  if (!btn) return

  const wrapper = btn.closest(".sidebar__list-item").querySelector(".sidebar__title-wrapper")
  const input = wrapper.querySelector(".sidebar__edit-input")

  wrapper.classList.add("editing")
  input.focus()
  input.select()
})

document.addEventListener("keydown", function(e) {
  if (e.key !== "Escape") return
  const input = document.querySelector(".sidebar__edit-input:focus")
  if (!input) return

  const wrapper = input.closest(".sidebar__title-wrapper")
  wrapper.classList.remove("editing")
})
