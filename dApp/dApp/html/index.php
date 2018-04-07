<html>
<head>
    <script type="text/javascript" src="vis/dist/vis.js"></script>
    <link href="vis/dist/vis.css" rel="stylesheet" type="text/css" />

    <style type="text/css">
        #canvasnetwork {
            width: 1000px;
            height: 666px;
            border: 1px solid lightgray;
        }
    </style>
</head>
<body oncontextmenu="return false;">
<div id="canvasnetwork"></div>

<script type="text/javascript">

    var nodes = new vis.DataSet([
        {id: 1, label: 'Node 1', group:'group1'},
        {id: 2, label: 'Node 2', group:'group1'},
        {id: 3, label: 'Node 3', group:'group2'},
        {id: 4, label: 'Node 4', group:'group2'},
        {id: 5, label: 'Node 5', group:'group2'},
        {id: 6, label:'Connector', group:'connectors'},
        {id: 7, label:'Connector', group:'connectors'},
        {id: 8, label:'Node 6', group:'group3'},
        {id: 9, label:'Node 7', group:'group3'}
    ]);


    var edges = new vis.DataSet([
        {from: 1, to: 2},
        {from: 6, to: 1},
        {from: 6, to: 3},
        {from: 3, to: 4},
        {from: 5, to: 4},
        {from: 3, to: 5},
        {from: 7, to: 1},
        {from: 7, to: 8},
        {from: 8, to: 9},
    ]);


    var container = document.getElementById('canvasnetwork');


    var data = {
        nodes: nodes,
        edges: edges
    };
    var options = {
		  joinCondition:function(nodeOptions) {
    return nodeOptions.group === 'group1';
  },
   clusterNodeProperties: {id:'Group1_Cluster', label:'Group1', borderWidth:3, shape:'diamond', color:'blue'}


	};

  var options2 = {
    joinCondition:function(nodeOptions) {
  return nodeOptions.group === 'group2';
},
 clusterNodeProperties: {id:'Group2_Cluster', label:'Group2', borderWidth:3, shape:'diamond', color:'yellow',
 }

};

var options3 = {
  joinCondition:function(nodeOptions) {
return nodeOptions.group === 'group3';
},
clusterNodeProperties: {id:'Group3_Cluster', label:'Group3', borderWidth:3, shape:'diamond', color:'green',
}

};

    // initialize your network!
        var network = new vis.Network(container, data, options);
  	   network.clustering.cluster(options);
       network.clustering.cluster(options2);
       network.clustering.cluster(options3);
       network.on("selectNode", function(params) {
         if (params.nodes.length == 1) {
           if (network.isCluster(params.nodes[0]) == true) {
             network.openCluster(params.nodes[0]);
           }
         }
	  });
	  network.on("oncontext", function(params){
		 // this.redraw();
		  //alert(params.pointer.DOM);
		  //alert(getMouseY());
		  //alert([getMouseX(), getMouseY()]);
		  var nodee = this.getNodeAt(params.pointer.DOM);
	         if(nodee !== undefined){
           alert((nodes.get(nodee).label));
			 }
   }
  );
</script>
</body>
</html>
