(function(){
var t;

function size(animate){
  if (animate == undefined){
    animate = false;
  }
  clearTimeout(t);
  t = setTimeout(function(){
    $("canvas").each(function(i,el){
      $(el).attr({
        "width":$(el).parent().width(),
        "height":$(el).parent().outerHeight()
      });
    });
    redraw(animate);
    var m = 0;
    $(".card").height("");
    $(".card").each(function(i,el){ m = Math.max(m,$(el).height()); });
    $(".card").height(m);
  }, 30);
}
$(window).on('resize', function(){ size(false); });


function redraw(animation){
  $.getJSON("dashboardData.json", function (json) {
    console.log('JSON: ', json);
    var covData = json['data']['coverage'];
    // set % coverage
    document.getElementById("covPercent").innerHTML = covData['total_percent_coverage'] + '%';

    var options = {animation:{}};
    if (!animation){
      options.animation.animateRotate = false;
    } else {
      options.animation.animateRotate = true;
    }
    var data = {
      datasets:[{
        data: [
        covData['total_covered_lines'],
        covData['total_missed_lines'],
        ],
        backgroundColor: [
        "#50AE54",
        "#F2453D"
        ]
      }],
      labels: [
        "lines covered", 
        "lines missed",
      ]
    };

    var config = {type: 'doughnut', data: data, options: options};
    var canvas = document.getElementById("cov");
    var ctx = canvas.getContext("2d");
    var doughnut = new Chart(ctx, config);
  });
}
size(true);

}());