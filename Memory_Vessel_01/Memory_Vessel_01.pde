//Tommy Wang
//April 24 
//memory vessel 01
//Ill try my best to turn your memory into digital codes

 float cameraY = height/2.0;
 float fov = mouseX/float(width) * PI/2;
 float cameraZ = cameraY / tan(fov / 2.0);
 float aspect = float(width)/float(height);
  
void setup() {
  size(700, 700, P3D);
}

void draw() {
  background(245);
  lights();

  translate(width/2, height/2);
  rotateY(frameCount * 0.01); // rotation

  drawCylinder(120, 200);
  //drawGlazeBands();
  //drawPiano();
  //drawBird();
  perspective(fov, aspect, cameraZ/10.0, cameraZ*10.0);
}

// Cylinder
void drawCylinder(float r, float h) { 
  int sides = 60;

  stroke(0);
  fill(230);

  // side surface
  beginShape(QUAD_STRIP);
  for (int i = 0; i <= sides; i++) {
    float angle = TWO_PI * i / sides;
    float x = cos(angle) * r;
    float z = sin(angle) * r;

    vertex(x, -h/2, z);
    vertex(x, h/2, z);
  }
  endShape();

  // top
  beginShape(TRIANGLE_FAN);
  vertex(0, -h/2, 0);
  for (int i = 0; i <= sides; i++) {
    float angle = TWO_PI * i / sides;
    vertex(cos(angle)*r, -h/2, sin(angle)*r);
  }
  endShape();

  // bottom
  beginShape(TRIANGLE_FAN);
  vertex(0, h/2, 0);
  for (int i = 0; i <= sides; i++) {
    float angle = TWO_PI * i / sides;
    vertex(cos(angle)*r, h/2, sin(angle)*r);
  }
  endShape();
}
