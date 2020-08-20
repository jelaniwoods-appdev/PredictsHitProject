import consumer from "./consumer"



$(document).on('turbolinks:load', function () {


  consumer.subscriptions.create({
      channel: "RoomChannel",
      room_type: $('#messages').attr('data-room-type'),
      room_id: $('#messages').attr('data-room-id')
    }, {
    connected() {
      // Called when the subscription is ready for use on the server
      console.log("connected!")
    },

    disconnected() {
      // Called when the subscription has been terminated by the server
    },

    received(data) {
      // Called when there's incoming data on the websocket for this channel
      console.log(data.prof_pic)
      console.log(data.username)
      console.log(data.body)

      $('#live_messages').append(
        '<div>' +
        '<div class="float-left image pr-3">' +
        '<img src=' + data.prof_pic + ' class="img-circle avatar" alt="user profile image"></img>' +
        '</div>' + 
        '<div class="comment-text">' + 
        '<b>' + data.username + '</b>' + 
        ' ' + data.body +
        '</div>' +
        '<br>' +
        '</div>'
      )
    }

  });

})
