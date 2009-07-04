Event.observe(window, 'dom:loaded', function() {
  function selectPanel(element) {
    $$('div.panel').invoke('hide');
    $$('.navigation li a').invoke('removeClassName', 'active');
    $(element.className.replace(/active/, '').strip()).show();
    element.addClassName('active');
  }

  $$('.navigation li').invoke('observe', 'click', function(e) {
    var element = Event.element(e);
    selectPanel(element);
  });

  if (location.hash) {
    selectPanel($$('.navigation li a.' + location.hash.replace('#', '')).first());
  }
});
