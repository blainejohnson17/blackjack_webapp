$(document).ready(function(){
    new_player();
    bet_amount();
    bet();
    rebet();
    hit();
    stay();
    play_again();
    arc();
});

function new_player() {
  $(document).on("click", "form#new_player_form input", function() {
    $.ajax({
      type: 'POST',
      url: '/new_player'
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });
    return false;
  });
}

function bet_amount() {
  $(document).on("click", "ul#chips li a", function() {
    var amount=$(this).text();
    var state=$.cookie('state');
    if (state == 1) {
      $.ajax({
      type: 'GET',
      url: '/bet_amount',
      data: { bet_add: amount }
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });
    }
    return false;
  });
}

function bet() {
  $(document).on("click", "form#bet_form input", function() {
    $.ajax({
      type: 'POST',
      url: '/bet'
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });
    return false;
  });
}

function rebet() {
  $(document).on("click", "form#rebet_form input", function() {
    $.ajax({
      type: 'POST',
      url: '/rebet'
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });
    return false;
  });
}

function hit() {
  $(document).on("click", "form#hit_form input", function() {
    $.ajax({
      type: 'POST',
      url: '/game/player/hit'
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });
    return false;
  });
}

function stay() {
  $(document).on("click", "form#stay_form input", function() {
    $.ajax({
      type: 'POST',
      url: '/game/player/stay'
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });
    return false;
  });
}

function play_again() {
  $(document).on("click", "#again", function() {
    $.ajax({
      type: 'GET',
      url: '/again'
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });
    return false;
  });
}

function arc() {
  $(".arc-text").arctext({radius: 500, dir: -1});
}