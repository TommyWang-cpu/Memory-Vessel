import processing.sound.*;

SinOsc[] notes;

float[] freqs = {
  261.6, 277.2, 293.7, 311.1,
  329.6, 349.2, 370.0, 392.0,
  415.3, 440.0, 466.2, 493.9
};

char[] keys = {'a','w','s','e','d','f','t','g','y','h','u','j'};
boolean[] playing = new boolean[12];

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
}

void draw() {
  background(240);
  lights();

  translate(width/2, height/2, zoom);

  if (rotating) angleY += 0.01;

  rotateX(angleX);
  rotateY(angleY);

  drawCylinder(120, 200);
  drawCylinderBottomCap(120, 200);
  drawGlazeWrap();

  drawInnerText();   //TEXTS
  drawPiano();
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

// --- 🧠 TEXT INSIDE CYLINDER (OPPOSITE SIDES)
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
}

void mouseReleased() {
  stopAll();
}

void keyPressed() {
  if (key == ' ') rotating = !rotating;

  for (int i = 0; i < 12; i++) {
    if (key == keys[i]) playNote(i);
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
