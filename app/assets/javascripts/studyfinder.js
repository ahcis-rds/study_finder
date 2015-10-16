var standalone = ("standalone" in window.navigator) && window.navigator.standalone;

$(function() {
  applySelect2();
  addListeners();
  applyPopovers();
  applyTypeahead();
  determineStandalone();
});

function applySelect2() {
  $('.select2').each(function() {

    var $this = $(this);
    var tags = false, 
        multiple = false,
        options = { width: '100%' };

    if($this.hasClass('tags')) {
      options.tags = [];
      options.multiple = true;
      options.tokenSeparators = [","];
    }

    // Remove this since it's added by simple form.
    $this.removeClass('form-control');
    $this.select2(options);
  });
}

function addListeners() {
  $('.study-results').on('click', '.btn-all-locations', function() {
    $(this).next('.study-locations').removeClass('hide');
  });

  $('.study-results').on('click', '.btn-hide', function() {
    $(this).parent().parent().addClass('hide');
  });

  $('.study-results').on('click', '.btn-show-full-eligibility', function() {
    $(this).parent().prev('.eligibility-criteria').removeClass('hide');
  });

  $('.study-results').on('click', '.btn-hide-full-eligibility', function() {
    $(this).parent().parent().addClass('hide');
  });

  $('.btn-reindex').on('click', function() {
    $(this).html('Indexing... Please Wait.');
  });
}

function applyPopovers() {
  $('[data-toggle="popover"]').popover({ trigger: 'hover' });
}

function applyTypeahead() {
  var engine = new Bloodhound({
    name: 'keyword-search',
    remote: '/studies/typeahead?q=%QUERY',
    datumTokenizer: function(d) {
      return Bloodhound.tokenizers.whitespace(d.val);
    },
    queryTokenizer: Bloodhound.tokenizers.whitespace
  });

  engine.initialize();

  $('.typeahead').typeahead(
    {
      minLength: 2,
      highlight: true,
      hint: false
    },
    {
      name: 'keyword-search',
      displayKey: 'text',
      source: engine.ttAdapter()
    }
  );
}

function determineStandalone() {
  if(standalone) {
    // Set back to landing page after 1 min and 30 seconds of idle time.
    $.idleTimer(90 * 1000);
    $(document).on("idle.idleTimer", function() {
      window.location = "splash";
    });

    // Hide elements that shouldn't display on kiosk.
    $('.rm-link').hide();
    $('.btn-more-info').hide();
    $('.nav-for-researchers').hide();
    $('.credentials').hide();
  }
}

function track(method, event, category, action, data) {
  if(ga) {
    ga(method, event, category, action, data);
  }
}

/* 
  This is all related to keeping the user in the standalone version when
  clicking a link.  The default behavior on iOS is that Safari will take
  the user out of app mode and open the link a new window in Safari.
*/

(function(document,navigator,standalone) {
    // prevents links from apps from oppening in mobile safari
    // this javascript must be the first script in your <head>
    if ((standalone in navigator) && navigator[standalone]) {
        var curnode, location=document.location, stop=/^(a|html)$/i;
        document.addEventListener('click', function(e) {
            curnode=e.target;
            while (!(stop).test(curnode.nodeName)) {
                curnode=curnode.parentNode;
            }
            // Condidions to do this only on links to your own app
            // if you want all links, use if('href' in curnode) instead.
            if('href' in curnode && ( curnode.href.indexOf('http') || ~curnode.href.indexOf(location.host) ) && curnode.href.indexOf("/ctgov/") == -1  ) {
                e.preventDefault();
                location.href = curnode.href;
            }
        },false);
    }
})(document,window.navigator,'standalone');
