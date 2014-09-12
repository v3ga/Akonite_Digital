// --------------------------------------------
DocumentExcel loadDocumentExcel(String name, String path)
{
  DocumentExcel document = new DocumentExcel(name, path);
  document.load();
  return document;
}

// --------------------------------------------
class DocumentExcel
{
  String name;
  String path;
  Workbook workbook = null;
  Sheet sheet;

  int nbColumns = 0;
  int nbRows = 0;

  HashMap<String, Integer> header;


  // --------------------------------------------
  DocumentExcel(String name_, String path_)
  {
    this.name = name_;
    this.path = path_;
  }


  // --------------------------------------------
  void load()
  {
    InputStream file;
    try 
    {
      file = new FileInputStream(this.path);
      this.workbook = WorkbookFactory.create(file);
      this.sheet = this.workbook.getSheetAt(0);

      println("- loaded "+this.path);

      this.nbRows = this.sheet.getLastRowNum();
      this.nbColumns = this.getColumnNb();

      println(" - num lines : "+this.nbRows);
      println(" - num cols : "+this.nbColumns);

      header = new HashMap<String, Integer>(this.nbColumns);
      Row rowHeader = sheet.getRow(0);
      for (int col=0; col<nbColumns; col++)
      {
        header.put( getCellContent(rowHeader, col).toLowerCase(), col );
      }
    }
    catch(Exception e) 
    {
      println("- ERROR : "+e);
    }
  }

  // --------------------------------------------
  String getCellContent(Row row, int col)
  {
    if (row != null && col<this.nbColumns) {
      Cell cell = row.getCell(col);
      if (cell != null)
      {
        if (cell.getCellType() == Cell.CELL_TYPE_STRING)        
          return cell.getStringCellValue();
        else if (cell.getCellType() == Cell.CELL_TYPE_NUMERIC)
          return Double.toString( cell.getNumericCellValue() );
      }
    }  
    return "";
  }

  // --------------------------------------------
  String getCellContent(int row, int col)
  {
    if (sheet != null && row<this.nbRows)
      return this.getCellContent(sheet.getRow(row), col);
    return "";
  }

  // --------------------------------------------
  String getCellContent(int row, String colName) {
    Integer col = header.get(colName.toLowerCase());
    if (col != null) {
      return getCellContent(row, col);
    }
    return "";
  }

  // --------------------------------------------
  int getColumnNb()
  {
    int nbCols = 0;
    for (int i=0;i<this.nbRows;i++) 
    {
      Row row = this.sheet.getRow(i);
      if (row != null)
      {
        int nb = row.getLastCellNum();
        if (nb>nbCols) nbCols = nb;
      }
    }
    return nbCols;
  }
}

