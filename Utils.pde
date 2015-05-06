// ------------------------------------------------
// timestamp
// ------------------------------------------------
String timestamp() 
{
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}


// ------------------------------------------------
// 
// ------------------------------------------------
float getRatio(PGraphics g_)
{
  return float(g_.width) / float(g_.height);
}

// ------------------------------------------------
// PanelZoom
// ------------------------------------------------
class PanelZoom
{
  float zoom;
  float scale;
  PVector offset, poffset;
  PVector mouse;

  PanelZoom()
  {
    zoom = 1.0;
    offset = new PVector(0, 0);
    poffset = new PVector(0, 0);
  }
  
  void setZoom(float zoom_)
  {
    zoom = zoom_;
  }
  
  
  void begin()
  {
    pushMatrix();
    translate(width/2, height/2);
    scale(zoom);
    translate(offset.x/zoom, offset.y/zoom);
  }
  
  void end()
  {
    popMatrix();
  }


  void mousePressed()
  {
    mouse = new PVector(mouseX, mouseY);
    poffset.set(offset);
  }

  void mouseDragged() {
    offset.x = mouseX - mouse.x + poffset.x;
    offset.y = mouseY - mouse.y + poffset.y;
  }
  
  
}
