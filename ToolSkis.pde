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
    String tabMap = "skis";
    tabName = tabMap;

    // Tab Properties
    cp5.tab(tabMap).activateEvent(true);
    cp5.tab(tabMap).setHeight(20);
    cp5.tab(tabMap).captionLabel().style().marginTop = 2;
    cp5.tab(tabMap).setId(id);
    cp5.tab(tabMap).setLabel("Skis");

    // Controls
    int x = 2;
    int y = 22;

    float zoomMin = 1.0;
    float zoomMax = 10.0;
    Slider sliderZoom = cp5.addSlider("Zoom", zoomMin, zoomMax, 7.0, x, y, 150, 20).addListener(this);
    sliderZoom.moveTo(tabMap);
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
    background(255);
    pushMatrix();
    translate(width/2, height/2);
    scale(zoom);
    // The offset (note how we scale according to the zoom)
    translate(offset.x/zoom, offset.y/zoom);

    //    skiRight.draw();
    //    skiLeft.draw();
    skiBoth.draw();
    //  drawBounding(skiLeft);
    //drawBounding(skiRight);
    popMatrix();
  }

  void drawBounding(RShape shape_)
  {
    RPoint[] rect = shape_.getBoundsPoints();
    stroke(200);
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
}

