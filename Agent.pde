// --------------------------------------------------------------------
// --------------------------------------------------------------------
class AttractionPoint extends PVector
{
  float radius = 500.0;
  Station station = null;
  AttractionPoint(Station station_)
  {
    this.station = station_;
  }
}

// --------------------------------------------------------------------
// --------------------------------------------------------------------
class Agent
{
  PVector pos, vel, followSum, escapeSum;
  color c;

  ArrayList<AttractionPoint> attrPoints = null;
  ArrayList<AttractionPoint> repPoints = null;


  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  Agent(int _x, int _y)
  {
    pos=new PVector(_x, _y); 
    vel=new PVector(0, 0);
    followSum=new PVector(0, 0);
    escapeSum=new PVector(0, 0);
    c=color(255, 255, 255);
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void setAttrPoints(ArrayList<AttractionPoint> list_)
  {
    attrPoints = list_;
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void setRepPoints(ArrayList<AttractionPoint> list_)
  {
    repPoints = list_;
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void move()
  {
    vel.add(follow());
    vel.add(escape());
    vel.limit(1);
    pos.add(vel); 
/*    if (pos.x>width || pos.x<0) {
      vel.x = - vel.x;
    }

    if (pos.y>height || pos.y<0) {
      vel.y = - vel.y;
    }
*/  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void display()
  {
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  void display(PGraphics pg)
  {
    pg.ellipse(pos.x,pos.y,5,5);
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  PVector follow()
  {///////////attraction force
    followSum.mult(0);
    if (attrPoints == null) return followSum;

    int count=0;
    for (int i=0; i<attrPoints.size();i++) {
      AttractionPoint aPt=attrPoints.get(i);
      float d=pos.dist(aPt);
      if (d<aPt.radius) {//attraction distance
        PVector dir = PVector.sub(aPt, pos);
        dir.normalize();
        dir.div(d);
        followSum.add(dir);
        count++;
      }
    } 
    if (count > 0) {
      followSum.div(count);
    }
    return followSum;
  }

  // --------------------------------------------------------------------
  // --------------------------------------------------------------------
  PVector escape()
  {///////////repulsion force
    escapeSum.mult(0);
    if (repPoints == null) return escapeSum;
    int count=0;
    for (int i=0; i<repPoints.size();i++) {
      AttractionPoint rPt=repPoints.get(i);
      float d=pos.dist(rPt);
      if (d<rPt.radius) {//repulsion distance
        PVector dir = PVector.sub(rPt, pos);
        dir.normalize();
        dir.div(d);
        escapeSum.sub(dir);
        count++;
      }
    } 
    if (count > 0) {
      escapeSum.div(count);
    }
    return escapeSum;
  }
}

