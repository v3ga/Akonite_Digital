class ToolMap extends Tool implements MapEventListener
{
  de.fhpotsdam.unfolding.Map carte;
  EventDispatcher carteEventDispatcher;
  boolean eventsRegistered = false;

  // Controls
  Slider sliderZoom;

  // Triangles
  ArrayList triangles;

  // Bounding box for geoloc points, screen related
  Rect boundingStations = new Rect();
  Rect boundingStationsPrev = new Rect();

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
    this.tabName = "default";
    super.initControls();
    
    // Tab Properties
    cp5.tab(tabName).activateEvent(true);
    cp5.tab(tabName).setHeight(20);
    cp5.tab(tabName).captionLabel().style().marginTop = 2;
    cp5.tab(tabName).setId(id);
    cp5.tab(tabName).setLabel("Carte");

    // Controls
    int x = 2;
    int y = 22;

    int toggleMarginLeft = 24;
    int toggleMarginTop = -18;

    // Fichier xls


    // Zoom
    float zoomMin = 1.0;
    float zoomMax = 10.0;
    sliderZoom = cp5.addSlider("zoom", zoomMin, zoomMax, 7.0, x, y, 150, 20).addListener(this);
    sliderZoom.setNumberOfTickMarks(int(zoomMax-zoomMin)+1);
    sliderZoom.moveTo(tabName);

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
    toggleDrawIndexes.moveTo(tabName);
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
    // Update stations (position on screens)
    for (Station station : stations) {
      station.update();
    }
    
    // Compute Bounding box
    computeBoundingsStations();

    // Compute Voronoi
    triangles = triangulateStations();
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void computeBoundingsStations()
  {
    // Compute bounding box on screens
    float xMin = Float.POSITIVE_INFINITY, xMax = Float.NEGATIVE_INFINITY;    
    float yMin = Float.POSITIVE_INFINITY, yMax = Float.NEGATIVE_INFINITY;    
    for (Station station : stations) 
    {
      if (station.xy[0]<xMin) xMin = station.xy[0];
      if (station.xy[0]>xMax) xMax = station.xy[0];

      if (station.xy[1]<yMin) yMin = station.xy[1];
      if (station.xy[1]>yMax) yMax = station.xy[1];
    }    

    boundingStations.set(xMin,yMin,xMax-xMin,yMax-yMin);

    // Compute normalized positions of stations relative to this bounding box
    for (Station station : stations) 
    {
      station.computePositionBounding(boundingStations);
    }

    // Create or resize offscreen
    // ratio changed ??? 
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void draw()
  {
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
    
    noFill();
    stroke(colorBounding);
    rect(boundingStations.x,boundingStations.y,boundingStations.width,boundingStations.height);

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
  void exportXML()
  {
    float w = 1;
    float h = toolSkis.skiBoth.getHeight()/toolSkis.skiBoth.getWidth();
    
    String xml="<stations w=\""+w+"\" h=\""+h+"\">\n";
    for (Station station : stations) 
    {
      float x = station.posBoundingNorm3.x;
      float y = -station.posBoundingNorm3.y;
      
      xml+="\t<station important=\"" + (station.isImportant ? "1":"0") +"\" id=\""+split(station.id, ".")[0]+"\" dep=\""+station.dep+"\" name=\""+station.name+"\" x=\""+x+"\" y=\""+y+"\"/>\n";      
    }
    xml+="</stations>\n";

    String[] xmlStrings = new String[1];
    xmlStrings[0] = xml;
    saveStrings("akonite_digital_stations.xml", xmlStrings);

  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void exportPDF()
  {
    String suffix = "";

    String sep = "";
    for (int i=0;i<filterStationDep.length;i++)
    {
      suffix += sep+filterStationDep[i];
      sep = "_";
    }
    
    String filename = "export_dep_"+suffix+".pdf";

    
    int w = (int)toolSkis.skiBoth.getWidth()*2;
    int h = (int)toolSkis.skiBoth.getHeight()*2;
    PGraphics pdf = createGraphics(w, h, PDF, filename);
    pdf.beginDraw();
    pdf.background(255);
    pdf.noStroke();
    pdf.fill(0);
    for (Station station : stations) 
    {
      pdf.ellipse(station.posBoundingNorm.x*w, station.posBoundingNorm.y*h, 10,10);      
    }
    endRecord();

    pdf.dispose();
    pdf.endDraw();
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void keyPressed()
  {
    if (key == 'x')
    {
      exportXML();
    }
    else if (key == 'p')
    {
      exportPDF();
    }
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

