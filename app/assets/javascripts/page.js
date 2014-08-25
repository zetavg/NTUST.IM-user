// This file will be included in each page, inside the body tag.
//
//= require semantic-ui

$(document).ready(function() {

  $('.ui.dropdown')
    .dropdown()
  ;

  $('.ui.checkbox')
    .checkbox()
  ;

  $('.ui.has-popup')
    .popup({
      position: 'bottom center'
    })
  ;

  $('.top.sidebar').first()
    .sidebar('attach events', '.top-sidebar-toggle-button')
  ;

  $('.top-sidebar-toggle-button').unbind('click').bind('click', function () {
    if ($('.mobile.sidebar').sidebar('is open')) {
      $('.mobile.sidebar').sidebar('hide');
    } else if ($('.top.sidebar').sidebar('is open')) {
      $('.top.sidebar').sidebar('hide');
    } else if ($('.apps.sidebar').sidebar('is open')) {
      $('.apps.sidebar').sidebar('hide');
    } else {
      $('.wrapper > .main').unbind('click').bind('click', function () {
        $('.sidebar').sidebar('hide');
      });
      if ($(window).width() > 992) {
        $('.top.sidebar').sidebar('toggle');
      } else {
        $('.mobile.sidebar').sidebar('toggle');
      }
    }
  });

  $('.field_with_errors').parent('.field').addClass('error');

});
