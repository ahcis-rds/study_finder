$(function() {

// "Email this study information to me" button listener
$('#email-me-modal').on('show.bs.modal', function (event) {
  var button = $(event.relatedTarget);
  var studyTitle = button.data('title');
  var trialId = button.data('trial-id');
  var modal = $(this);
  // pass some trial attributes from the search results into the modal
  modal.find('.study-title').text(studyTitle);
  modal.find('#email-me-modal-submit').data('trial_id', trialId).data('button', button);

  if(window.myselfWidget !== undefined) {
    grecaptcha.reset();
  }
});

// "Email this study information to me" form handler
$('#email-me-modal-submit').on('click', function (event) {
  var $this = $(this),
      trial_id = $this.data('trial_id'),
      parentButton = $this.data('button'),
      form = $('#email-me-form');

  // reset validation messages
  form.find('.help-inline').remove();
  form.find('.form-group').removeClass('has-error');

  // grab our form inputs
  var email = form.find('.email');
  var notes = form.find('.notes');
  var captcha = form.find('#g-recaptcha-response');

  if(window.myselfWidget !== undefined) {
    var mwResponse = grecaptcha.getResponse( window.myselfWidget )
  }

  if ($.trim(email.val())  === '' || (window.myselfWidget !== undefined && !mwResponse.length)) {
    email.parent().addClass('has-error');

    if($.trim(email.val())  === '')
      email.parent().append('<span class="help-inline">Please provide your email.</span>');

    if(window.myselfWidget !== undefined && !mwResponse.length) {
      captcha.parent().append('<span class="help-inline">Please complete the captcha.</span>');
    }

    email.focus();
    return false;
  }

  var data = {
    id: trial_id,
    email: email.val(),
    notes: notes.val()
  };

  if(window.myselfWidget !== undefined) {
    data['g-recaptcha-response'] = mwResponse;
  }

  var jqxhr = $.post("/studies/email_me", data, function() {
    // clear the form
    $('#email-me-form').trigger("reset");
    // close window
    $('#email-me-modal').modal('hide');
    // tell user their email was successfully sent
    $('<div class="alert alert-success alert-dismissible" role="alert" style="margin-top:10px;"><button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>Your email has been sent!</div>')
      .insertAfter(parentButton.parent());

    // Track to analytics
    track('send', 'event', 'email_me', 'sent', {'trial_id':trial_id});
  })
    .fail(function() {
      // clear the form
    $('#email-me-form').trigger("reset");
    // close window
    $('#email-me-modal').modal('hide');
      // leave window open
      $('<div class="alert alert-danger alert-dismissible" role="alert" style="margin-top:10px;"><button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>There was a problem sending your email</div>')
        .insertAfter(parentButton.parent());
    });
});

// "Contact the Study Team" button listener
$('#contact-study-team-modal').on('show.bs.modal', function (event) {
  var button = $(event.relatedTarget);
  var studyEmail = button.data('email');
  var trialId = button.data('trial-id');
  var modal = $(this);
  // pass some trial attributes from the search results into the modal
  modal.find('.study-email').text(studyEmail).attr('href', 'mailto:' + studyEmail + "?bcc=" + STUDY_CONTACT_BCC);
  modal.find('#contact-study-team-modal-submit').data('trial_id', trialId).data('button', button);

  if(window.studyTeamWidget !== undefined) {
    grecaptcha.reset();
  }
});

// "Contact the Study Team" form handler
$('#contact-study-team-modal-submit').on('click', function (event) {
  var $this = $(this),
      trial_id = $this.data('trial_id'),
      parentButton = $this.data('button'),
      form = $('#contact-study-team-form');

  // reset validation messages
  form.find('.help-inline').remove();
  form.find('.form-group').removeClass('has-error');

  // grab our form inputs
  var email = form.find('.email');
  var name  = form.find('.name');
  var phone = form.find('.phone');
  var notes = form.find('.notes');
  var to    = form.find('.study-email').text();
  var captcha = form.find('#study-team-captcha');

  if(window.studyTeamWidget !== undefined) {
    var stResponse = grecaptcha.getResponse( window.studyTeamWidget )
  }

  if ($.trim(email.val())  === '') {
    email.parent().addClass('has-error');
    email.parent().append('<span class="help-inline">Please provide your email.</span>');
    email.focus();
    return false;
  }

  if ($.trim(name.val())  === '') {
    name.parent().addClass('has-error');
    name.parent().append('<span class="help-inline">Please provide your name.</span>');
    name.focus();
    return false;
  }

  if(window.studyTeamWidget !== undefined && !stResponse.length) {
    captcha.parent().append('<span class="help-inline">Please complete the captcha.</span>');
    return false;
  }

  var data = {
    id: trial_id,
    to: to,
    name: name.val(),
    email: email.val(),
    phone: phone.val(),
    notes: notes.val()
  };

  if(window.studyTeamWidget !== undefined) {
    data['g-recaptcha-response'] = stResponse;
  }

  var jqxhr = $.post("/studies/contact_team", data, function() {
    // clear the form
    $('#contact-study-team-form').trigger("reset");
    // close window
    $('#contact-study-team-modal').modal('hide');
    // tell user their email was successfully sent
    $('<div class="alert alert-success alert-dismissible" role="alert" style="margin-top:10px;"><button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>Your email has been sent!</div>')
      .insertAfter(parentButton.parent());

    // Track to analytics
    track('send', 'event', 'email_study_team', 'sent', {'trial_id':trial_id});
  })
    .fail(function() {
      // clear the form
    $('#contact-study-team-form').trigger("reset");
    // close window
    $('#contact-study-team-modal').modal('hide');
      // leave window open
      $('<div class="alert alert-danger alert-dismissible" role="alert" style="margin-top:10px;"><button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>There was a problem sending your email</div>')
        .insertAfter(parentButton.parent());
    });
});

});
