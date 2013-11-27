var plot;
var hist;
var data;
var tmpgraph;

registerKeyboardHandler = function(callback) {
  var callback = callback;
  d3.select(window).on("keydown", callback);  
};

formatBasePairs = function(bp) {
  var prefix = d3.formatPrefix(bp);
  return prefix.scale(bp).toString() + prefix.symbol + (prefix.symbol == "" ? "bp" : "b");
}

ChromosomePlot = function(elemid,data,options) {
  var self = this;
  this.chart = d3.select("#"+elemid);
  this.cx = parseInt(this.chart.style("width"));
  this.cy = parseInt(this.chart.style("height"));
  this.options = options || {};
  this.options.chrthickness = 10;
  this.options.bins = options.bins || 100;

  this.options.start = 0;
  this.options.chr = d3.select("#chrfield").property("value");
  this.options.end = data.chromosomes[0].size;

  this.top = {};
  this.bot = {};

  this.padding = {
    "top": 40,
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
          .domain([0,this.options.end-this.options.bins])
          .range([0,this.options.end-this.options.bins])
          .clamp(true);
  this.endclamp = d3.scale.linear()
          .domain([this.options.bins,this.options.end])
          .range([this.options.bins,this.options.end])
          .clamp(true);

  var histbins = self.x.ticks(this.options.bins);


  this.cf = crossfilter(data.junctions);
  this.junctionsByChr = this.cf.dimension(function(j) { return j.rname; });
  this.junctionsByStrand = this.cf.dimension(function(j) { return j.strand; });


  // this.top.hist = d3.layout.histogram()
  //   .bins(histbins)
  //   .value(function(j) {return j.junction})
  //   (this.junctionsByStrand.filter("+").top(Infinity));
  // hist = this.top.hist;
  // this.junctionsByStrand.filterAll();
  // this.bot.hist = d3.layout.histogram()
  //   .bins(histbins)
  //   .value(function(j) {return j.junction})
  //   (this.junctionsByStrand.filter("-").top(Infinity));


  


  // top y-scale (inverted domain)
  this.top.y = d3.scale.linear()
      .domain([5, 0])
      .nice()
      .range([0, (this.size.height-this.options.chrthickness)/2])
      .nice();

  this.bot.y = d3.scale.linear()
      .domain([0, 5])
      .nice()
      .range([(this.size.height+this.options.chrthickness)/2, this.size.height])
      .nice();



  this.top.line = d3.svg.line()
      .x(function(d) { return self.x(d.x); })
      .y(function(d) { return self.top.y(d.y); });



  this.bot.line = d3.svg.line()
      .x(function(d) { return self.x(d.x); })
      .y(function(d) { return self.bot.y(d.y); });



  this.vis = this.chart.append("svg")
      .attr("width",  this.cx)
      .attr("height", this.cy)
      .append("g")
        .attr("transform", "translate(" + this.padding.left + "," + this.padding.top + ")");

  this.vis.append("clipPath")                  //Make a new clipPath
    .attr("id", "chart-area")           //Assign an ID
    .append("rect")                     //Within the clipPath, create a new rect
    .attr("x", 0)                 //Set rect's position and size…
    .attr("y", 0)
    .attr("width", this.size.width)
    .attr("height", this.size.height);

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
          .attr("clip-path", "url(#chart-area)")
          .attr("stroke", "steelblue")
          .attr("fill", "none")
          .attr("stroke-width", 2);          
          // .attr("d", this.top.line(this.top.hist));

  this.vis.append("path")
          .attr("id","botpath")
          .attr("class", "line")
          .attr("clip-path", "url(#chart-area)")
          .attr("stroke", "firebrick")
          .attr("fill", "none")
          .attr("stroke-width", 2);
          // .attr("d", this.bot.line(this.bot.hist));

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

  this.sliderscale = d3.scale.log()
                      .domain([5,5])
                      .nice()
                      .range([self.top.y.range()[0]+40,self.top.y.range()[1]-20])
                      .nice()
                      .clamp(true);

  this.sliderclamp = this.sliderscale.copy()
                          .domain(this.sliderscale.range());

  this.brush = d3.svg.brush()
    .y(self.sliderscale)
    .extent([5,5])
    .on("brush", self.brushed());

  this.vis.append("g")
    .attr("class", "slider axis")
    .attr("transform", "translate(" + (self.size.width + 10) +  ",0)")
    .call(d3.svg.axis()
      .scale(self.sliderscale)
      .orient("right")
      .ticks(0)
      .tickFormat("")
      .outerTickSize(0)
      .tickSize(0));
    // .select(".domain")
    //   .attr("class", "domain slider")
    // .select(function() { return this.parentNode.appendChild(this.cloneNode(true)); })
      // .attr("class", "halo");;

  this.slider = this.vis.append("g")
    .attr("transform", "translate(" + (self.size.width + 10) +  ",0)")
    .attr("class", "slider")
    .call(self.brush);

  this.slider.selectAll(".extent,.resize")
    .remove();

  var bg = this.slider.select(".background");

  bg
    .attr("x",-10)
    .attr("width",20)
    .attr("y",Number(bg.attr("y"))-5)
    .attr("height",Number(bg.attr("height"))+10);

  this.handle = this.slider.append("circle")
    .attr("class", "handle")
    .attr("cy", self.sliderscale.range()[1])
    .attr("r", 6);

  
  this.vis.append("text")
          .text(formatBasePairs(histbins[1]-histbins[0])+" bins")
          .attr("id","binsize")
          .attr("x",this.size.width)
          .attr("y",0)
          .attr("dy","1em")
          .attr("text-anchor","end")

  
  this.redraw()();

 
};

ChromosomePlot.prototype.brushed = function() {
  var self = this;
  return function() {
    // var value = self.brush.extent()[0];
    // if (d3.event.sourceEvent) { // not a programmatic event
    //   value = self.sliderscale.invert(d3.mouse(this)[1]);
    //   self.brush.extent([value, value]);
    // }

    value = d3.mouse(this)[1];

    self.handle.attr("cy", self.sliderclamp(value));
    self.redraw()();
  }
}


ChromosomePlot.prototype.updateData = function() {
  var self = this;
  return function() {

    var histbins = self.x.ticks(self.options.bins);

    self.vis.select("text#binsize")
        .text(formatBasePairs(histbins[1]-histbins[0])+" bins");

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
  }
}

ChromosomePlot.prototype.updateX = function() {
  var self = this;
  return function() {
    var newxstart = d3.round(self.startclamp(self.x.domain()[0])),
        newxend = d3.round(self.endclamp(self.x.domain()[1]));
    
    self.x.domain([ newxstart, newxend ]);

    d3.select("#startfield")
      .property("value",self.x.domain()[0]);
    d3.select("#endfield")
      .property("value",self.x.domain()[1]);

    self.vis.select("g.axis.x")
      .call(self.xAxis)
  }
}

ChromosomePlot.prototype.updateY = function() {
  var self = this;
  return function () {

    var largestbin = d3.max(self.top.hist.concat(self.bot.hist), function(j) {return j.y});
    self.sliderscale.domain([5,d3.max([5,largestbin/0.9])]);

    var newymax = self.sliderscale.invert(self.handle.attr("cy"));
    self.top.y.domain([newymax,0]);
    self.bot.y.domain([0,newymax]);

    self.vis.select("g.axis.top.y")
      .call(self.top.yAxis);

    self.vis.select("g.axis.bot.y")
      .call(self.bot.yAxis);


  }
}

ChromosomePlot.prototype.redraw = function() {
  var self = this;
  return function() {

    self.updateX()();

    self.updateData()();

    self.updateY()();


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

function initViewer() {
  var chr = d3.select("#chrfield").property("value");
  var url = "/get_library_data/?library_id="+gon.library.id;
  if (chr) {
   url += "&chr="+chr;
    d3.json(url, function(error, json) {
      if (error) return console.warn(error);
      data = json;
      $('tbody').empty();
      for (var i=0;i<data.junctions.length;i++) {
        var j = data.junctions[i];
        $('tbody').append("<tr><td>"+j.rname+"</td><td>"+j.junction+"</td><td>"+j.strand+"</td></tr>");
      }
      $('#transloc-viz').empty();
      plot = new ChromosomePlot("transloc-viz", data, {});
    });
  } else {
    d3.json(url, function(error, json) {
      if (error) return console.warn(error);
      data = json;
    });
  }
}

$(document).ready(function() {
  initViewer();
});

