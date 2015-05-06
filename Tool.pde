class Tool implements ControlListener
{
  PApplet applet=null;
  int id = 0;
  String tabName = "";
  
  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  Tool(PApplet p)
  {
    this.applet = p;
  }
  
  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void setup(){}
  void update(){}
  void draw(){}
  void select(){}
  void unselect(){}
  void mousePressed(){}
  void mouseDragged(){}
  void keyPressed(){}

  void initControls()
  {
    cp5.tab(tabName).activateEvent(true);
    cp5.tab(tabName).setHeight(20);
    cp5.tab(tabName).captionLabel().style().marginTop = 2;
    cp5.tab(tabName).setId(id);
    cp5.tab(tabName).setLabel(tabName);
  }
  public void controlEvent(ControlEvent theEvent) {}
}

class ToolManager extends ArrayList<Tool>
{
  PApplet applet=null;
  Tool toolSelected = null;
  int idTool = 0;
  
  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  ToolManager(PApplet applet)
  {
    this.applet = applet;
  }
  
  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void addTool(Tool t)
  {
    add(t);
    t.id = ++idTool;
    println(t.id);
  }  
  
  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void setup()
  {
    for (Tool t:this)
    t.setup();

    toolSelected = get(0);
  }
  
  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void initControls(PApplet p)
  {
    cp5 = new ControlP5(p);
    //cp5.setFont(createFont("helvetica",10));

    for (Tool t : this)
      t.initControls();
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void update()
  {
    for (Tool tool : this)
      tool.update();
  }
  
  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void draw()
  {
    if (toolSelected != null){
      pushStyle();
      toolSelected.draw();
      popStyle();
    }
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  Tool getTool(int id)
  {
    Tool t = null;
    for (int i=0;i<size();i++){
      t = get(i);
      if (t.id == id) break;
    }
    return t;
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void select(Tool which)
  {
    select(which.id);  
    cp5.window(applet).activateTab(which.tabName);
  }
  
  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void select(int id)
  {
    Tool t = getTool(id);
    if (t != toolSelected){
      toolSelected = t;
      t.select();
    }
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void mousePressed()
  {
    if (toolSelected !=null)
      toolSelected.mousePressed();
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void mouseDragged()
  {
    if (toolSelected !=null)
      toolSelected.mouseDragged();
  }

  
  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void keyPressed()
  {
    if (toolSelected !=null)
      toolSelected.keyPressed();
  }
}
