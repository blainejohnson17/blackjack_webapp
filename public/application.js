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
  $(document).on("click", '#new_player_form input[type="submit"]', function() {
    var serializedData = $('#new_player_form').serialize();
    $.ajax({
      type: 'POST',
      url: '/new_player',
      data: serializedData
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });
    return false;
  });
}

function bet_amount() {
  $(document).on("click", "ul#chips li a", function() {
    var amount = $(this).text();
    amount = amount.substring(1, amount.length);
    $.ajax({
    type: 'GET',
    url: '/bet_amount',
    data: { bet_add: amount }
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });
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
      var $target = $(".cards");
      $target.hide().css( "left", "600px" ).show().animate({ left: "10px" }, 300);
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
      var $target = $(".cards").children();
      while( $target.length ) {
        $target = $target.children();
      }
      $target.end().parent().parent().hide().css( "left", "600px" ).show().animate({ left: "10px" }, 300);
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
      var $target = $(".cards:first").children();
      while( $target.length ) {
        $target = $target.children();
      }
      $target.end().parent().parent().hide().css( "left", "600px" ).show().animate({ left: "10px" }, 300);
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