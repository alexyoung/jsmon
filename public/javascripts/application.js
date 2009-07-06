Event.observe(window, 'dom:loaded', function() {
  function hide_question() {
    if ($('hide_failure')) $('hide_failure').remove();
  }

  document.observe('click', function(e) {
    var element = Event.element(e);
    if (element.hasClassName('hide_failure')) {
      var service_link = element.up().previous('a');
      var code = service_link.id.split('service_').last();
      new Ajax.Request('/services/update', {
        method: 'post',
        postBody: "services[#{code}][hidden]=true".interpolate({ 'code': code }),
        onSuccess: function() {
          window.location = '/';
        },
        onFailure: function() {
          alert('Service could not be hidden');
        }
      });
      Event.stop(e);
    } else if (element.hasClassName('cancel_hide_question')) {
      hide_question();
      Event.stop(e);
    }
  });

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

  $$('.edit_service').invoke('observe', 'click', function(e) {
    var element = Event.element(e);
    hide_question();
    var hide_html = ' <span id="hide_failure">hide? <a href="" class="hide_failure">Yes</a>, <a class="cancel_hide_question" href="">No</a></span>';
    element.insert({ 'after': hide_html });
    Event.stop(e);
  });

  if (location.hash) {
    selectPanel($$('.navigation li a.' + location.hash.replace('#', '')).first());
  }
});
