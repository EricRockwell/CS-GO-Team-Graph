import processing.pdf.*;

// Code from Visualizing Data, First Edition, Copyright 2008 Ben Fry.
// Based on the GraphLayout example by Sun Microsystems.


 //load data from the table of gained players and their teams
  // create a node for each player and team
  //make the nodes for the teams a shade of blue
  //make the nodes for the players a shade of yellow/orange
  //maybe make each team have a background with their logo
  // place it so the teams are along the top and the players all go below 
  //make it so if they are currently on the team, it is purple 
  //on hover draw a slightly smaller radius circle within the other circle to display the information
  //make it so the name will be the team
  //make it so all the data after that will be the player so --
  //row[0] == name of team
  //row[1] == player on the team
  //the repeats for as many players as there is per team
  //maybe keep track of how many players there are for each team and display that on the hover of each node




int nodeCount;
Node[] nodes = new Node[100];
HashMap nodeTable = new HashMap();
Table data;
int edgeCount;
Edge[] edges = new Edge[500];

static final color nodeColor   = #F0C070;
static final color selectColor = #FF3030;
static final color fixedColor  = #FF8080;
static final color edgeColor   = #000000;

PFont font;


void setup() {
  size(600, 600);  
    data = loadTable("data.tsv");
  loadData();
  font = createFont("SansSerif", 10);

}


void writeData() {
  PrintWriter writer = createWriter("huckfinn.dot");
  writer.println("digraph output {");
  for (int i = 0; i < edgeCount; i++) {
    String from = "\"" + edges[i].from.label + "\"";
    String to = "\"" + edges[i].to.label + "\"";
    writer.println(TAB + from + " -> " + to + ";");
  }
  writer.println("}");
  writer.flush();
  writer.close();
}


void loadData() {
  for (int i = 0; i < data.getRowCount(); i++) {
      for (int j = 0; j< data.getRowCount(); j++) {
        addEdge(data.getString(i,1), data.getString(i,0));
      }
      
}

}

void addEdge(String fromLabel, String toLabel) {
  
  Node from = findNode(fromLabel);
  Node to = findNode(toLabel);
  from.increment();
  to.increment();
  
  for (int i = 0; i < edgeCount; i++) {
    if (edges[i].from == from && edges[i].to == to) {
      edges[i].increment();
      return;
    }
  } 
  
  Edge e = new Edge(from, to);
  e.increment();
  if (edgeCount == edges.length) {
    edges = (Edge[]) expand(edges);
  }
  edges[edgeCount++] = e;
}



Node findNode(String label) {
  label = label.toLowerCase();
  Node n = (Node) nodeTable.get(label);
  if (n == null) {
    return addNode(label);
  }
  return n;
}


Node addNode(String label) {
  Node n = new Node(label);  
  if (nodeCount == nodes.length) {
    nodes = (Node[]) expand(nodes);
  }
  nodeTable.put(label, n);
  nodes[nodeCount++] = n;  
  return n;
}


void draw() {
  if (record) {
    beginRecord(PDF, "output.pdf");
  }

  background(255);
  textFont(font);  
  smooth();  
  
  for (int i = 0 ; i < edgeCount ; i++) {
    edges[i].relax();
  }
  for (int i = 0; i < nodeCount; i++) {
    nodes[i].relax();
  }

  for (int i = 0 ; i < edgeCount ; i++) {
    edges[i].draw();
  }
  for (int i = 0 ; i < nodeCount ; i++) {
    nodes[i].draw();
  }
  
  if (record) {
    endRecord();
    record = false;
  }
}


boolean record;

void keyPressed() {
  if (key == 'r') {
    record = true;
  }
}


Node selection; 


void mousePressed() {
  // Ignore anything greater than this distance
  float closest = 20;
  for (int i = 0; i < nodeCount; i++) {
    Node n = nodes[i];
    float d = dist(mouseX, mouseY, n.x, n.y);
    if (d < closest) {
      selection = n;
      closest = d;
    }
  }
  if (selection != null) {
    if (mouseButton == LEFT) {
      selection.fixed = true;
    } else if (mouseButton == RIGHT) {
      selection.fixed = false;
    }
  }
}


void mouseDragged() {
  if (selection != null) {
    selection.x = mouseX;
    selection.y = mouseY;
  }
}


void mouseReleased() {
  selection = null;
}
