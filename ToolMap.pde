class ToolMap extends Tool implements MapEventListener
{
  de.fhpotsdam.unfolding.Map carte;
  EventDispatcher carteEventDispatcher;
  boolean eventsRegistered = false;

  // Controls
  Slider sliderZoom;

  // Triangles
  ArrayList triangles;

  // Properties
  //  boolean isDrawLinks = true;
  boolean isDrawIndexes = false;

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  ToolMap(PApplet p)
  {
    super(p);
    carte = new de.fhpotsdam.unfolding.Map(applet);
    carte.zoomAndPanTo(new de.fhpotsdam.unfolding.geo.Location(locMapStart[0], locMapStart[1]), 8);
    carteEventDispatcher = MapUtils.createDefaultEventDispatcher(applet, carte);
    carteEventDispatcher.register(this, ZoomMapEvent.TYPE_ZOOM, carte.getId());
    eventsRegistered = true;
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  public String getId()
  {
    return "__toolMap__";
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void initControls()
  {
    String tabMap = "default";
    tabName = tabMap;

    // Tab Properties
    cp5.tab(tabMap).activateEvent(true);
    cp5.tab(tabMap).setHeight(20);
    cp5.tab(tabMap).captionLabel().style().marginTop = 2;
    cp5.tab(tabMap).setId(id);
    cp5.tab(tabMap).setLabel("Carte");

    // Controls
    int x = 2;
    int y = 22;

    int toggleMarginLeft = 24;
    int toggleMarginTop = -18;

    // Fichier xls


    // Zoom
    float zoomMin = 1.0;
    float zoomMax = 10.0;
    sliderZoom = cp5.addSlider("Zoom", zoomMin, zoomMax, 7.0, x, y, 150, 20).addListener(this);
    sliderZoom.setNumberOfTickMarks(int(zoomMax-zoomMin)+1);
    sliderZoom.moveTo(tabMap);

    // Links
    /*
    y+=32;  
     Toggle toggleDrawLinks = cp5.addToggle("Connexions", toolMap.isDrawLinks, x, y, 20, 20).addListener(this);  
     toggleDrawLinks.moveTo(tabMap);
     toggleDrawLinks.captionLabel().style().marginLeft = toggleMarginLeft;
     toggleDrawLinks.captionLabel().style().marginTop = toggleMarginTop;
     */
    // Indexes
    y+=32;  
    Toggle toggleDrawIndexes = cp5.addToggle("Index", toolMap.isDrawIndexes, x, y, 20, 20).addListener(this);  
    toggleDrawIndexes.moveTo(tabMap);
    toggleDrawIndexes.captionLabel().style().marginLeft = toggleMarginLeft;
    toggleDrawIndexes.captionLabel().style().marginTop = toggleMarginTop;
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  public void controlEvent(ControlEvent theEvent)
  {
    String nameSource = theEvent.name();
    // Zoom
    if (nameSource.equals("Zoom"))
    {
      if (carte !=  null)
        carte.zoomToLevel(int(theEvent.value()));
    }
    // Links
    /*    else if (nameSource.equals("Connexions"))
     {
     this.isDrawLinks =  (theEvent.value() == 1.0f);
     }
     */
    else if (nameSource.equals("Index"))
    {
      this.isDrawIndexes =  (theEvent.value() == 1.0f);
    }
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  public void onManipulation(MapEvent event)
  {
    updateSliderZoom();
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void updateSliderZoom()
  {
    //if (toolCarte.sliderZoom != null)
    sliderZoom.setValue( carte.getZoomFromScale(carte.mapDisplay.innerScale) );
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void registerEvents(boolean is)
  {
    if (is) {
      if (carteEventDispatcher != null) {   
        if (!eventsRegistered) {   
          carteEventDispatcher.register(carte, PanMapEvent.TYPE_PAN, carte.getId());
          carteEventDispatcher.register(carte, ZoomMapEvent.TYPE_ZOOM, carte.getId());
          carteEventDispatcher.register(this, ZoomMapEvent.TYPE_ZOOM, carte.getId());
          eventsRegistered = true;
        }
      }
    }
    else {
      if (carteEventDispatcher != null) {    
        carteEventDispatcher.unregister(carte, PanMapEvent.TYPE_PAN, carte.getId());
        carteEventDispatcher.unregister(carte, ZoomMapEvent.TYPE_ZOOM, carte.getId());
        carteEventDispatcher.unregister(this, ZoomMapEvent.TYPE_ZOOM, carte.getId());
        eventsRegistered = false;
      }
    }
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void update()
  {
    for (Station station : stations) {
      station.update();
    }
    triangles = triangulateStations();
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void draw()
  {
    update();

    // Draw
    carte.draw();  

    pushStyle();

    if (triangles != null)
    {
      noFill();
      stroke(colorStationLines);

      beginShape(TRIANGLES);
      for (int i=0;i<triangles.size();i++)
      {
        Triangle t = (Triangle)triangles.get(i);

        vertex(t.p1.x, t.p1.y, 0.0);
        vertex(t.p2.x, t.p2.y, 0.0);
        vertex(t.p3.x, t.p3.y, 0.0);
      }
      endShape();
    }

    noStroke();
    fill(colorStation);
    int index=0;
    for (Station station : stations) {
      station.draw();
    }

    if (isDrawIndexes) {
      for (int i=0;i<stations.size();i++) {
        Station station = stations.get(i);
        text(station.name, station.xy[0]+6, station.xy[1]);
      }
    }

    popStyle();
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void mousePressed()
  {
    if (cp5.window(applet).isMouseOver())
      registerEvents(false);
    else
      registerEvents(true);
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  ArrayList triangulateStations()
  {
    if (stations != null)
    {
      ArrayList points = new ArrayList();
      for (Station s : stations)
      {
        PVector p = new PVector( s.xy[0], s.xy[1], 0.0 );
        points.add( p );
      }

      return Triangulate.triangulate(points);
    }

    return null;
  }
}

