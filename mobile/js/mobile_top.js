$(document).ready(function(){
      $(".hidden_ul").hide();
      // $("ul > li:first-child a").next().show();
      $("ul.ham li.ham_li").click(function(){
        $(this).toggleClass('border').children().next().slideToggle(150);
        // $(this).next().slideDown(300);
        $("ul.ham li.ham_li").not(this).removeClass('border').children().next().slideUp(150);
        return false;
      });
      $("ul.ham li.ham_li").eq(0).trigger("click");
      $("ul.ham li.ham_li .hidden_ul li").click(function(e){
      e.stopPropagation();
      });
    });