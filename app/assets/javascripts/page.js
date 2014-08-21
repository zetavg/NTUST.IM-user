// This file will be included in each page, inside the body tag.
//
//= require semantic-ui

$('.ui.dropdown')
  .dropdown()
;
$('.top.sidebar').first()
  .sidebar('attach events', '.top-sidebar-toggle-button')
;

$('.top-sidebar-toggle-button').unbind('click').bind('click', function () {
  if ($('.left.sidebar').sidebar('is open')) {
    $('.left.sidebar').sidebar('hide');
  } else if ($('.top.sidebar').sidebar('is open')) {
    $('.top.sidebar').sidebar('hide');
  } else {
    if ($(window).width() > 992) {
      $('.top.sidebar').sidebar('toggle');
    } else {
      $('.left.sidebar').sidebar('toggle');
    }
  }
});
