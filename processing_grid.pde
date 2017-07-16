// so processing sketch can call javascript functions
interface JavaScript {
  void updateData();
  void setCellDB(int col, int row, int red, int green, int blue);
}

void bindJavascript(JavaScript js) {
  javascript = js;
}

JavaScript javascript;


int boxSize = 100;
color[][] colors;
int cols, rows;

// formatting 
int rightMargin = 300;
int bottomMargin = 300;

// the selected cell
int selectedCol;
int selectedRow;

// the actual x, y coordinates of a mouse click
int clickedX;
int clickedY;

// not true sliders but close enough
Slider sliderR;
Slider sliderG;
Slider sliderB;

Button submit;

PFont f;

// slider dimensions
int sWidth = 255;
int sHeight = 50;

// y coordinate of top slider, used to space them out
int topYSliders;

// number of times draw has been called in this cycle
// used to limit number of http requests sent
int countDraw;

void setup() {
  size(1000, 1000); 
  topYSliders = boxSize / 2;
  cols = (width - rightMargin) / boxSize;
  rows = (height - bottomMargin) / boxSize;
  colors = new color[cols][rows]; // x, y
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      colors[i][j] = color(255); // white
    }
  }

  f = createFont("Arial", 36, true);


  // sliders
  sliderR = new Slider(width - rightMargin + 25, topYSliders, sWidth, sHeight, f, "Red", 67);
  sliderG = new Slider(width - rightMargin + 25, topYSliders + 2 * sHeight, sWidth, sHeight, f, "Green", 135);
  sliderB = new Slider(width - rightMargin + 25, topYSliders + 4 * sHeight, sWidth, sHeight, f, "Blue", 143);

  // submit button
  submit = new Button(width - rightMargin + 25, topYSliders + 6 * sHeight + 2 * boxSize + boxSize / 2, sWidth, sHeight, f);

  countDraw = 0;
}

void draw() {
  if (javascript != null && countDraw > 200) {
    javascript.updateData();
    countDraw = 0;
  }

  countDraw++;

  // fill the cells
  stroke(150);
  strokeWeight(1);
  background(255);
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      fill(colors[i][j]);
      rect(i * boxSize, j * boxSize, boxSize, boxSize);
    }
  }

  // highlight selected rectangle
  strokeWeight(5);
  color(0);
  noFill();
  rect(selectedCol * boxSize, selectedRow * boxSize, boxSize, boxSize);

  // sliders
  //sliderR.update();
  sliderR.display();

  //sliderG.update();
  sliderG.display();

  //sliderB.update();
  sliderB.display();

  // submit button
  submit.update();
  submit.display();
  
   // sample color rectangle
  noStroke();
  fill(sliderR.getValue(), sliderG.getValue(), sliderB.getValue());
  rect(width - rightMargin + 55, topYSliders + 6 * sHeight, 2 * boxSize, 2 * boxSize);

  // send http request to update database if submit was clicked
  if (submit.wasClicked()) {
    colors[selectedCol][selectedRow] = color(sliderR.getValue(), sliderG.getValue(), sliderB.getValue());
    if (javascript != null) {
      javascript.setCellDB(selectedCol, selectedRow, sliderR.getValue(), sliderG.getValue(), sliderB.getValue());
    }
    clickedX = -1;
    clickedY = -1;
    submit.reset();
  }

 
}

// called on mouse click - for clicking within cell
void mousePressed() {
  submit.update();
  // if mouse clicked within grid boundaries, update selected cell
  if (mouseX < width - rightMargin && mouseY < rows * boxSize) {
    selectedCol = (mouseX - (mouseX % boxSize)) / 100;
    selectedRow = (mouseY - (mouseY % boxSize)) / 100;
  }
  
  
  // can update sliders by dragging or by clicking
  sliderR.update();
  sliderG.update();
  sliderB.update();
  
  clickedX = mouseX;
  clickedY = mouseY;
}

// called on mouse drag - update sliders
void mouseDragged() {
  sliderR.update();
  sliderG.update();
  sliderB.update();
}

// used for javascript to call to update a cell color
void setColor(int col, int row, int r, int g, int b) {
  colors[col][row] = color(r, g, b);
}



// had to implement my own slider since processing js doesn't support control p5 java library
class Slider {
  int sWidth, sHeight; 
  int xPos, yPos; // top left corner
  int sliderPosition; // x position of slider
  PFont f;
  String label;

  Slider(int x, int y, int sw, int sh, PFont font, String s, int defaultVal) {
    this.xPos = x;
    this.yPos = y;
    this.sWidth = sw;
    this.sHeight = sh;
    sliderPosition = defaultVal;
    this.f = font;
    this.label = s;
  }

  // update slider position if mouse click was within slider
  void update() {
    //if (clickedX >= xPos && clickedX <= xPos + sWidth && clickedY >= yPos && clickedY <= yPos + sHeight) { // slider was clicked
    //  sliderPosition = clickedX - xPos;
    //}
    if (mouseX >= xPos && mouseX <= xPos + sWidth && mouseY >= yPos && mouseY <= yPos + sHeight) { // slider was clicked
      sliderPosition = mouseX - xPos;
    }
  }

  void display() {
    noStroke();
    fill(90);
    rect(xPos, yPos, sWidth, sHeight); // full rect
    fill(200);
    rect(xPos, yPos, sliderPosition, sHeight); // slider rect

    // label for button
    fill(0);
    textFont(f, sHeight / 2);
    text(label, xPos, yPos + sHeight + sHeight / 2);

    //value label
    fill(255);
    text("" + sliderPosition, xPos + 10, yPos + sHeight / 4 + sHeight / 2);
  }

  int getValue() {
    return sliderPosition;
  }
}

// had to implement own button class since processing js doesn't support the button library either
class Button {
  int bWidth, bHeight;
  int xPos, yPos;
  boolean clicked;
  PFont f;

  Button(int x, int y, int bw, int bh, PFont font) {
    this.xPos = x;
    this.yPos = y; 
    this.bWidth = bw;
    this.bHeight = bh;
    clicked = false;

    this.f = font;
  }

  // change button state if mouse click was within button boundaries
  void update() {
    if (clickedX >= xPos && clickedX <= xPos + bWidth && clickedY >= yPos && clickedY <= yPos + bHeight) { // slider was clicked
      clicked = true;
    }
  }

  void display() {
    fill(100);
    rect(xPos, yPos, bWidth, bHeight);
    fill(255);
    textFont(f, 25);
    text("Submit Color", xPos + 50, yPos + (bHeight / 2) + 10);
  }

  void reset() {
    clicked = false;
  }

  boolean wasClicked() {
    return clicked;
  }
}