# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  options =
    rowHeight: 120
  $('.recommended_user__gallery').justifiedGallery(options)

  acceptedUsers = []

  $('.recommended_user__button--accept').on('click', (event) ->
    $(event.target).parent().addClass('recommended_user__button_wrapper--accepted')
    acceptedUsers.push($(event.target).data().userid)
    $('.accepted_user_output__text').text(acceptedUsers))

  $('.recommended_user__button--reject').on('click', (event) ->
    $(event.target).parent().removeClass('recommended_user__button_wrapper--accepted')
    acceptedUsers = _.reject(acceptedUsers, (i) -> i == $(event.target).data().userid)
    $('.accepted_user_output__text').text(acceptedUsers))

  $('.accepted_user_output__text').on('click', (event) ->
    $('.accepted_user_output__text').text(acceptedUsers)
    $('.accepted_user_output__text').select())
