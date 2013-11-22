var plot;
var hist;
var junctions;
var tmpgraph;

registerKeyboardHandler = function(callback) {
  var callback = callback;
  d3.select(window).on("keydown", callback);  
};

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
      .on("mousedown.drag", self.plot_drag())
      //.on("touchstart.drag", self.plot_drag())
      this.top.plot.call(d3.behavior.zoom().x(this.x).on("zoom", this.redraw()));

  this.bot.plot = this.vis.append("rect")
      .attr("y", this.bot.y(0))
      .attr("width", this.size.width)
      .attr("height", (this.size.height-this.options.chrthickness)/2)
      .style("fill", "#EEEEEE")
      .attr("pointer-events", "all")
      .on("mousedown.drag", self.plot_drag())
      //.on("touchstart.drag", self.plot_drag())
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

  d3.select(this.chart)
      .on("mousemove.drag", self.mousemove())
      .on("mouseup.drag",   self.mouseup())

  this.redraw()();

 
};

TranslocPlot.prototype.plot_drag = function() {
  var self = this;
  return function() {
    registerKeyboardHandler(self.keydown());
    d3.select('body').style("cursor", "move");
    // if (d3.event.altKey) {
    //   var p = d3.svg.mouse(self.vis.node());
    //   var newpoint = {};
    //   newpoint.x = self.x.invert(Math.max(0, Math.min(self.size.width,  p[0])));
    //   // newpoint.y = self.y.invert(Math.max(0, Math.min(self.size.height, p[1])));
    //   self.points.push(newpoint);
    //   self.points.sort(function(a, b) {
    //     if (a.x < b.x) { return -1 };
    //     if (a.x > b.x) { return  1 };
    //     return 0
    //   });
    //   self.selected = newpoint;
    //   self.update();
    //   d3.event.preventDefault();
    //   d3.event.stopPropagation();
    // }    
  }
};

TranslocPlot.prototype.update = function() {
  var self = this;
  var toplines = this.vis.select("#toppath").attr("d", this.top.line(this.top.hist));
  var botlines = this.vis.select("#botpath").attr("d", this.bot.line(this.bot.hist));
        
  // var circle = this.vis.select("svg").selectAll("circle")
  //     .data(this.points, function(d) { return d; });

  // circle.enter().append("circle")
  //     .attr("class", function(d) { return d === self.selected ? "selected" : null; })
  //     .attr("cx",    function(d) { return self.x(d.x); })
  //     .attr("cy",    function(d) { return self.y(d.y); })
  //     .attr("r", 10.0)
  //     .style("cursor", "ns-resize")
  //     .on("mousedown.drag",  self.datapoint_drag())
  //     .on("touchstart.drag", self.datapoint_drag());

  // circle
  //     .attr("class", function(d) { return d === self.selected ? "selected" : null; })
  //     .attr("cx",    function(d) { 
  //       return self.x(d.x); })
  //     .attr("cy",    function(d) { return self.y(d.y); });

  // circle.exit().remove();

  if (d3.event && d3.event.keyCode) {
    d3.event.preventDefault();
    d3.event.stopPropagation();
  }
}


TranslocPlot.prototype.mousemove = function() {
  var self = this;
  return function() {
    // var p = d3.svg.mouse(self.vis[0][0]),
        // t = d3.event.changedTouches;
    
    if (self.dragged) {
      // self.dragged.y = self.y.invert(Math.max(0, Math.min(self.size.height, p[1])));
      self.update();
    };
    if (!isNaN(self.downx)) {
      d3.select('body').style("cursor", "ew-resize");
      var rupx = self.x.invert(p[0]),
          xaxis1 = self.x.domain()[0],
          xaxis2 = self.x.domain()[1],
          xextent = xaxis2 - xaxis1;
      if (rupx != 0) {
        var changex, new_domain;
        changex = self.downx / rupx;
        new_domain = [xaxis1, xaxis1 + (xextent * changex)];
        self.x.domain(new_domain);
        self.redraw()();
      }
      d3.event.preventDefault();
      d3.event.stopPropagation();
    };
    // if (!isNaN(self.downy)) {
    //   d3.select('body').style("cursor", "ns-resize");
    //   var rupy = self.y.invert(p[1]),
    //       yaxis1 = self.y.domain()[1],
    //       yaxis2 = self.y.domain()[0],
    //       yextent = yaxis2 - yaxis1;
    //   if (rupy != 0) {
    //     var changey, new_domain;
    //     changey = self.downy / rupy;
    //     new_domain = [yaxis1 + (yextent * changey), yaxis1];
    //     self.y.domain(new_domain);
    //     self.redraw()();
    //   }
    //   d3.event.preventDefault();
    //   d3.event.stopPropagation();
    // }
  }
};

TranslocPlot.prototype.mouseup = function() {
  var self = this;
  return function() {
    document.onselectstart = function() { return true; };
    d3.select('body').style("cursor", "auto");
    d3.select('body').style("cursor", "auto");
    if (!isNaN(self.downx)) {
      self.redraw()();
      self.downx = Math.NaN;
      d3.event.preventDefault();
      d3.event.stopPropagation();
    };
    // if (!isNaN(self.downy)) {
    //   self.redraw()();
    //   self.downy = Math.NaN;
    //   d3.event.preventDefault();
    //   d3.event.stopPropagation();
    // }
    if (self.dragged) { 
      self.dragged = null 
    }
  }
}

TranslocPlot.prototype.keydown = function() {
  var self = this;
  return function() {
    if (!self.selected) return;
    // switch (d3.event.keyCode) {
    //   case 8: // backspace
    //   case 46: { // delete
    //     var i = self.points.indexOf(self.selected);
    //     self.points.splice(i, 1);
    //     self.selected = self.points.length ? self.points[i > 0 ? i - 1 : 0] : null;
    //     self.update();
    //     break;
    //   }
    // }
  }
};

TranslocPlot.prototype.redraw = function() {
  var self = this;
  return function() {
    var tx = function(d) { 
      return "translate(" + self.x(d) + ",0)"; 
    },
    ty = function(d) { 
      return "translate(0," + self.y(d) + ")";
    },
    stroke = function(d) { 
      return d ? "#ccc" : "#666"; 
    };
    self.xAxis = d3.svg.axis()
                  .scale(self.x)
                  .orient("top")
                  .ticks(4);
    self.top.yAxis = d3.svg.axis()
                        .scale(self.top.y)
                        .orient("left")
                        .ticks(5);
    self.bot.yAxis = d3.svg.axis()
                        .scale(self.bot.y)
                        .orient("left")
                        .ticks(5);

    self.vis.append("g")
      .attr("class", "axis")
      .attr("transform", "translate(0,-5)")
      .call(self.xAxis)
      // .append("text")
      // .text(d3.format(".2s")(chrObj.end - chrObj.start + 1))
      // .attr("x",chrObj.xScale((chrObj.end + chrObj.start)/2))
      // .attr("y",chrObj.for.yScale(chrObj.maxY)-5);
    self.vis.append("g")
      .attr("class", "axis")
      .attr("transform", "translate(-5,0)")
      .call(self.top.yAxis);
    self.vis.append("g")
      .attr("class", "axis")
      .attr("transform", "translate(-5,0)")
      .call(self.bot.yAxis);

    
    self.top.plot.call(d3.behavior.zoom().x(self.x).on("zoom", self.redraw()));
    self.bot.plot.call(d3.behavior.zoom().x(self.x).on("zoom", self.redraw()));
    self.update();    
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

