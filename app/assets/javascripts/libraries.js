var junctions;
$(document).ready(function() {
  $.ajax({
    type: "GET",
    url: document.URL,
    dataType: "json",
    success: function (data) {
      for (var i=0;i<data.length;i++) {
        var j = data[i];
        $('table').append("<tr><td>chr"+j.rname+"</td><td>"+j.junction+"</td><td>"+j.strand+"</td></tr>");
      }
      junctions = data;
    }
  });
});