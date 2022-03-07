
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})


socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("schedule:lobby", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })


// DELETE EVENTS
let delete_event = document.getElementById('delete');

if (delete_event != null) {
  delete_event.addEventListener('click', function(event) {
      let id = document.querySelector('#plan_id').textContent
      channel.push('delete', { data: id })
  })
}
channel.on('delete', (msg) => {
  document.getElementById(msg.id.replace(/[^0-9]/g, "")).style.display = "none"})

  // CREATE EVENTS
let create_event = document.getElementById('create');

if (create_event != null) {
  create_event.addEventListener('click', function(event) {
      let { value: repetition } = document.querySelector('#plan_repetition')
      let { value: date_year } = document.querySelector('#plan_date_year')
      let { value: date_month } = document.querySelector('#plan_date_month')
      let { value: date_day } = document.querySelector('#plan_date_day')
      let { value: date_hour } = document.querySelector('#plan_date_hour')
      let { value: date_minute } = document.querySelector('#plan_date_minute')
      channel.push('create', { data: { repetition, date_year, date_month, date_day, date_hour, date_minute } })
  })
}

channel.on('create', (msg) => {
  document.querySelector("#event").innerHTML += msg.html_event
})

// EDIT EVENTS
let edit_event = document.getElementById('edit');

if (edit_event != null) {
  edit_event.addEventListener('click', function(event) {
    let { value: repetition } = document.querySelector('#plan_repetition')
    let { value: date_year } = document.querySelector('#plan_date_year')
    let { value: date_month } = document.querySelector('#plan_date_month')
    let { value: date_day } = document.querySelector('#plan_date_day')
    let { value: date_hour } = document.querySelector('#plan_date_hour')
    let { value: date_minute } = document.querySelector('#plan_date_minute')
    let { value: id } = document.querySelector('#plan_id')
    channel.push('edit', { data: { repetition, date_year, date_month, date_day, date_hour, date_minute, id } })
  })
}

channel.on('edit', (msg) => {
  document.getElementById(msg.id).innerHTML = msg.html_event
})


export default socket
