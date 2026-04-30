
import processing.sound.*;

float x, y;
float vx, vy;

PImage[] images;
int currentImage = 0;
float sizeValue = 100;
float sizeSliderX = 20, sizeSliderY = 330;

boolean hide = true;

SinOsc[] notes;

float[] freqs = {
  261.6, 277.2, 293.7, 311.1,
  329.6, 349.2, 370.0, 392.0,
  415.3, 440.0, 466.2, 493.9
};

char[] keys = {'1','2','3','4','5','6','7','8','9','0','-','='};
boolean[] playing = new boolean[12];

boolean top = true;

boolean rotating = true;
float angleY = 0;
float angleX = 0;
float zoom = -200;

float keyW = 18;
float keyH = 55;
float startX;

color[] keyColors;

PFont font;

void setup() {
  size(800, 700, P3D);

  font = createFont("Arial", 32);
  textFont(font);

  notes = new SinOsc[12];
  for (int i = 0; i < 12; i++) {
    notes[i] = new SinOsc(this);
  }

  startX = -(12 * keyW) / 2;

  keyColors = new color[12];
  for (int i = 0; i < 12; i++) {
    keyColors[i] = color(random(120,255), random(120,255), random(120,255));
  }

  textAlign(CENTER, CENTER);
  
  images = new PImage[2];
  images[0] = loadImage("1.jpeg");
  images[1] = loadImage("2.jpeg");
  
}

void draw() {
  
  background(240);
  lights();
  
  if(hide) drawImage();
  
  translate(width/2, height/2, zoom);
  
  if (rotating) angleY += 0.01;

  rotateX(angleX);
  rotateY(angleY);

  drawCylinder(120, 200);
  drawCylinderBottomCap(120, 200);
  drawGlazeWrap();

  drawInnerText();   //TEXTS
  drawPiano();
  if (top) drawCylinderTopCap(120,-200);
}

//Cylinder
void drawCylinder(float r, float h) {
  int sides = 80;

  stroke(80);
  fill(255, 245, 230);

  beginShape(QUAD_STRIP);
  for (int i = 0; i <= sides; i++) {
    float a = TWO_PI * i / sides;
    vertex(cos(a)*r, -h/2, sin(a)*r);
    vertex(cos(a)*r,  h/2, sin(a)*r);
  }
  endShape();
}

// --- Bottom cap
void drawCylinderBottomCap(float r, float h) {
  int sides = 80;

  fill(255, 245, 230);
  stroke(80);

  beginShape(TRIANGLE_FAN);
  vertex(0, h/2, 0);

  for (int i = 0; i <= sides; i++) {
    float a = TWO_PI * i / sides;
    float x = cos(a) * r;
    float z = sin(a) * r;
    vertex(x, h/2, z);
  }

  endShape();
}

//Glaze
void drawGlazeWrap() {
  int sides = 80;
  float r = 122;
  float topY = -100;

  noStroke();
  fill(100, 160, 255, 140);

  beginShape(QUAD_STRIP);
  for (int i = 0; i <= sides; i++) {
    float a = TWO_PI * i / sides;

    float x = cos(a) * r;
    float z = sin(a) * r;

    float drip = 20 + 30 * noise(i * 0.2, frameCount * 0.02);

    vertex(x, topY, z);
    vertex(x, topY + drip, z);
  }
  endShape();
}

// TEXT INSIDE CYLINDER (OPPOSITE SIDES)
void drawInnerText() {
  pushMatrix();
  translate(0, 0, 30);

  textSize(26);
  textAlign(CENTER, CENTER);

  float offset = 40; //separate distance

  //HoYoHoYo
  pushMatrix();
  translate(0, 0, offset);
  draw3DText("HoYoHoYo", 0);
  popMatrix();

  
  textSize(20);
  pushMatrix();
  rotateY(PI);
  translate(0, 0, offset + 20); //extra spacing so it doesn't overlap
  draw3DText("Miku & Silver Wolf LV999", 0);
  popMatrix();

  popMatrix();
}
//3D text
void draw3DText(String word, float y) {

  //depth layers
  for (int i = 6; i > 0; i--) {
    pushMatrix();
    translate(0, 0, -i);
    fill(0, 35);
    text(word, 0, y);
    popMatrix();
  }

  fill(30);
  text(word, 0, y);
}

// --- Piano
void drawPiano() {
  pushMatrix();
  translate(0, 20, 120);

  noStroke();

  for (int i = 0; i < 12; i++) {
    if (playing[i]) fill(255);
    else fill(keyColors[i]);

    rect(startX + i * keyW, 0, keyW - 2, keyH);
  }

  popMatrix();
}

// --- Controls
void mouseDragged() {
  angleY += (mouseX - pmouseX) * 0.01;
  angleX += (mouseY - pmouseY) * 0.01;
  
  if (mouseX >= sizeSliderX && mouseX <= sizeSliderX + 120 &&
      mouseY >= sizeSliderY - 5 && mouseY <= sizeSliderY + 15) {

    sizeValue = map(mouseX, sizeSliderX, sizeSliderX + 120, 50, 200);
  }
}

void mouseWheel(processing.event.MouseEvent event) {
  zoom += event.getCount() * 20;
}

void mousePressed() {
  float localX = mouseX - width/2;
  float localY = mouseY - height/2;

  for (int i = 0; i < 12; i++) {
    float x = startX + i * keyW;
    float y = 20;

    if (localX > x && localX < x + keyW &&
        localY > y && localY < y + keyH) {
      playNote(i);
    }
  }
  if (mouseX > width-155 && mouseX < width &&
        mouseY > 75 && mouseY < 125){
      hide = !hide;
     }
  
}
//rect(width-80 - 75, 75, 150, 50);
void mouseReleased() {
  stopAll();
}

void keyPressed() {
  if (key == ' ') rotating = !rotating;

  for (int i = 0; i < 12; i++) {
    if (key == keys[i]) playNote(i);
  }
  if (key == 'r') top = !top;
  if (key == 'i'){
   currentImage = (currentImage + 1) % images.length; 
  }
}

void keyReleased() {
  stopAll();
}

// --- Sound
void playNote(int i) {
  notes[i].freq(freqs[i]);
  notes[i].amp(0.5);
  notes[i].play();
  playing[i] = true;
}

void stopAll() {
  for (int i = 0; i < 12; i++) {
    notes[i].stop();
    playing[i] = false;
  }
}


void drawCylinderTopCap(float r, float h) {
  int sides = 80;

  fill(255, 245, 230);
  stroke(80);
  
  beginShape(TRIANGLE_FAN);
  vertex(0, h/2, 0);

  for (int i = 0; i <= sides; i++) {
    float a = TWO_PI * i / sides;
    float x = cos(a) * r;
    float z = sin(a) * r;
    vertex(x, h/2, z);
  }

  endShape();
  translate(0,-120);
  sphere(20);
}

void drawImage(){
  imageMode(CENTER);
  image(images[currentImage], width/2, 100, sizeValue, sizeValue); 
  
  fill(100, 200, 100);
  rect(width-80 - 75, 75, 150, 50);
  fill(0);
  textSize(18);
  text("Hide", width-80, 100);
  drawSlider(sizeSliderX, sizeSliderY, sizeValue, 1, 10, "Size", color(255,100,100)); 
}

void drawSlider(float xPos, float yPos, float value, float minV, float maxV, String label, color c) {
  fill(0);
  textSize(12);
  text(label, xPos + 40, yPos - 10);

  fill(200);
  rect(xPos, yPos, 120, 10);

  fill(c);
  rect(xPos, yPos, map(value, minV, maxV, 0, 120), 10);
}
void drawObject() {
  imageMode(CENTER);
  image(images[currentImage], x, y, sizeValue, sizeValue);
}
