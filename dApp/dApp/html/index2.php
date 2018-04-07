<!DOCTYPE html>
<html>
  <head>
    <meta charset=utf-8 />
    <meta name="viewport" content="user-scalable=no, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, minimal-ui">
    <link href="./gjs/style.css" rel="stylesheet" />
    <script src="./gjs/jquery.min.js"></script>
    <script src="./gjs/cytoscape.min.js"></script>
    <script>
      $(function(){ // on dom ready
          var cy = cytoscape({
      container: document.getElementById('cy'),

      boxSelectionEnabled: false,
      autounselectify: true,

      style: [
            {
                  selector: 'node',
                  css: {
                        'content': 'data(id)',
                        'text-valign': 'center',
                        'text-halign': 'center'
                  }
            },
            {
                  selector: '$node > node',
                  css: {
                        'padding-top': '10px',
                        'padding-left': '10px',
                        'padding-bottom': '10px',
                        'padding-right': '10px',
                        'text-valign': 'top',
                        'text-halign': 'center',
                        'background-color': '#bbb'
                  }
            },
            {
                  selector: 'edge',
                  css: {
                        'target-arrow-shape': 'triangle',
                        'curve-style': 'bezier'
                  }
            },
            {
                  selector: ':selected',
                  css: {
                        'background-color': 'black',
                        'line-color': 'black',
                        'target-arrow-color': 'black',
                        'source-arrow-color': 'black'
                  }
            }
      ],

      elements: {
            nodes: [
                  { data: { id: 'a', parent: 'b' }, position: { x: 215, y: 85 } },
                  { data: { id: 'b', parent: 'g' } },
                  { data: { id: 'c', parent: 'b' }, position: { x: 300, y: 85 } },
                  { data: { id: 'd' }, position: { x: 135, y: 175 } },
                  { data: { id: 'e', parent: 'g' } },
                  { data: { id: 'f', parent: 'e' }, position: { x: 300, y: 175 } },
                  { data: { id: 'g' } },
                  { data: { id: 'h' }, position: { x: 400, y: 115 } },
                  { data: { id: 'i' }, position: { x: 400, y: 185 } }

            ],
            edges: [
                  { data: { id: 'db', source: 'd', target: 'b' } },
                  { data: { id: 'ac', source: 'a', target: 'c' } },
                  { data: { id: 'eb', source: 'e', target: 'b' } },
                  { data: { id: 'gi', source: 'g', target: 'i' } },
                  { data: { id: 'hg', source: 'h', target: 'g' } },
                  { data: { id: 'hi', source: 'h', target: 'i' } }

            ]
      },

      layout: {
            name: 'preset',
            padding: 5
      }
    });

    cy.on('tap', 'node', function(evt){
       var node = evt.cyTarget;
       document.getElementById("cz").innerHTML =
        "LMB auf "+node.id()+"<br>"+
        document.getElementById("cz").innerHTML;
    });

    cy.on('cxttap', 'node', function(evt){
       var node = evt.cyTarget;
       document.getElementById("cz").innerHTML =
        "RMB auf "+node.id()+"<br>"+
        document.getElementById("cz").innerHTML;
    });



    // cy.on('mousedown', 'node', function(evt){
    //    var node1 = evt.cyTarget;
    //    var startpos = node1.position();
    //
    //    var endpos;
    //    var node_pos;
    //    var handler = function(evt2){
    //       node_pos = evt2.cyTarget;
    //       endpos = node_pos.position();
    //    };
    //
    //    cy.on('position', 'node', handler);
    //    cy.one('mouseup', 'node', function(evt3){
    //       var node2 = evt.cyTarget;
    //
    //       document.getElementById("cz").innerHTML =
    //        "Bewege "+node1.id()+" von ("+startpos.x+", "+startpos.y+")<br>&nbsp&nbsp&nbsp; nach ("+endpos.x+", "+endpos.y+")<br>"+
    //        document.getElementById("cz").innerHTML;
    //        cy.off('position', handler);
    //    });
    //
    //
    // });

    // cy.on('mousemove', function(evt){
    //   var pos = evt.cyTarget.position();
    //   if(pos.x == null){
    //     document.getElementById("pos").innerHTML = "Connection selected";
    //   } else {
    //     document.getElementById("pos").innerHTML = "X: "+pos.x+" | Y: "+pos.y;
    //   }
    //
    // });
  }); // on dom ready


    </script>
  </head>
  <body>
    <div id="cy"></div>
    <div id="cx">
      <h2>Control Panel</h2>
      <button value="" name="ne" id="ne">Neues Element</button><br>
      <button value="" name="ne" id="ne">Markiertes löschen</button><br>
      <button value="" name="ne" id="ne">Verbindung erstellen</button>
    </div>
    <div id="czcontainer">
      <div id="czheadline">
        <div id="pos"><br></div>
        <h2>Action Log</h2>
      </div>
      <div id="cz">

      </div>
    </div>
  </body>
</html>
