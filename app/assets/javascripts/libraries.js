var appCanvas = {w: 940, h: 560, margin: {top: 10, right: 20, bottom: 10, left: 20} };
var junctions;
var cf;
var chrObj;

var drawViz = function(svg) {
  cf = crossfilter(junctions);
  var junctionsByChr = cf.dimension(function(j) { return j.rname; });
  var junctionsByStrand = cf.dimension(function(j) { return j.strand; });

  var w = appCanvas.w - appCanvas.margin.left - appCanvas.margin.right,
      h = appCanvas.h - appCanvas.margin.top - appCanvas.margin.bottom;

  var chr = "1";

  var chrsize = 10000000;
  var chrthickness = 10;

  var xScale = d3.scale.linear()
                  .domain([0,chrsize])
                  .range([0,w]);
  var yScale = d3.scale.linear()
                  .domain([-h/2,h/2])
                  .range([h,0]);
  svg.append("rect")
      .datum(chrsize)
      .attr({ x: xScale(0),
              y: yScale(chrthickness/2),
              width: function(d) {return xScale(d);},
              height: chrthickness,
              fill: "white",
              stroke: "black"});

  chrObj = {for: {}, rev: {}};
  junctionsByChr.filter(chr);
  
  chrObj.for.histdata = d3.layout.histogram()
    .bins(xScale.ticks(100))
    (junctionsByStrand.filter("+").top(Infinity).map(function(j){return j.junction;}));
  junctionsByStrand.filterAll();
  chrObj.rev.histdata = d3.layout.histogram()
    .bins(xScale.ticks(100))
    (junctionsByStrand.filter("-").top(Infinity).map(function(j){return j.junction;}));
  chrObj.xScale = xScale;
  var maxY = d3.max(chrObj.for.histdata.concat(chrObj.rev.histdata),function(b){return b.y});
  chrObj.for.yScale = d3.scale.linear()
                              .domain([0,d3.max([5,maxY])])
                              .range([yScale(chrthickness/2),0]);
  chrObj.rev.yScale = d3.scale.linear()
                              .domain([0,d3.max([5,maxY])])
                              .range([yScale(-chrthickness/2),h]);
  
  chrObj.for.line = d3.svg.line()
    .x(function(d) { return chrObj.xScale(d.x); })
    .y(function(d) { return chrObj.for.yScale(d.y); });
  svg.append("path")
      .datum(chrObj.for.histdata)
      .attr({ d: chrObj.for.line,
              fill: "none",
              stroke: "steelblue"});
  chrObj.rev.line = d3.svg.line()
    .x(function(d) { return chrObj.xScale(d.x); })
    .y(function(d) { return chrObj.rev.yScale(d.y); });
    svg.append("path")
      .datum(chrObj.rev.histdata)
      .attr({ d: chrObj.rev.line,
              fill: "none",
              stroke: "firebrick"});

};

var initViz = function() {
  
  var svg = d3.select("#transloc-viz").append("svg")
              .attr("width", appCanvas.w)
              .attr("height", appCanvas.h)
  
  svg.append("rect")
      .attr({ fill: "none",
              stroke: "lightgrey",
              x: 0,
              y: 0,
              width: appCanvas.w,
              height: appCanvas.h});

  svg = svg.append("g")
            .attr("transform", "translate(" + appCanvas.margin.left + "," + appCanvas.margin.top + ")");

  drawViz(svg);


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