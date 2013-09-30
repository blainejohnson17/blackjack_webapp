$(document).ready(function(){
    bet();
});

function bet() {
  $(document).on("click", "ul.chips li a", function() {
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