// --------------------------------------------------------------------
class Station
{
  String id;
  String name;
  float altitude = 0.0f;
  int dep = 0;
  de.fhpotsdam.unfolding.geo.Location loc;
  float xy[];
  PVector posBoundingNorm = new PVector();
  RPoint posBoundingNorm2 = new RPoint(); // normalized & relative to the upper left corner of the bounding rect
  RPoint posBoundingNorm3 = new RPoint(); // normalized & relative to the center of the bounding rect

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  Station(String id_, String name_)
  {
    this.id = id_;
    this.name = name_;
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void setDepartement(String dep_)
  {
    this.dep = (int)Float.parseFloat(dep_);
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void setLoc(float lat_, float lon_)
  {
    loc = new de.fhpotsdam.unfolding.geo.Location(lat_, lon_);
  }

  void setLoc(String lat_, String lon_) {
    setLoc( Float.parseFloat(lat_), Float.parseFloat(lon_));
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void setLocAndAltitude(String lat_, String lon_, String altitude) {
    setLoc(lat_, lon_);
    this.altitude = Float.parseFloat(altitude);
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void computePositionBounding(Rect bounding_)
  {
    // Store in PVector
    this.posBoundingNorm.set( (this.xy[0]-bounding_.x)/bounding_.width, (this.xy[1]-bounding_.y)/bounding_.height);

    // Store in RPoint
    this.posBoundingNorm2.x = this.posBoundingNorm.x; 
    this.posBoundingNorm2.y = this.posBoundingNorm.y; 

    this.posBoundingNorm3.x = this.posBoundingNorm.x - 0.5; 
    this.posBoundingNorm3.y = this.posBoundingNorm.y - 0.5; 
  }



  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void update()
  {
    if (map != null) {
      this.xy = map.getScreenPositionFromLocation(this.loc);
    }
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void draw()
  {
    if (map != null) {
      ellipse(xy[0], xy[1], 8, 8);
    }
  }
}

// --------------------------------------------------------------------
class StationManager extends ArrayList<Station>
{
  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void setup()
  {
    DocumentExcel doc = loadDocumentExcel( "Stations", dataPath("Liste_stations_nivometeo.xls") );
    for (int i=1; i<doc.nbRows ; i++)
    {
      int depStation = (int) Float.parseFloat( doc.getCellContent(i, "departement") );
      int idStation = (int) Float.parseFloat( doc.getCellContent(i, "numer_sta") );

      boolean keepIt = false;
      if (filterStationMode == 0)
        keepIt = filterById(idStation);
      else if (filterStationMode == 1)
        keepIt = filterDepartement(depStation);
      else if (filterStationMode == 2)
        keepIt = true;
        
      if ( keepIt )
      { 
        Station s = new Station( doc.getCellContent(i, "numer_sta"), doc.getCellContent(i, "nom usuel") );
        s.setLocAndAltitude( doc.getCellContent(i, "latitude"), doc.getCellContent(i, "longitude"), doc.getCellContent(i, "altitude") );
        s.setDepartement( doc.getCellContent(i, "departement") );

        add(s);
      }
    }
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void printStationIds()
  {
    String s="";
    String sep="";
    String sepLine="";
    int indexGotoLine = 0;
    for(Station station : this)
    {
      s += sep+sepLine+split(station.id, ".")[0];
      sep = ",";
      indexGotoLine++;
      if (indexGotoLine >= 20){indexGotoLine=0;sepLine="\n";}else{sepLine="";};
    }
    
    println(s);
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  boolean filterById(int id)
  {
    if (id>=idStationMin && id<=idStationMax)
    {
      return true;
    }
    return false;
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  boolean filterDepartement(int dep)
  {
    for (int i=0;i<filterStationDep.length;i++) {
      if (dep == filterStationDep[i]) return true;
    }
    return false;
  }
}

