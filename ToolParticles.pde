class ToolParticles extends Tool
{
  // Links to toolSkis instance offscreens
  PGraphics offscreen,offscreenResized,offscreenMaskResized;

  // Enable zooming
  PanelZoom panelZoom = new PanelZoom();

  // TEMP
  PImage img;

  // Agent + Attractors + Repulsors
  ArrayList<Agent> agents = new ArrayList<Agent>();
  ArrayList<AttractionPoint> attrPoints  = new ArrayList<AttractionPoint>();
  ArrayList<AttractionPoint> repPoints = new ArrayList<AttractionPoint>();
  
  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  ToolParticles(PApplet p)
  {
    super(p);
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void setup()
  {
    img = loadImage("map.gif");
    
    offscreen = toolSkis.offParticles;
    offscreenResized = toolSkis.offParticlesResized;

    // Create attractors / repulsors    
    for (Station station : stations)
    {
      // RULE for creating attractor or repulsor
      if (station.precipitation24h <= 50)
      {
         attrPoints.add( new AttractionPoint(station) );
      }
      else
      {
         repPoints.add( new AttractionPoint(station) );
      }
      
    }

    println("-created "+attrPoints.size()+" attractors and "+repPoints.size()+" repulsors");
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void initControls()
  {
    this.tabName = "Particles";
    super.initControls();
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void drawParticles()
  {
    offscreen.beginDraw();
    offscreen.noStroke();
    offscreen.fill(50);
    drawAttractors(attrPoints);
    offscreen.fill(200);
    drawAttractors(repPoints);
    offscreen.fill(255);

    for (Agent a : agents) 
    {
      a.display(offscreen);
    }  
    offscreen.endDraw();
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void drawAttractors(ArrayList<AttractionPoint> list_)
  {
    for (AttractionPoint point : list_)
    {
      offscreen.ellipse(point.station.posBoundingNorm2.x*offscreen.width, point.station.posBoundingNorm2.y*offscreen.height,5,5); 
    }
  }
  
  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void update()
  {
    for (AttractionPoint point : attrPoints)
    {
      point.set( point.station.posBoundingNorm2.x*offscreen.width, point.station.posBoundingNorm2.y*offscreen.height );
    }
    for (AttractionPoint point : repPoints)
    {
      point.set( point.station.posBoundingNorm2.x*offscreen.width, point.station.posBoundingNorm2.y*offscreen.height );
    }

    for (Agent a : agents) 
    {
      a.move();
    }  
  }
  
  
  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void draw()
  {
    background(0);
    pushStyle();
    pushMatrix();
    panelZoom.begin();
    if (offscreen != null)
    {
      translate(width/2-offscreen.width/2, height/2-offscreen.height/2);
      image(offscreen,0,0,offscreen.width,offscreen.height);
    }
    panelZoom.end();
    popMatrix();
    popStyle();
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void mousePressed()
  {
    //panelZoom.mousePressed();
    float x = map(mouseX,0,width,0,offscreen.width);
    Agent agent = new Agent((int)x,(int)random(offscreen.height));
    agent.setAttrPoints(attrPoints);
    agent.setRepPoints(repPoints);
    agents.add(agent);
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void mouseDragged() {
    //panelZoom.mouseDragged();
  }


}
