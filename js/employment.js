(function () {

var contentWidth = document.getElementById('content').clientWidth;

var plotWidth;
  if (contentWidth >= 500) {plotWidth = contentWidth/5.05;} 
  else { plotWidth = contentWidth/2.05; }

  var elem = document.getElementById('countrySelect'); // Create variable element that stores value from menu 
  if(elem){ elem.addEventListener("load", graphState(elem.value), false)}; // on load, graph default value 
  if(elem){ elem.addEventListener("change", onSelectChange, false)}; // on change, run 'onSelectChange function' that graphs new country 

  function onSelectChange(){
    d3.selectAll('svg').remove();
    var value = this.value;
    graphState(value);
  }

  var margin = {top: 20, right: 20, bottom: 20, left: 20},
      width = plotWidth - margin.left - margin.right,
      height = 180 - margin.top - margin.bottom;

  var x = d3.scaleLinear()
            .range([0, width])
            .domain([1990,2016]); 

  var y = d3.scaleLinear()
          .domain([0, 45])
          .range([height, 10]);

  function graphState(countryName) {

    d3.csv("data/employment.csv", type, function(error, data) {
      if (error) throw error;

      data = data.filter(function (d) { return d.country == countryName } );

      var sectors = d3.nest()
          .key(function(d) { return d.sector; })
          .entries(data);

      var svg = d3.select("#graphEmployment").selectAll("svg")
          .data(sectors)
          .enter().append("svg")
          .attr("width", width + margin.left + margin.right)
          .attr("height", height + margin.top + margin.bottom)
          .append("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
          .each(multiple);

      svg.append("text")
          .attr("x", width/2)
          .attr("y", 0)
          .attr('text-anchor', 'middle')
          .text(function(d) { return d.key; });

      // Append x axis 
      svg.append("g")
         .attr('class', 'xaxis')
         .attr("transform", "translate(0," + height + ")")
         .call(d3.axisBottom(x)
         .tickFormat(d3.format(".0f"))
         .tickValues([1990, 2000, 2010]));

      // Append y axis
      svg.append("g")
         .attr('class', 'yaxis')
         .call(d3.axisLeft(y)
         .ticks(7));

    });

    function multiple(sector) {
      var svg = d3.select(this);

      var line = d3.line()
          .x(function(d) { return x(d.year); })
          .y(function(d) { return y(d.value); });

      svg.append("path")
          .attr("class", "line")
          .attr("d", line(sector.values));
    }

    function type(d) {
      d.country = d.Country;
      d.year = +d.Year;
      d.sector = d.Sector;
      d.value = +d.Value;
      return d;
    }

};
})();