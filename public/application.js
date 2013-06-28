$(document).ready(function(){
  player_hits();
  player_stays();
  dealer_hits();
});


function player_hits(){
  $(document).on("click", "#hit_form input", function(){
    alert("player_hits!");
    $.ajax({
      type: "POST",
      url: "/game/player/hit"
    }).done(function(msg){
      $("#game").replaceWith(msg);
    });
    return false;
  });
}

function player_stays(){
  $(document).on("click", "#stay_form input", function(){
    alert("player_stays!");
    $.ajax({
      type: "POST",
      url: "/game/player/stay"
    }).done(function(msg){
      $("#game").replaceWith(msg);
    });
    return false;
  });
}

function dealer_hits(){
  $(document).on("click", "#dealer_hit_btn input", function(){
    alert("dealer hits!");
    $.ajax({
      type: "POST",
      url: "/game/dealer/hit"
    }).done(function(msg){
      $("#game").replaceWith(msg);
    });
    return false;
  });
}