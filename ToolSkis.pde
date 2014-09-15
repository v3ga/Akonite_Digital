class ToolSkis extends Tool
{
  RShape skiLeft;
  RShape skiRight;
  RShape skiBoth;

  float zoom;
  float scale;
  PVector offset, poffset;
  PVector mouse;


  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  ToolSkis(PApplet p)
  {
    super(p);
    zoom = 1.0;
    offset = new PVector(0, 0);
    poffset = new PVector(0, 0);
  }

  void initControls()
  {
    // Tab Properties
    this.tabName = "skis";
    super.initControls();

    // Controls
    int x = 2;
    int y = 22;

    float zoomMin = 1.0;
    float zoomMax = 10.0;
    Slider sliderZoom = cp5.addSlider("zoomPanel", zoomMin, zoomMax, 7.0, x, y, 150, 20).addListener(this);
    sliderZoom.moveTo(this.tabName);
  }

  void setup()
  {
    RShape shapeSkis = RG.loadShape("Ski Akonite 2014-1.svg");
    //shapeSkis.children[2].rotate(PI/2);
    skiLeft = shapeSkis.children[0];
    skiRight = shapeSkis.children[2];

    skiLeft.centerIn(applet.g);
    skiLeft.rotate(PI/2);
    skiLeft.centerIn(applet.g);
    skiLeft.translate(-skiLeft.getWidth()/2, 0);

    skiRight.centerIn(applet.g);
    skiRight.rotate(PI/2);
    skiRight.centerIn(applet.g);
    skiRight.translate(skiRight.getWidth()/2, 0);

    skiBoth = new RShape();
    skiBoth.addChild(skiLeft);
    skiBoth.addChild(skiRight);
  }

  void draw()
  {
    pushStyle();
    background(255);
    pushMatrix();
    translate(width/2, height/2);
    scale(zoom);
    // The offset (note how we scale according to the zoom)
    translate(offset.x/zoom, offset.y/zoom);

    //    skiRight.draw();
    //drawBounding(skiRight);
    //    skiLeft.draw();
    //  drawBounding(skiLeft);
    skiBoth.draw();
    drawBounding(skiBoth);
    
    // Draw stations inside
    fill(colorStation);
    noStroke();
    for (Station s : stations)
    {
      ellipse(s.posBoundingNorm3.x*skiBoth.getWidth(), s.posBoundingNorm3.y*skiBoth.getHeight(), 5,5);    
    }

    popMatrix();
    popStyle();
  }

  void drawBounding(RShape shape_)
  {
    RPoint[] rect = shape_.getBoundsPoints();
    stroke(colorBounding);
    beginShape(QUADS);
    for (int i=0;i<rect.length;i++) {
      vertex(rect[i].x, rect[i].y);
    }
    endShape();
  }

  void mousePressed()
  {
    mouse = new PVector(mouseX, mouseY);
    poffset.set(offset);
  }

  // Calculate the new offset based on change in mouse vs. previous offsey
  void mouseDragged() {
    offset.x = mouseX - mouse.x + poffset.x;
    offset.y = mouseY - mouse.y + poffset.y;
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  public void controlEvent(ControlEvent theEvent)
  {
    String nameSource = theEvent.name();
    if (nameSource.equals("zoomPanel"))
    {
        zoom = theEvent.value();
    }
  }
}

