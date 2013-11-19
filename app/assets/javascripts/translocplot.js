var plot;
var hist;
TranslocPlot = function(elemid,junctions,options) {
  var self = this;
  this.chart = document.getElementById(elemid);
  this.cx = this.chart.clientWidth;
  this.cy = this.chart.clientHeight;
  this.options = options || {};
  this.options.chrthickness = 10;
  this.options.start = options.start || 1;
  this.options.end = options.end || 10000000;

  this.top = {};
  this.bot = {};

  this.padding = {
    "top": 80,
    "right": 40,
    "bottom": 10,
    "left": 50
  };

  this.size = {
    "width":  this.cx - this.padding.left - this.padding.right,
    "height": this.cy - this.padding.top  - this.padding.bottom
  };

  // x-scale
  this.x = d3.scale.linear()
      .domain([this.options.start, this.options.end])
      .range([0, this.size.width]);

  // drag x-axis logic
  this.downx = Math.NaN;

  this.cf = crossfilter(junctions);
  this.junctionsByChr = this.cf.dimension(function(j) { return j.rname; });
  this.junctionsByStrand = this.cf.dimension(function(j) { return j.strand; });

  this.top.hist = d3.layout.histogram()
    .bins(this.x.ticks(100))
    .value(function(j) {return j.junction})
    (this.junctionsByStrand.filter("+").top(Infinity));
  hist = this.top.hist;
  this.junctionsByStrand.filterAll();
  this.bot.hist = d3.layout.histogram()
    .bins(this.x.ticks(100))
    .value(function(j) {return j.junction})
    (this.junctionsByStrand.filter("-").top(Infinity));



  
  this.options.ymin = options.ymin || 0;
  this.options.ymax = options.ymax || 20;
 





  // top y-scale (inverted domain)
  this.top.y = d3.scale.linear()
      .domain([this.options.ymax, this.options.ymin])
      .nice()
      .range([0, (this.size.height-this.options.chrthickness)/2])
      .nice();

  this.bot.y = d3.scale.linear()
      .domain([this.options.ymin, this.options.ymax])
      .nice()
      .range([(this.size.height+this.options.chrthickness)/2, this.size.height])
      .nice();

  // drag y-axis logic
  this.downy = Math.NaN;

  this.dragged = this.selected = null;

  this.top.line = d3.svg.line()
      .x(function(d,i) { return this.x(this.top.points[i].x); })
      .y(function(d,i) { return this.top.y(this.top.points[i].y); });

  this.bot.line = d3.svg.line()
      .x(function(d,i) { return this.x(this.bot.points[i].x); })
      .y(function(d,i) { return this.bot.y(this.bot.points[i].y); });

  this.top.points = this.top.hist.map(function(d) {return {x: d.x, y: d.y};});
  this.bot.points = this.bot.hist.map(function(d) {return {x: d.x, y: d.y};});
    console.log(this.top.points);
  console.log(this.bot.points);

  this.vis = d3.select(this.chart).append("svg")
      .attr("width",  this.cx)
      .attr("height", this.cy)
      .append("g")
        .attr("transform", "translate(" + this.padding.left + "," + this.padding.top + ")");

  this.top.plot = this.vis.append("rect")
      .attr("width", this.size.width)
      .attr("height", (this.size.height-this.options.chrthickness)/2)
      .style("fill", "#EEEEEE")
      .attr("pointer-events", "all")
      //.on("mousedown.drag", self.plot_drag())
      //.on("touchstart.drag", self.plot_drag())
      //this.plot.call(d3.behavior.zoom().x(this.x).y(this.y).on("zoom", this.redraw()));

  this.bot.plot = this.vis.append("rect")
      .attr("y", this.bot.y(0))
      .attr("width", this.size.width)
      .attr("height", (this.size.height-this.options.chrthickness)/2)
      .style("fill", "#EEEEEE")
      .attr("pointer-events", "all")
      //.on("mousedown.drag", self.plot_drag())
      //.on("touchstart.drag", self.plot_drag())
      //this.plot.call(d3.behavior.zoom().x(this.x).y(this.y).on("zoom", this.redraw()));

  this.vis.append("path")
          .attr("class", "line")
          //.attr("color", "steelblue")
          .attr("d", this.top.line(this.top.points));
  this.vis.append("path")
          .attr("class", "line")
          //.attr("color", "brickred")
          .attr("d", this.bot.line(this.bot.points));
};


$(document).ready(function() {
  d3.json("/get_junctions/?library_id="+gon.library.id, function(error, json) {
    if (error) return console.warn(error);
    junctions = json;
    for (var i=0;i<junctions.length;i++) {
      var j = junctions[i];
      $('table').append("<tr><td>chr"+j.rname+"</td><td>"+j.junction+"</td><td>"+j.strand+"</td></tr>");
    }
    plot = new TranslocPlot("transloc-viz", junctions, {
        "start": 0,
        "end": 10000000
    });
  });
});

