// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require jquery
//= require jquery_ujs
//= require jquery.turbolinks
//= require turbolinks
//= require bootstrap
//= require_tree .
// = require data-confirm-modal


$(document).on('turbolinks:load', function(){
  var wideImg = {
    
    close: function(){
      $(".wide-img-close").on("click", function(){
        console.log("none");
        $.when(
          $(".wide-img").animate({"opacity": 0}),
          $("#display").animate({"opacity": 0})
        ).done(function(){
          $(".wide-img").remove();
          $("#display").css("display", "none");
        });
      });
    }
  }
  
  $(".wide-img-hover").on("click", function(){
    var srcImg = $(this).attr("src");
    
    var wideImgBox = `<div class="wide-img">
                        <img src="${srcImg}">  
                        <div class="wide-img-close">
                          <p class="btn-hover"><i class="fa fa-remove" aria-hidden="true"></i></p>
                        </div>
                      </div>`

    $.when(
      $("#display").css("display", "")
    ).done(function(){
      $("#display").animate({"opacity": .8});
      $("#display").after(wideImgBox);
      wideImg.close();
    });
  });
  wideImg.close();
 
});


// 通信中の表示
function stateLoading(){
  $(function(){
    $("#display").css('opacity','.3');
    $("#display").css('display','block');
    $("#loading").css('opacity','1');
    $("#loading").css('display','block');
  }); 
}

function doneLoading(){
  $(function(){
    $("#display").css('opacity','0');
    $("#display").css('display','none');
    $("#loading").css('opacity','0');
    $("#loading").css('display','none');
  });
}


// flexble textarea
$(function() {
  var $textarea = $('#textarea');
  var lineHeight = parseInt($textarea.css('lineHeight'));
  $textarea.on('input', function(evt) {
    var lines = ($(this).val() + '\n').match(/\n/g).length;
    $(this).height(lineHeight * lines);
  });
});


// flexble font-size
$(function() {
  var maxCount = 0;
  $("#flex-font > p").each(function(index, element){
    console.log(index + ':' + $(element).text());
    var count = $(element).text().length;
    if (maxCount < count){
      maxCount = count;
    }
  });
  console.log(maxCount);
  if(maxCount >= 30){
    $("#flex-font > p").css("font-size", "1.4rem");
  }else if(maxCount >= 24){
    $("#flex-font > p").css("font-size", "1.6rem");
  } 
});
