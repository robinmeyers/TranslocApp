var plot;
var hist;
var junctions;
var tmpgraph;

registerKeyboardHandler = function(callback) {
  var callback = callback;
  d3.select(window).on("keydown", callback);  
};

formatBasePairs = function(bp) {
  var prefix = d3.formatPrefix(bp);
  return prefix.scale(bp).toString() + prefix.symbol + (prefix.symbol == "" ? "bp" : "b");
}

TranslocPlot = function(elemid,junctions,options) {
  var self = this;
  this.chart = document.getElementById(elemid);
  this.cx = this.chart.clientWidth;
  this.cy = this.chart.clientHeight;
  this.options = options || {};
  this.options.chrthickness = 10;
  this.options.start = options.start || 0;
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
      .nice()
      .range([0, this.size.width])
      .nice();

  this.startclamp = d3.scale.linear()
          .domain([0,10000000-100])
          .range([0,10000000-100])
          .clamp(true);
  this.endclamp = d3.scale.linear()
          .domain([100,10000000])
          .range([100,10000000])
          .clamp(true);

  var histbins = self.x.ticks(100);


  // drag x-axis logic
  this.downx = Math.NaN;

  this.cf = crossfilter(junctions);
  this.junctionsByChr = this.cf.dimension(function(j) { return j.rname; });
  this.junctionsByStrand = this.cf.dimension(function(j) { return j.strand; });




  this.top.hist = d3.layout.histogram()
    .bins(histbins)
    .value(function(j) {return j.junction})
    (this.junctionsByStrand.filter("+").top(Infinity));
  hist = this.top.hist;
  this.junctionsByStrand.filterAll();
  this.bot.hist = d3.layout.histogram()
    .bins(histbins)
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
      // .on("mousedown.drag", self.plot_drag())
      this.top.plot.call(d3.behavior.zoom().x(this.x).on("zoom", this.redraw()));


  this.bot.plot = this.vis.append("rect")
      .attr("y", this.bot.y(0))
      .attr("width", this.size.width)
      .attr("height", (this.size.height-this.options.chrthickness)/2)
      .style("fill", "#EEEEEE")
      .attr("pointer-events", "all")
      // .on("mousedown.drag", self.plot_drag())
      this.bot.plot.call(d3.behavior.zoom().x(this.x).on("zoom", this.redraw()));


  this.vis.append("rect")
          .attr("y", this.top.y(0))
          .attr("height", this.options.chrthickness)
          .attr("width",this.size.width)
          .attr("fill", "none")
          .attr("stroke", "black");

  this.vis.append("path")
          .attr("id","toppath")
          .attr("class", "line")
          .attr("stroke", "steelblue")
          .attr("fill", "none")
          .attr("stroke-width", 2)          
          .attr("d", this.top.line(this.top.hist));
  this.vis.append("path")
          .attr("id","botpath")
          .attr("class", "line")
          .attr("stroke", "firebrick")
          .attr("fill", "none")
          .attr("stroke-width", 2)
          .attr("d", this.bot.line(this.bot.hist));

  this.xAxis = d3.svg.axis()
                  .scale(this.x)
                  .orient("top")
                  .outerTickSize(0)
                  .ticks(8);
  this.top.yAxis = d3.svg.axis()
                      .scale(this.top.y)
                      .orient("left")
                      .ticks(5);
  this.bot.yAxis = d3.svg.axis()
                      .scale(this.bot.y)
                      .orient("left")
                      .ticks(5);
  this.vis.append("g")
    .attr("class","axis x")
    .attr("transform", "translate(0,-5)")
    .call(this.xAxis)
    // .append("text")
    // .text(d3.format(".2s")(chrObj.end - chrObj.start + 1))
    // .attr("x",chrObj.xScale((chrObj.end + chrObj.start)/2))
    // .attr("y",chrObj.for.yScale(chrObj.maxY)-5);
  this.vis.append("g")
    .attr("class", "axis top y")
    .attr("transform", "translate(-5,0)")
    .call(this.top.yAxis);
  this.vis.append("g")
    .attr("class","axis bot y")
    .attr("transform", "translate(-5,0)")
    .call(this.bot.yAxis);

  this.vis.append("text")
          .text(formatBasePairs(histbins[1]-histbins[0])+" bins")
          .attr("id","binsize")
          .attr("x",this.size.width)
          .attr("y",0)
          .attr("dy","1em")
          .attr("text-anchor","end")

  // d3.select(this.chart)
  //     .on("mousemove.drag", self.mousemove())
  //     .on("mouseup.drag",   self.mouseup())

  this.redraw()();

 
};

// TranslocPlot.prototype.plot_drag = function() {
//   var self = this;
//   return function() {
//     registerKeyboardHandler(self.keydown());
//     d3.select('body').style("cursor", "move");  
//   }
// };

// TranslocPlot.prototype.update = function() {
//   var self = this;
  

//   if (d3.event && d3.event.keyCode) {
//     d3.event.preventDefault();
//     d3.event.stopPropagation();
//   }
// }


// TranslocPlot.prototype.mousemove = function() {
//   var self = this;
//   return function() {
//     var p = d3.mouse(self.vis[0][0]);
//         // t = d3.event.changedTouches;
    
//     if (self.dragged) {
//       self.update();
//     };
//     if (!isNaN(self.downx)) {
//       d3.select('body').style("cursor", "ew-resize");
//       var rupx = self.x.invert(p[0]),
//           xaxis1 = self.x.domain()[0],
//           xaxis2 = self.x.domain()[1],
//           xextent = xaxis2 - xaxis1;
//       if (rupx != 0) {
//         var changex, new_domain;
//         changex = self.downx / rupx;
//         new_domain = [xaxis1, xaxis1 + (xextent * changex)];
//         self.x.domain(new_domain);
//         self.redraw()();
//       }
//       d3.event.preventDefault();
//       d3.event.stopPropagation();
//     };
//   }
// };

// TranslocPlot.prototype.mouseup = function() {
//   var self = this;
//   return function() {
//     document.onselectstart = function() { return true; };
//     d3.select('body').style("cursor", "auto");
//     d3.select('body').style("cursor", "auto");
//     if (!isNaN(self.downx)) {
//       self.redraw()();
//       self.downx = Math.NaN;
//       d3.event.preventDefault();
//       d3.event.stopPropagation();
//     };
//     if (self.dragged) { 
//       self.dragged = null 
//     }
//   }
// }

// TranslocPlot.prototype.keydown = function() {
//   var self = this;
//   return function() {
//     if (!self.selected) return;

//   }
// };

TranslocPlot.prototype.redraw = function() {
  var self = this;
  return function() {

    var newxstart = d3.round(self.startclamp(self.x.domain()[0])),
        newxend = d3.round(self.endclamp(self.x.domain()[1]));
    
    self.x.domain([ newxstart, newxend ]);

    d3.select("#startfield")
      .attr("value",self.x.domain()[0]);
    d3.select("#endfield")
      .attr("value",self.x.domain()[1]);

    self.vis.select("g.axis.x")
      .call(self.xAxis)


    var histbins = self.x.ticks(100);

    self.junctionsByStrand.filterAll();
    self.top.hist = d3.layout.histogram()
      .bins(histbins)
      .value(function(j) {return j.junction})
      .range([histbins[0],histbins[histbins.length-1]])
      (self.junctionsByStrand.filter("+").top(Infinity));
    hist = self.top.hist;
    self.junctionsByStrand.filterAll();
    self.bot.hist = d3.layout.histogram()
      .bins(histbins)
      .value(function(j) {return j.junction})
      .range([histbins[0],histbins[histbins.length-1]])
      (self.junctionsByStrand.filter("-").top(Infinity));
    
    self.options.ymax = d3.max(self.top.hist.concat(self.bot.hist),function(b){return b.y;});
    self.options.ymax = d3.max([self.options.ymax,5])

    self.top.y.domain([self.options.ymax,self.options.ymin]);
    self.bot.y.domain([self.options.ymin,self.options.ymax]);

    self.vis.select("g.axis.top.y")
      .call(self.top.yAxis);

    self.vis.select("g.axis.bot.y")
      .call(self.bot.yAxis);

    self.vis.select("text#binsize")
        .text(formatBasePairs(histbins[1]-histbins[0])+" bins");

    var toplines = self.vis.select("#toppath")
                      .attr("d", self.top.line(self.top.hist));
    var botlines = self.vis.select("#botpath")
                      .attr("d", self.bot.line(self.bot.hist));

    var xrange = self.x.domain()[1]-self.x.domain()[0];

    self.top.plot.call(d3.behavior.zoom()
            .scaleExtent([0,xrange/100])
            .x(self.x)
            .on("zoom", self.redraw()));
    self.bot.plot.call(d3.behavior.zoom()
            .scaleExtent([0,xrange/100])
            .x(self.x)
            .on("zoom", self.redraw()));
  }  
}

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

