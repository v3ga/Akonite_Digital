// --------------------------------------------------------------------
import de.fhpotsdam.unfolding.mapdisplay.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.tiles.*;
import de.fhpotsdam.unfolding.interactions.*;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.core.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.events.*;
import de.fhpotsdam.utils.*;
import de.fhpotsdam.unfolding.providers.*;
import geomerative.*;
import controlP5.*;
import java.io.*;
import java.util.*; 
import org.apache.poi.ss.usermodel.Sheet;
import org.processing.wiki.triangulate.*;


// --------------------------------------------------------------------
ControlP5 cp5;
ToolManager toolManager;
ToolMap toolMap;
ToolSkis toolSkis;
StationManager stations;

// Variable pour stocker la carte
de.fhpotsdam.unfolding.Map map;
// Couleur pour le dessin des stations sur la carte
color colorStation = color(0,0,0);
color colorStationLines = color(60,60,60);
// Départements à considérer pour l'application
int[] filterStationDep = {4,5,6,38,73,74};
int idStationMin = 7400;
int idStationMax = 7499;
int filterStationMode = 1; // 0 = par id, 1 par département, 2 = tout
// Position (lat, lon) au démarrage de l'application
float[] locMapStart = {45.05447, 6.4686};
// Zoom par défaut au démarrage de l'application
float zoomMapStart = 7.0; 

// --------------------------------------------------------------------
// setup()
// --------------------------------------------------------------------
void setup()
{
  size(1024,768,P3D);
  
  // Libs
  RG.init(this);
  
  // Tools
  toolManager = new ToolManager(this);
  toolMap = new ToolMap(this);
  toolSkis = new ToolSkis(this);

  // Stations
  stations = new StationManager();
  stations.setup();
  stations.printStationIds();

  // Tools
  toolManager.addTool ( (Tool) toolMap ); 
  toolManager.addTool ( (Tool) toolSkis ); 

  // Controls
  toolManager.initControls(this);

  // Set up tools
  toolManager.setup();

  // Default tool open
  toolManager.select(toolMap);
  
  // Shortcut
  map = toolMap.carte;
}

// --------------------------------------------------------------------
// draw()
// --------------------------------------------------------------------
void draw()
{
  toolManager.draw();
}

// --------------------------------------------------------------------
// mousePressed()
// --------------------------------------------------------------------
void mousePressed()
{
  toolManager.mousePressed();
}

// --------------------------------------------------------------------
// mouseDragged()
// --------------------------------------------------------------------
void mouseDragged()
{
  toolManager.mouseDragged();
}


// --------------------------------------------------------------------
// keyPressed
// --------------------------------------------------------------------
void keyPressed()
{
  toolManager.keyPressed();
}

// --------------------------------------------------------------------
// controlEvent
// --------------------------------------------------------------------
void controlEvent(ControlEvent theEvent) 
{
  if (theEvent.isTab()){
    toolManager.select(theEvent.tab().id());
  }
}

