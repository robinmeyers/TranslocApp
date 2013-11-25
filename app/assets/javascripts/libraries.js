var appCanvas = {w: 940, h: 560, margin: {top: 80, right: 40, bottom: 10, left: 50} };
var junctions;
var cf;


function drawChromosome(svg,chrObj) {

  svg.append("rect")
      .datum(chrObj.end)
      .attr({ x: chrObj.xScale(0),
              y: chrObj.for.yScale(0),
              width: function(d) {return chrObj.xScale(d);},
              height: chrObj.thickness,
              fill: "white",
              stroke: "black"});

  chrObj.for.line = d3.svg.line()
    .x(function(d) { return chrObj.xScale(d.x); })
    .y(function(d) { return chrObj.for.yScale(d.y); });
  svg.append("path")
      .datum(chrObj.for.histdata)
      .attr({ d: chrObj.for.line,
              fill: "none",
              stroke: "steelblue",
              'stroke-width': 2});
  chrObj.rev.line = d3.svg.line()
    .x(function(d) { return chrObj.xScale(d.x); })
    .y(function(d) { return chrObj.rev.yScale(d.y); });
  svg.append("path")
    .datum(chrObj.rev.histdata)
    .attr({ d: chrObj.rev.line,
            fill: "none",
            stroke: "firebrick",
            'stroke-width': 2});

  svg.append("g")
    .attr("class", "axis")
    .attr("transform", "translate(0,-5)")
    .call(chrObj.xAxis)
    .append("text")
    .text(d3.format(".2s")(chrObj.end - chrObj.start + 1))
    .attr("x",chrObj.xScale((chrObj.end + chrObj.start)/2))
    .attr("y",chrObj.for.yScale(chrObj.maxY)-5);
  svg.append("g")
    .attr("class", "axis")
    .attr("transform", "translate(-5,0)")
    .call(chrObj.for.yAxis);
  svg.append("g")
    .attr("class", "axis")
    .attr("transform", "translate(-5,0)")
    .call(chrObj.rev.yAxis);





}


function drawViz(svg) {
  cf = crossfilter(junctions);
  var junctionsByChr = cf.dimension(function(j) { return j.rname; });
  var junctionsByStrand = cf.dimension(function(j) { return j.strand; });

  var w = appCanvas.w - appCanvas.margin.left - appCanvas.margin.right,
      h = appCanvas.h - appCanvas.margin.top - appCanvas.margin.bottom;

  var chr = "1";

  var chrObj = { size: 10000000,
                 thickness: 10,
                 for: {}, rev: {}};

  chrObj.start = 1;
  chrObj.end = chrObj.size;

  chrObj.xScale = d3.scale.linear()
                  .domain([chrObj.start,chrObj.end])
                  .range([0,w]);

  chrObj.xAxis = d3.svg.axis()
                    .scale(chrObj.xScale)
                    .orient("top")
                    .tickValues([chrObj.start,chrObj.end])
                    .ticks(10)

  
  // junctionsByChr.filter(chr);
  
  chrObj.for.histdata = d3.layout.histogram()
    .bins(chrObj.xScale.ticks(100))
    (junctionsByStrand.filter("+").top(Infinity).map(function(j){return j.junction;}));
  junctionsByStrand.filterAll();
  chrObj.rev.histdata = d3.layout.histogram()
    .bins(chrObj.xScale.ticks(100))
    (junctionsByStrand.filter("-").top(Infinity).map(function(j){return j.junction;}));

  chrObj.maxY = d3.max(chrObj.for.histdata.concat(chrObj.rev.histdata),function(b){return b.y});
  chrObj.maxY = d3.max([chrObj.maxY,5]);

  chrObj.for.yScale = d3.scale.linear()
                              .domain([0,chrObj.maxY])
                              .range([h/2-chrObj.thickness/2,0]);
  chrObj.for.yAxis = d3.svg.axis()
                        .scale(chrObj.for.yScale)
                        .orient("left")
                        .ticks(5)

  chrObj.rev.yScale = d3.scale.linear()
                              .domain([0,chrObj.maxY])
                              .range([h/2+chrObj.thickness/2,h]);
  chrObj.rev.yAxis = d3.svg.axis()
                        .scale(chrObj.rev.yScale)
                        .orient("left")
                        .ticks(5);
  
  drawChromosome(svg,chrObj);

};

function initViz() {
  
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