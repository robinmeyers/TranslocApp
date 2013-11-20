var plot;
var hist;
var junctions;
var tmpgraph;

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



  
  this.options.ymin = 0;
  this.options.ymax = d3.max(this.top.hist.concat(this.bot.hist),function(b){return b.y;});
  this.options.ymax = d3.max([this.options.ymax,5]) 
  console.log(this.options.ymax);




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
      .x(function(d) { return self.x(d.x); })
      .y(function(d) { return self.top.y(d.y); });



  this.bot.line = d3.svg.line()
      .x(function(d) { return self.x(d.x); })
      .y(function(d) { return self.bot.y(d.y); });



  tmpgraph = this;

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

  this.vis.append("rect")
          .attr("y", this.top.y(0))
          .attr("height", this.options.chrthickness)
          .attr("width",this.size.width)
          .attr("fill", "none")
          .attr("stroke", "black");

  this.vis.append("path")
          .attr("class", "line")
          .attr("stroke", "steelblue")
          .attr("fill", "none")
          .attr("stroke-width", 2)          
          .attr("d", this.top.line(this.top.hist));
  this.vis.append("path")
          .attr("class", "line")
          .attr("stroke", "firebrick")
          .attr("fill", "none")
          .attr("stroke-width", 2)
          .attr("d", this.bot.line(this.bot.hist));

  this.xAxis = d3.svg.axis()
                  .scale(this.x)
                  .orient("top")
                  .ticks(4);
  this.top.yAxis = d3.svg.axis()
                      .scale(this.top.y)
                      .orient("left")
                      .ticks(5)
  this.bot.yAxis = d3.svg.axis()
                      .scale(this.bot.y)
                      .orient("left")
                      .ticks(5)

  this.vis.append("g")
    .attr("class", "axis")
    .attr("transform", "translate(0,-5)")
    .call(this.xAxis)
    // .append("text")
    // .text(d3.format(".2s")(chrObj.end - chrObj.start + 1))
    // .attr("x",chrObj.xScale((chrObj.end + chrObj.start)/2))
    // .attr("y",chrObj.for.yScale(chrObj.maxY)-5);
  this.vis.append("g")
    .attr("class", "axis")
    .attr("transform", "translate(-5,0)")
    .call(this.top.yAxis);
  this.vis.append("g")
    .attr("class", "axis")
    .attr("transform", "translate(-5,0)")
    .call(this.bot.yAxis);
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

