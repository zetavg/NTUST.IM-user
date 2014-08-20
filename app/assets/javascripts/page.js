// This file will be included in each page, inside the body tag.
//
//= require semantic-ui

$('.ui.dropdown')
  .dropdown()
;
$('.top.sidebar').first()
  .sidebar('attach events', '.top-sidebar-toggle-button')
;
