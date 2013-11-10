var junctions;

var initViz = function() {
  var w = 940;
  var h = 500;
  var barPadding = 1;
  var dataset = Array.apply(null, new Array(20)).map(Number.prototype.valueOf,0).map(Math.random);
  var svg = d3.select("#transloc-viz")
              .append("svg");
  svg.selectAll("rect")
      .data(dataset)
      .enter()
      .append("rect")
      .attr("x", function(d, i) {
        return i * (w / dataset.length);
      })
      .attr("y", function(d) {
        return h - h * d;
      })
      .attr("width", w / dataset.length - barPadding)
      .attr("height", function(d) {
        return h * d; 
      })
      .attr("fill",function(d) {return "rgb(0,0,"+Math.floor(d*255)+")"});
};


$(document).ready(function() {
  d3.json("/get_junctions/?library_id="+gon.library.id, function(error, json) {
    if (error) return console.warn(error);
    junctions = json;
    for (var i=0;i<junctions.length;i++) {
      var j = junctions[i];
      $('table').append("<tr><td>chr"+j.rname+"</td><td>"+j.junction+"</td><td>"+j.strand+"</td></tr>");
    }
    initViz();
  });
});