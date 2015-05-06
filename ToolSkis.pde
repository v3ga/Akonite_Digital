class ToolSkis extends Tool
{
  RShape skiLeft;
  RShape skiRight;
  RShape skiBoth;
  float  skiRatio = 0.0, skiRatioPrev = -1.0;

  boolean isDrawParticles = false;
  boolean isDrawBlobs = false;
  boolean isDrawOffscreens = false;
  boolean isDrawStations = true;
  
  PGraphics offSkiMask;
  PGraphics offParticles,offParticlesResized,offParticlesMaskResized;
  PImage    imgOffParticlesResized;

  BlobDetection blobs;
  float blobsTh=0.2;

  PImage imgOffscreenMaskResized;

  PanelZoom panelZoom = new PanelZoom();

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  ToolSkis(PApplet p)
  {
    super(p);
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
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
    Slider sliderZoom = cp5.addSlider("zoomPanel", zoomMin, zoomMax, 1.0, x, y, 150, 20).addListener(this);
    sliderZoom.moveTo(this.tabName);

    y+=20;
    float blobsThMin = 0.0;
    float blobsThMax = 1.0;
    Slider sliderBlobsTh = cp5.addSlider("blobsTh", blobsThMin, blobsThMax, 0.5, x, y, 150, 20).addListener(this);
    sliderBlobsTh.moveTo(this.tabName);

  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
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
    skiBoth.setFill( color(255) );

    createOffscreens();

  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void createOffscreens()
  {
      float skiRatio = skiBoth.getWidth()/skiBoth.getHeight();
      float offscreenWidth = skiBoth.getWidth(); // 500;
      int wOffscreen = (int) offscreenWidth;
      int hOffscreen = int(offscreenWidth/skiRatio);
      
      // Offscreens for particles (normal + resized)
      println("- creating offscreen for particles, w="+wOffscreen+";h="+hOffscreen);
      offParticles = createGraphics(wOffscreen,hOffscreen);
      float ratio = getRatio(offParticles);
      offParticlesResized = createGraphics(50, int(50.0/ratio));
      offParticlesMaskResized = createGraphics(offParticlesResized.width, offParticlesResized.height);

      // Offscreen for mask
      println("- creating offscreen for ski mask");
      offSkiMask = createGraphics( offParticlesResized.width, offParticlesResized.height );
      skiBoth.centerIn(offSkiMask);
      offSkiMask.beginDraw();
      offSkiMask.background(0,255);
      offSkiMask.translate(offSkiMask.width/2, offSkiMask.height/2);
      offSkiMask.noStroke();
      offSkiMask.fill(255,255);
      RPolygon skiBothPoly = skiBoth.toPolygon();
      skiBothPoly.draw(offSkiMask);
      offSkiMask.endDraw();

      skiBoth.centerIn(applet.g);

      println("- creating blobs");
      blobs = new BlobDetection(offParticlesMaskResized.width, offParticlesMaskResized.height);
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void update()
  {
    // Draw particles
    toolParticles.drawParticles(); // toolParticles knows offParticles
    
    // Resize (prepate for blob detection)
    offParticlesResized.beginDraw();
    offParticlesResized.image(offParticles, 0,0,offParticlesResized.width,offParticlesResized.height);
    offParticlesResized.endDraw();
    
    // Apply Mask
    imgOffParticlesResized = offParticlesResized.get(); 
    imgOffParticlesResized.mask(offSkiMask);

    // Blob Detection
    blobs.setThreshold(blobsTh);
    blobs.computeBlobs(imgOffParticlesResized.pixels);

    // Draw particles with mask
    imgOffParticlesResized = offParticlesResized.get();
    imgOffParticlesResized.mask(offSkiMask);
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void draw()
  {
    pushStyle();
    background(255);

    if (isDrawOffscreens)
    {
      int x = 0;
      float y = height-offSkiMask.height;
      int gap = 10;
      image(offSkiMask,x,y);

      x+=(int)offSkiMask.width+gap;
      image(imgOffParticlesResized,x,y);

      x+=(int)imgOffParticlesResized.width+gap;
      image(imgOffParticlesResized,x,y);
      
      stroke(200,0,0);
      drawContours(x,y,imgOffParticlesResized.width,imgOffParticlesResized.height);

    }
    
    panelZoom.begin();

    //    skiRight.draw();
    //drawBounding(skiRight);
    //    skiLeft.draw();
    //  drawBounding(skiLeft);

    // Draw skis contour + bounding box
    noStroke();
    fill(255,255);
    skiBoth.draw();
    drawBounding(skiBoth);
    
    // Draw stations inside
    if (isDrawStations)
    {
      fill(colorStation);
      noStroke();
      for (Station s : stations)
      {
        ellipse(s.posBoundingNorm3.x*skiBoth.getWidth(), s.posBoundingNorm3.y*skiBoth.getHeight(), 5,5);    
      }
    }
    // Draw 
    RPoint[] rect = skiBoth.getBoundsPoints();
    if (isDrawParticles)
    {
      if (imgOffParticlesResized != null)
      {
        tint(255,100);  
        image(imgOffParticlesResized, rect[0].x, rect[0].y, skiBoth.getWidth(), skiBoth.getHeight());    
      }
    }

    if (isDrawBlobs)
    {
      if (blobs != null)
      {
        stroke(255,0,0);
        pushMatrix();
        translate(rect[0].x, rect[0].y,0);
        drawContours(0,0,skiBoth.getWidth(), skiBoth.getHeight());
        popMatrix();
      }    
    }


    panelZoom.end();
    popStyle();
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
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

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void drawContours(float x, float y, float w, float h) 
  {
    Blob b;
    EdgeVertex eA, eB;
    for (int n=0 ; n<blobs.getBlobNb() ; n++) 
    {
      b=blobs.getBlob(n);
      if (b!=null) 
      {
        for (int m=0;m<b.getEdgeNb();m++) 
        {
          eA = b.getEdgeVertexA(m);
          eB = b.getEdgeVertexB(m);
          if (eA !=null && eB !=null)
            line(
            x+eA.x*w, y+eA.y*h, 
            x+eB.x*w, y+eB.y*h 
              );
        }
      }
    }
  }



  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void mousePressed()
  {
    if (!cp5.isMouseOver())
      panelZoom.mousePressed();
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void mouseDragged() {
    if (!cp5.isMouseOver())
      panelZoom.mouseDragged();
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  public void controlEvent(ControlEvent theEvent)
  {
    String nameSource = theEvent.name();
    if (nameSource.equals("zoomPanel"))
    {
        panelZoom.setZoom( theEvent.value() );
    }
    else if (nameSource.equals("blobsTh"))
    {
        blobsTh = theEvent.value() ;
    }


  }
}

