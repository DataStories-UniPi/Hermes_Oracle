Prompt Package Body VISUALIZER;
CREATE OR REPLACE PACKAGE BODY VISUALIZER
AS
  -- Replaces All Code Occurrences Of A String With Another Within A CLOB
  -- 1) clob src - the CLOB source to be replaced.
  -- 2) replace str - the string to be replaced.
  -- 3) replace with - the replacement string.
FUNCTION replaceClob(
    srcClob     IN CLOB,
    replaceStr  IN VARCHAR2,
    replaceWith IN VARCHAR2)
  RETURN CLOB
IS
  vBuffer VARCHAR2 (32767);
  l_amount BINARY_INTEGER := 32767;
  l_pos PLS_INTEGER       := 1;
  l_clob_len PLS_INTEGER;
  newClob CLOB := EMPTY_CLOB;
BEGIN
  -- initalize the new clob
  dbms_lob.createtemporary(newClob,TRUE);
  l_clob_len  := dbms_lob.getlength(srcClob);
  WHILE l_pos <= l_clob_len
  LOOP
    dbms_lob.read(srcClob, l_amount, l_pos, vBuffer);
    IF vBuffer IS NOT NULL THEN
      -- replace the text
      vBuffer := REPLACE(vBuffer, replaceStr, replaceWith);
      -- write it to the new clob
      dbms_lob.writeappend(newClob, LENGTH(vBuffer), vBuffer);
    END IF;
    l_pos := l_pos + l_amount;
  END LOOP;
  RETURN newClob;
EXCEPTION
WHEN OTHERS THEN
  RAISE;
END;
PROCEDURE Polygon2KML(
    geom MDSYS.SDO_GEOMETRY,
    outSRID    INTEGER,
    outKMLfile VARCHAR2)
IS
  --geom MDSYS.SDO_GEOMETRY;
  TRANSgeom MDSYS.SDO_GEOMETRY;
  KMLpolygon CLOB;
  xsldoc CLOB;
  kmldoc CLOB;
  myParser DBMS_XMLPARSER.parser;
  kmldomdoc DBMS_XMLDOM.DOMDocument;
  xsltdomdoc DBMS_XMLDOM.DOMDocument;
  xsl DBMS_XSLPROCESSOR.stylesheet;
  outdomdocf DBMS_XMLDOM.DOMDocumentFragment;
  outnode DBMS_XMLDOM.DOMNode;
  PROC DBMS_XSLPROCESSOR.processor;
  CLOBsubstitution CLOB;
  final CLOB;
  substitution VARCHAR2(32767);
  CLOBsize     INTEGER;
  pattern      VARCHAR2(3);
  offset       INTEGER;
  occur        INTEGER;
  position     INTEGER;
  b            BOOLEAN;
BEGIN
  /*geom := SDO_GEOMETRY(2003, 2100, NULL, SDO_ELEM_INFO_ARRAY(1,1003,3), SDO_ORDINATE_ARRAY(530000,4115000,
  540000,4125000));*/
  TRANSgeom := MDSYS.SDO_CS.TRANSFORM (geom, outSRID);
  --GMLpolygon := MDSYS.SDO_UTIL.TO_GMLGEOMETRY(TRANSgeom);
  --DBMS_OUTPUT.PUT_LINE('GML RANGE QUERY = ' || TO_CHAR(GMLpolygon));
  KMLpolygon := MDSYS.SDO_UTIL.TO_KMLGEOMETRY(TRANSgeom);
  --DBMS_OUTPUT.PUT_LINE('KML RANGE QUERY = ' || TO_CHAR(KMLpolygon));
  dbms_xslprocessor.clob2file(KMLpolygon, 'GML2KML', 'OracleKMLpolygonCLOB.txt');
  --KMLpolygon := dbms_xslprocessor.read2clob ('GML2KML', 'OracleKMLpolygonCLOB.txt'); -- Obviously not necessary!
  xsldoc   := dbms_xslprocessor.read2clob ('GML2KML', 'PolygonToCoords.xslt');
  myParser := DBMS_XMLPARSER.newParser;
  DBMS_XMLPARSER.parseCLOB(myParser, KMLpolygon);
  kmldomdoc := DBMS_XMLPARSER.getDocument(myParser);
  DBMS_XMLPARSER.parseCLOB(myParser, xsldoc);
  xsltdomdoc := DBMS_XMLPARSER.getDocument(myParser);
  xsl        := DBMS_XSLPROCESSOR.newStyleSheet(xsltdomdoc, '');
  PROC       := DBMS_XSLPROCESSOR.newProcessor;
  --apply stylesheet to DOM document
  outdomdocf := DBMS_XSLPROCESSOR.processXSL(PROC, xsl, kmldomdoc);
  outnode    := DBMS_XMLDOM.makeNode(outdomdocf); -- Put this to KML template
  --output <coordinates ... /coordinates>
  DBMS_XMLDOM.writeToBuffer(outnode, CLOBsubstitution);
  dbms_xslprocessor.clob2file(CLOBsubstitution, 'GML2KML', 'coordinates.txt');--DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
  --Compute the length of the CLOB that will replace the pattern
  CLOBsize := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
  --load KML TEMPLATE file
  kmldoc := dbms_xslprocessor.read2clob ('GML2KML', 'polygon_template.kml');--DBMS_OUTPUT.PUT_LINE('kmldoc = ' || TO_CHAR(kmldoc));
  --Find 'XXX' pattern inside template kml
  pattern  := 'XXX';
  occur    := 1;
  offset   := 1;
  position := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset); --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
  --Transform CLOB to VARCHAR2
  substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
  INSERT INTO securefile_tab VALUES
    (1, kmldoc
    );
  SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
  /*b := dbms_lob.issecurefile(kmldoc);
  IF b THEN dbms_output.put_line('Stored in a securefile');
  ELSE dbms_output.put_line('Not stored in a securefile'); END IF;*/
  --Replace the pattern with the 'coords' xml
  DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 3, CLOBsize, position, substitution);
  -- FINALLY write to disk the transformed KML file
  dbms_xslprocessor.clob2file(kmldoc, 'GML2KML', outKMLfile||'.kml');--dbms_xslprocessor.clob2file(kmldoc, 'GML2KML', 'FINAL.kml');
  DELETE securefile_tab;
  -- FREE
  DBMS_XMLDOM.freeDocument(kmldomdoc);
  DBMS_XMLDOM.freeDocument(xsltdomdoc);
  DBMS_XMLDOM.freeDocFrag(outdomdocf);
  DBMS_XMLPARSER.freeParser(myParser);
  DBMS_XSLPROCESSOR.freeProcessor(PROC);
END;
PROCEDURE Polygon2Volume3D2KML(
    geom MDSYS.SDO_GEOMETRY,
    outSRID    INTEGER,
    outKMLfile VARCHAR2,
    altitude   NUMBER)
IS
  --geom MDSYS.SDO_GEOMETRY;
  TRANSgeom MDSYS.SDO_GEOMETRY;
  KMLpolygon CLOB;
  xsldoc CLOB;
  kmldoc CLOB;
  myParser DBMS_XMLPARSER.parser;
  kmldomdoc DBMS_XMLDOM.DOMDocument;
  xsltdomdoc DBMS_XMLDOM.DOMDocument;
  xsl DBMS_XSLPROCESSOR.stylesheet;
  outdomdocf DBMS_XMLDOM.DOMDocumentFragment;
  outnode DBMS_XMLDOM.DOMNode;
  PROC DBMS_XSLPROCESSOR.processor;
  CLOBsubstitution CLOB;
  final CLOB;
  substitution VARCHAR2(32767);
  CLOBsize     INTEGER;
  pattern      VARCHAR2(3);
  offset       INTEGER;
  occur        INTEGER;
  position     INTEGER;
  b            BOOLEAN;
  height       VARCHAR2(20);
BEGIN
  /*geom := SDO_GEOMETRY(2003, 2100, NULL, SDO_ELEM_INFO_ARRAY(1,1003,3), SDO_ORDINATE_ARRAY(530000,4115000,
  540000,4125000));*/
  TRANSgeom := MDSYS.SDO_CS.TRANSFORM (geom, outSRID);
  --GMLpolygon := MDSYS.SDO_UTIL.TO_GMLGEOMETRY(TRANSgeom);
  --DBMS_OUTPUT.PUT_LINE('GML RANGE QUERY = ' || TO_CHAR(GMLpolygon));
  KMLpolygon := MDSYS.SDO_UTIL.TO_KMLGEOMETRY(TRANSgeom);
  --DBMS_OUTPUT.PUT_LINE('KML RANGE QUERY = ' || TO_CHAR(KMLpolygon));
  dbms_xslprocessor.clob2file(KMLpolygon, 'GML2KML', 'OracleKMLpolygonCLOB.txt');
  --KMLpolygon := dbms_xslprocessor.read2clob ('GML2KML', 'OracleKMLpolygonCLOB.txt'); -- Obviously not necessary!
  xsldoc   := dbms_xslprocessor.read2clob ('GML2KML', 'PolygonToCoords.xslt');
  myParser := DBMS_XMLPARSER.newParser;
  DBMS_XMLPARSER.parseCLOB(myParser, KMLpolygon);
  kmldomdoc := DBMS_XMLPARSER.getDocument(myParser);
  DBMS_XMLPARSER.parseCLOB(myParser, xsldoc);
  xsltdomdoc := DBMS_XMLPARSER.getDocument(myParser);
  xsl        := DBMS_XSLPROCESSOR.newStyleSheet(xsltdomdoc, '');
  PROC       := DBMS_XSLPROCESSOR.newProcessor;
  --apply stylesheet to DOM document
  outdomdocf := DBMS_XSLPROCESSOR.processXSL(PROC, xsl, kmldomdoc);
  outnode    := DBMS_XMLDOM.makeNode(outdomdocf); -- Put this to KML template
  --output <coordinates ... /coordinates>
  DBMS_XMLDOM.writeToBuffer(outnode, CLOBsubstitution);
  dbms_xslprocessor.clob2file(CLOBsubstitution, 'GML2KML', 'coordinates.txt');--DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
  --FROM HERE
  --REPLACE SPACES (i.e. ' ') with altitude information
  height := ',' || TO_CHAR(altitude) || ' ';
  DBMS_OUTPUT.PUT_LINE('altitude = ' || height);
  CLOBsubstitution := replaceClob (CLOBsubstitution, ' ', height);
  DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
  --TILL HERE
  --Compute the length of the CLOB that will replace the pattern
  CLOBsize := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
  --load KML TEMPLATE file
  kmldoc := dbms_xslprocessor.read2clob ('GML2KML', 'volume3D_template.kml');--DBMS_OUTPUT.PUT_LINE('kmldoc = ' || TO_CHAR(kmldoc));
  --Find 'XXX' pattern inside template kml
  pattern  := 'XXX';
  occur    := 1;
  offset   := 1;
  position := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset); --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
  --Transform CLOB to VARCHAR2
  substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
  INSERT INTO securefile_tab VALUES
    (1, kmldoc
    );
  SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
  /*b := dbms_lob.issecurefile(kmldoc);
  IF b THEN dbms_output.put_line('Stored in a securefile');
  ELSE dbms_output.put_line('Not stored in a securefile'); END IF;*/
  --Replace the pattern with the 'coords' xml
  DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 3, CLOBsize, position, substitution);
  -- FINALLY write to disk the transformed KML file
  dbms_xslprocessor.clob2file(kmldoc, 'GML2KML', outKMLfile);--dbms_xslprocessor.clob2file(kmldoc, 'GML2KML', 'FINAL.kml');
  DELETE securefile_tab;
  -- FREE
  DBMS_XMLDOM.freeDocument(kmldomdoc);
  DBMS_XMLDOM.freeDocument(xsltdomdoc);
  DBMS_XMLDOM.freeDocFrag(outdomdocf);
  DBMS_XMLPARSER.freeParser(myParser);
  DBMS_XSLPROCESSOR.freeProcessor(PROC);
END;
PROCEDURE Linestring2KML(
    geom MDSYS.SDO_GEOMETRY,
    outSRID    INTEGER,
    outKMLfile VARCHAR2)
IS
  --mp hermes.Moving_Point;
  --geom MDSYS.SDO_GEOMETRY;
  TRANSgeom MDSYS.SDO_GEOMETRY;
  KMLpath CLOB;
  xsldoc CLOB;
  kmldoc CLOB;
  myParser DBMS_XMLPARSER.parser;
  kmldomdoc DBMS_XMLDOM.DOMDocument;
  xsltdomdoc DBMS_XMLDOM.DOMDocument;
  xsl DBMS_XSLPROCESSOR.stylesheet;
  outdomdocf DBMS_XMLDOM.DOMDocumentFragment;
  outnode DBMS_XMLDOM.DOMNode;
  PROC DBMS_XSLPROCESSOR.processor;
  CLOBsubstitution CLOB;
  final CLOB;
  substitution VARCHAR2(32767);
  CLOBsize     INTEGER;
  pattern      VARCHAR2(3);
  offset       INTEGER;
  occur        INTEGER;
  position     INTEGER;
  b            BOOLEAN;
BEGIN
  /*geom := SDO_GEOMETRY(2003, 2100, NULL, SDO_ELEM_INFO_ARRAY(1,1003,3), SDO_ORDINATE_ARRAY(530000,4115000,
  540000,4125000));
  SELECT a.mpoint INTO mp
  FROM mpoints a
  WHERE a.object_id=377281000 and a.traj_id=94;
  geom := mp.route();*/
  TRANSgeom := MDSYS.SDO_CS.TRANSFORM (geom, outSRID);
  --GMLpolygon := MDSYS.SDO_UTIL.TO_GMLGEOMETRY(TRANSgeom);
  --DBMS_OUTPUT.PUT_LINE('GML RANGE QUERY = ' || TO_CHAR(GMLpolygon));
  KMLpath := MDSYS.SDO_UTIL.TO_KMLGEOMETRY(TRANSgeom);
  --DBMS_OUTPUT.PUT_LINE('KML RANGE QUERY = ' || TO_CHAR(KMLpath));
  dbms_xslprocessor.clob2file(KMLpath, 'GML2KML', 'OracleKMLpathCLOB.txt');
  --KMLpath := dbms_xslprocessor.read2clob ('GML2KML', 'OracleKMLpathCLOB.txt'); -- Obviously not necessary!
  xsldoc   := dbms_xslprocessor.read2clob ('GML2KML', 'LinestringToCoords.xslt');
  myParser := DBMS_XMLPARSER.newParser;
  DBMS_XMLPARSER.parseCLOB(myParser, KMLpath);
  kmldomdoc := DBMS_XMLPARSER.getDocument(myParser);
  DBMS_XMLPARSER.parseCLOB(myParser, xsldoc);
  xsltdomdoc := DBMS_XMLPARSER.getDocument(myParser);
  xsl        := DBMS_XSLPROCESSOR.newStyleSheet(xsltdomdoc, '');
  PROC       := DBMS_XSLPROCESSOR.newProcessor;
  --apply stylesheet to DOM document
  outdomdocf := DBMS_XSLPROCESSOR.processXSL(PROC, xsl, kmldomdoc);
  outnode    := DBMS_XMLDOM.makeNode(outdomdocf); -- Put this to KML template
  --output <coordinates ... /coordinates>
  DBMS_XMLDOM.writeToBuffer(outnode, CLOBsubstitution);
  dbms_xslprocessor.clob2file(CLOBsubstitution, 'GML2KML', 'coordinates.txt');--DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
  --Compute the length of the CLOB that will replace the pattern
  CLOBsize := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
  --load KML TEMPLATE file
  kmldoc := dbms_xslprocessor.read2clob ('GML2KML', 'path_template.kml');--DBMS_OUTPUT.PUT_LINE('kmldoc = ' || TO_CHAR(kmldoc));
  --Find 'XXX' pattern inside template kml
  pattern  := 'XXX';
  occur    := 1;
  offset   := 1;
  position := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset); --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
  --Transform CLOB to VARCHAR2
  substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
  INSERT INTO securefile_tab VALUES
    (1, kmldoc
    );
  SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
  /*b := dbms_lob.issecurefile(kmldoc);
  IF b THEN dbms_output.put_line('Stored in a securefile');
  ELSE dbms_output.put_line('Not stored in a securefile'); END IF;*/
  --Replace the pattern with the 'coords' xml
  DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 3, CLOBsize, position, substitution);
  -- FINALLY write to disk the transformed KML file
  dbms_xslprocessor.clob2file(kmldoc, 'GML2KML', outKMLfile);
  DELETE securefile_tab;
  -- FREE
  DBMS_XMLDOM.freeDocument(kmldomdoc);
  DBMS_XMLDOM.freeDocument(xsltdomdoc);
  DBMS_XMLDOM.freeDocFrag(outdomdocf);
  DBMS_XMLPARSER.freeParser(myParser);
  DBMS_XSLPROCESSOR.freeProcessor(PROC);
END;

PROCEDURE Placemark2KML(
    geom MDSYS.SDO_GEOMETRY,
    outSRID    INTEGER,
    outKMLfile VARCHAR2,
    message1   VARCHAR2,
    message2   VARCHAR2)
IS
  --mp hermes.Moving_Point;
  --geom MDSYS.SDO_GEOMETRY;
  TRANSgeom MDSYS.SDO_GEOMETRY;
  KMLpath CLOB;
  xsldoc CLOB;
  kmldoc CLOB;
  myParser DBMS_XMLPARSER.parser;
  kmldomdoc DBMS_XMLDOM.DOMDocument;
  xsltdomdoc DBMS_XMLDOM.DOMDocument;
  xsl DBMS_XSLPROCESSOR.stylesheet;
  outdomdocf DBMS_XMLDOM.DOMDocumentFragment;
  outnode DBMS_XMLDOM.DOMNode;
  PROC DBMS_XSLPROCESSOR.processor;
  CLOBsubstitution CLOB;
  final CLOB;
  substitution VARCHAR2(32767);
  CLOBsize     INTEGER;
  pattern      VARCHAR2(3);
  offset       INTEGER;
  occur        INTEGER;
  position     INTEGER;
  b            BOOLEAN;
  msg1         VARCHAR2(200);
  msg2         VARCHAR2(200);
BEGIN
  /*  SELECT a.mpoint INTO mp
  FROM mpoints a
  WHERE a.object_id=377281000 and a.traj_id=94;
  geom := mp.f_initial();*/
  /*select m.mpoint.at_instant(tau_tll.d_timepoint_sec(2010,2,19,10,45,0)) INTO geom from hermes.mpoints m
  where m.object_id IN (259898000) ;*/
  --geom := MDSYS.SDO_GEOMETRY (2001,2100,sdo_point_type (545000,4200000, NULL),NULL,NULL);
  TRANSgeom := MDSYS.SDO_CS.TRANSFORM (geom, outSRID);
  --GMLpolygon := MDSYS.SDO_UTIL.TO_GMLGEOMETRY(TRANSgeom);
  --DBMS_OUTPUT.PUT_LINE('GML RANGE QUERY = ' || TO_CHAR(GMLpolygon));
  KMLpath := MDSYS.SDO_UTIL.TO_KMLGEOMETRY(TRANSgeom);
  --DBMS_OUTPUT.PUT_LINE('KML RANGE QUERY = ' || TO_CHAR(KMLpath));
  dbms_xslprocessor.clob2file(KMLpath, 'GML2KML', 'OracleKMLplacemarkCLOB.txt');
  --KMLpath := dbms_xslprocessor.read2clob ('GML2KML', 'OracleKMLplacemarkCLOB.txt'); -- Obviously not necessary!
  xsldoc   := dbms_xslprocessor.read2clob ('GML2KML', 'PlacemarkToCoords.xslt');
  myParser := DBMS_XMLPARSER.newParser;
  DBMS_XMLPARSER.parseCLOB(myParser, KMLpath);
  kmldomdoc := DBMS_XMLPARSER.getDocument(myParser);
  DBMS_XMLPARSER.parseCLOB(myParser, xsldoc);
  xsltdomdoc := DBMS_XMLPARSER.getDocument(myParser);
  xsl        := DBMS_XSLPROCESSOR.newStyleSheet(xsltdomdoc, '');
  PROC       := DBMS_XSLPROCESSOR.newProcessor;
  --apply stylesheet to DOM document
  outdomdocf := DBMS_XSLPROCESSOR.processXSL(PROC, xsl, kmldomdoc);
  outnode    := DBMS_XMLDOM.makeNode(outdomdocf); -- Put this to KML template
  --output <coordinates ... /coordinates>
  DBMS_XMLDOM.writeToBuffer(outnode, CLOBsubstitution);
  dbms_xslprocessor.clob2file(CLOBsubstitution, 'GML2KML', 'coordinates.txt');--DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
  --Compute the length of the CLOB that will replace the pattern
  CLOBsize := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
  --load KML TEMPLATE file
  kmldoc := dbms_xslprocessor.read2clob ('GML2KML', 'SimplePlacemark_template.kml');--DBMS_OUTPUT.PUT_LINE('kmldoc = ' || TO_CHAR(kmldoc));
  --Find 'XXX' pattern inside template kml
  pattern  := 'XXX';
  occur    := 1;
  offset   := 1;
  position := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset); --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
  --Transform CLOB to VARCHAR2
  substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
  INSERT INTO securefile_tab VALUES
    (1, kmldoc
    );
  SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
  /*b := dbms_lob.issecurefile(kmldoc);
  IF b THEN dbms_output.put_line('Stored in a securefile');
  ELSE dbms_output.put_line('Not stored in a securefile'); END IF;*/
  --Replace the pattern with the 'coords' xml
  DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 3, CLOBsize, position, substitution);
  DELETE securefile_tab;
  --NOW THE SAME FOR 'MS1' pattern
  msg1             := message1; --msg1 := 'Point of Interest';
  CLOBsubstitution := TO_CLOB(msg1);
  --Compute the length of the CLOB that will replace the pattern
  CLOBsize := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
  pattern  := 'MS1';
  occur    := 1;
  offset   := 1;
  position := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset); --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
  --Transform CLOB to VARCHAR2
  substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
  INSERT INTO securefile_tab VALUES
    (1, kmldoc
    );
  SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
  --Replace the pattern with the 'coords' xml
  DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 3, CLOBsize, position, substitution);
  DELETE securefile_tab;
  --NOW THE SAME FOR 'MS2' pattern
  msg2             := message2; --msg2 := 'You are too close!!!';
  CLOBsubstitution := TO_CLOB(msg2);
  --Compute the length of the CLOB that will replace the pattern
  CLOBsize := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
  pattern  := 'MS2';
  occur    := 1;
  offset   := 1;
  position := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset); --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
  --Transform CLOB to VARCHAR2
  substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
  INSERT INTO securefile_tab VALUES
    (1, kmldoc
    );
  SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
  --Replace the pattern with the 'coords' xml
  DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 3, CLOBsize, position, substitution);
  DELETE securefile_tab;
  -- FINALLY write to disk the transformed KML file
  dbms_xslprocessor.clob2file(kmldoc, 'GML2KML', outKMLfile||'.kml');
  -- FREE
  DBMS_XMLDOM.freeDocument(kmldomdoc);
  DBMS_XMLDOM.freeDocument(xsltdomdoc);
  DBMS_XMLDOM.freeDocFrag(outdomdocf);
  DBMS_XMLPARSER.freeParser(myParser);
  DBMS_XSLPROCESSOR.freeProcessor(PROC);
END;
PROCEDURE MovingPoint2KML(
    mp hermes.Moving_Point,
    outSRID    INTEGER,
    outKMLfile VARCHAR2)
IS
  --mp hermes.Moving_Point;
  geom MDSYS.SDO_GEOMETRY;
  TRANSgeom MDSYS.SDO_GEOMETRY;
  kmldoc CLOB;
  CLOBsubstitution CLOB;
  final CLOB;
  substitution VARCHAR2(32767);
  CLOBsize     INTEGER;
  pattern      VARCHAR2(4);
  offset       INTEGER := 1;
  occur        INTEGER := 1;
  position     INTEGER;
  i PLS_INTEGER;
  counter PLS_INTEGER;
  b    BOOLEAN;
  ZXID VARCHAR2(20);
  ZXDE VARCHAR2(10);
  XXXX VARCHAR2(4);
  XYE1 VARCHAR2(4);
  XYE2 VARCHAR2(4);
  XMO1 VARCHAR2(2);
  XMO2 VARCHAR2(2);
  XDA1 VARCHAR2(2);
  XDA2 VARCHAR2(2);
  XHO1 VARCHAR2(2);
  XHO2 VARCHAR2(2);
  XMI1 VARCHAR2(2);
  XMI2 VARCHAR2(2);
  XSE1 VARCHAR2(2);
  XSE2 VARCHAR2(2);
  ZXY1 VARCHAR2(40);
  ZXY2 VARCHAR2(40);
  ump  VARCHAR2(350);
BEGIN
  XXXX := 'XXXX';
  /*SELECT a.mpoint INTO mp
  FROM mpoints a
  WHERE a.object_id=271000819;*/
  /*select m.mpoint.at_period(tau_tll.d_period_sec(
  tau_tll.D_Timepoint_Sec(2010,2,19,10,35,0),
  tau_tll.D_Timepoint_Sec(2010,2,19,10,55,0))) INTO mp
  from hermes.mpoints m where m.object_id IN (259898000);-- and traj_id=416;*/
  --load KML TEMPLATE file
  kmldoc  := dbms_xslprocessor.read2clob ('GML2KML', 'MovingPoint_template_SLOW.kml');--DBMS_OUTPUT.PUT_LINE('kmldoc = ' || TO_CHAR(kmldoc));
  counter := 1;
  FOR i IN mp.u_tab.FIRST .. mp.u_tab.LAST
  LOOP
    IF mp IS NULL OR mp.u_tab(i) IS NULL OR mp.u_tab(i).p.b.M_Y IS NULL THEN
      CONTINUE;
    END IF;
    ZXID      := 'IDENTITY!';
    ZXDE      := TO_CHAR(counter);                            --DBMS_OUTPUT.PUT_LINE('ZXDE = ' || ZXDE);
    XYE1      := LPAD(TO_CHAR(mp.u_tab(i).p.b.M_Y), 4,'0');   --DBMS_OUTPUT.PUT_LINE('XYE1 = ' || XYE1);
    XYE2      := LPAD(TO_CHAR(mp.u_tab(i).p.e.M_Y), 4,'0');   --DBMS_OUTPUT.PUT_LINE('XYE2 = ' || XYE2);
    XMO1      := LPAD(TO_CHAR(mp.u_tab(i).p.b.M_M), 2,'0');   --DBMS_OUTPUT.PUT_LINE('ZXDE = ' || ZXDE);
    XMO2      := LPAD(TO_CHAR(mp.u_tab(i).p.e.M_M), 2,'0');   --DBMS_OUTPUT.PUT_LINE('ZXDE = ' || ZXDE);
    XDA1      := LPAD(TO_CHAR(mp.u_tab(i).p.b.M_D), 2,'0');   --DBMS_OUTPUT.PUT_LINE('ZXDE = ' || ZXDE);
    XDA2      := LPAD(TO_CHAR(mp.u_tab(i).p.e.M_D), 2,'0');   --DBMS_OUTPUT.PUT_LINE('ZXDE = ' || ZXDE);
    XHO1      := LPAD(TO_CHAR(mp.u_tab(i).p.b.M_H), 2,'0');   --DBMS_OUTPUT.PUT_LINE('ZXDE = ' || ZXDE);
    XHO2      := LPAD(TO_CHAR(mp.u_tab(i).p.e.M_H), 2,'0');   --DBMS_OUTPUT.PUT_LINE('ZXDE = ' || ZXDE);
    XMI1      := LPAD(TO_CHAR(mp.u_tab(i).p.b.M_MIN), 2,'0'); --DBMS_OUTPUT.PUT_LINE('ZXDE = ' || ZXDE);
    XMI2      := LPAD(TO_CHAR(mp.u_tab(i).p.e.M_MIN), 2,'0'); --DBMS_OUTPUT.PUT_LINE('ZXDE = ' || ZXDE);
    XSE1      := LPAD(TO_CHAR(mp.u_tab(i).p.b.M_SEC), 2,'0'); --DBMS_OUTPUT.PUT_LINE('ZXDE = ' || ZXDE);
    XSE2      := LPAD(TO_CHAR(mp.u_tab(i).p.e.M_SEC), 2,'0'); --DBMS_OUTPUT.PUT_LINE('ZXDE = ' || ZXDE);
    geom      := MDSYS.SDO_GEOMETRY (2001,mp.SRID,sdo_point_type (mp.u_tab(i).m.xi, mp.u_tab(i).m.yi, NULL),NULL,NULL);
    TRANSgeom := MDSYS.SDO_CS.TRANSFORM (geom, outSRID);
    ZXY1      := SUBSTR(REPLACE(TO_CHAR (TRANSgeom.sdo_point.x), ',', '.'), 0, 16) || ',' || SUBSTR(REPLACE(TO_CHAR (TRANSgeom.sdo_point.y), ',', '.'), 0, 16); --DBMS_OUTPUT.PUT_LINE('ZXY1 = ' || TO_CHAR(ZXY1));
    geom      := MDSYS.SDO_GEOMETRY (2001,mp.SRID,sdo_point_type (mp.u_tab(i).m.xe, mp.u_tab(i).m.ye, NULL),NULL,NULL);
    TRANSgeom := MDSYS.SDO_CS.TRANSFORM (geom, outSRID);
    ZXY2      := SUBSTR(REPLACE(TO_CHAR (TRANSgeom.sdo_point.x), ',', '.'), 0, 16) || ',' || SUBSTR(REPLACE(TO_CHAR (TRANSgeom.sdo_point.y), ',', '.'), 0, 16); --DBMS_OUTPUT.PUT_LINE('ZXY2 = ' || TO_CHAR(ZXY2));
    --REPLACE 'ZXID' pattern
    CLOBsubstitution := TO_CLOB(ZXID); --DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
    --IF CLOBsubstitution is null THEN DBMS_OUTPUT.PUT_LINE('There is an error in data! Empty CLOB substitution'); RETURN; END IF;
    CLOBsize     := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
    pattern      := 'ZXID';
    position     := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset);      --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
    substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
    INSERT INTO securefile_tab VALUES
      (1, kmldoc
      );
    SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
    DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 4, CLOBsize, position, substitution);
    DELETE securefile_tab;
    --REPLACE 'ZXDE' pattern
    CLOBsubstitution := TO_CLOB(ZXDE); --DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
    --IF CLOBsubstitution is null THEN DBMS_OUTPUT.PUT_LINE('There is an error in data! Empty CLOB substitution'); RETURN; END IF;
    CLOBsize     := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
    pattern      := 'ZXDE';
    position     := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset);      --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
    substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
    INSERT INTO securefile_tab VALUES
      (1, kmldoc
      );
    SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
    DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 4, CLOBsize, position, substitution);
    DELETE securefile_tab;
    --REPLACE 'XYE1' pattern
    CLOBsubstitution := TO_CLOB(XYE1); --DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
    --IF CLOBsubstitution is null THEN DBMS_OUTPUT.PUT_LINE('There is an error in data! Empty CLOB substitution'); RETURN; END IF;
    CLOBsize     := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
    pattern      := 'XYE1';
    position     := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset);      --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
    substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
    INSERT INTO securefile_tab VALUES
      (1, kmldoc
      );
    SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
    DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 4, CLOBsize, position, substitution);
    DELETE securefile_tab;
    --REPLACE 'XYE2' pattern
    CLOBsubstitution := TO_CLOB(XYE2); --DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
    --IF CLOBsubstitution is null THEN DBMS_OUTPUT.PUT_LINE('There is an error in data! Empty CLOB substitution'); RETURN; END IF;
    CLOBsize     := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
    pattern      := 'XYE2';
    position     := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset);      --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
    substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
    INSERT INTO securefile_tab VALUES
      (1, kmldoc
      );
    SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
    DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 4, CLOBsize, position, substitution);
    DELETE securefile_tab;
    --REPLACE 'XMO1' pattern
    CLOBsubstitution := TO_CLOB(XMO1); --DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
    --IF CLOBsubstitution is null THEN DBMS_OUTPUT.PUT_LINE('There is an error in data! Empty CLOB substitution'); RETURN; END IF;
    CLOBsize     := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
    pattern      := 'XMO1';
    position     := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset);      --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
    substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
    INSERT INTO securefile_tab VALUES
      (1, kmldoc
      );
    SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
    DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 4, CLOBsize, position, substitution);
    DELETE securefile_tab;
    --REPLACE 'XMO2' pattern
    CLOBsubstitution := TO_CLOB(XMO2); --DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
    --IF CLOBsubstitution is null THEN DBMS_OUTPUT.PUT_LINE('There is an error in data! Empty CLOB substitution'); RETURN; END IF;
    CLOBsize     := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
    pattern      := 'XMO2';
    position     := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset);      --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
    substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
    INSERT INTO securefile_tab VALUES
      (1, kmldoc
      );
    SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
    DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 4, CLOBsize, position, substitution);
    DELETE securefile_tab;
    --REPLACE 'XDA1' pattern
    CLOBsubstitution := TO_CLOB(XDA1); --DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
    --IF CLOBsubstitution is null THEN DBMS_OUTPUT.PUT_LINE('There is an error in data! Empty CLOB substitution'); RETURN; END IF;
    CLOBsize     := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
    pattern      := 'XDA1';
    position     := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset);      --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
    substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
    INSERT INTO securefile_tab VALUES
      (1, kmldoc
      );
    SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
    DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 4, CLOBsize, position, substitution);
    DELETE securefile_tab;
    --REPLACE 'XDA2' pattern
    CLOBsubstitution := TO_CLOB(XDA2); --DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
    --IF CLOBsubstitution is null THEN DBMS_OUTPUT.PUT_LINE('There is an error in data! Empty CLOB substitution'); RETURN; END IF;
    CLOBsize     := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
    pattern      := 'XDA2';
    position     := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset);      --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
    substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
    INSERT INTO securefile_tab VALUES
      (1, kmldoc
      );
    SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
    DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 4, CLOBsize, position, substitution);
    DELETE securefile_tab;
    --REPLACE 'XHO1' pattern
    CLOBsubstitution := TO_CLOB(XHO1); --DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
    --IF CLOBsubstitution is null THEN DBMS_OUTPUT.PUT_LINE('There is an error in data! Empty CLOB substitution'); RETURN; END IF;
    CLOBsize     := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
    pattern      := 'XHO1';
    position     := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset);      --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
    substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
    INSERT INTO securefile_tab VALUES
      (1, kmldoc
      );
    SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
    DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 4, CLOBsize, position, substitution);
    DELETE securefile_tab;
    --REPLACE 'XHO2' pattern
    CLOBsubstitution := TO_CLOB(XHO2); --DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
    --IF CLOBsubstitution is null THEN DBMS_OUTPUT.PUT_LINE('There is an error in data! Empty CLOB substitution'); RETURN; END IF;
    CLOBsize     := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
    pattern      := 'XHO2';
    position     := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset);      --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
    substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
    INSERT INTO securefile_tab VALUES
      (1, kmldoc
      );
    SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
    DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 4, CLOBsize, position, substitution);
    DELETE securefile_tab;
    --REPLACE 'XMI1' pattern
    CLOBsubstitution := TO_CLOB(XMI1); --DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
    --IF CLOBsubstitution is null THEN DBMS_OUTPUT.PUT_LINE('There is an error in data! Empty CLOB substitution'); RETURN; END IF;
    CLOBsize     := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
    pattern      := 'XMI1';
    position     := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset);      --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
    substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
    INSERT INTO securefile_tab VALUES
      (1, kmldoc
      );
    SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
    DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 4, CLOBsize, position, substitution);
    DELETE securefile_tab;
    --REPLACE 'XMI2' pattern
    CLOBsubstitution := TO_CLOB(XMI2); --DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
    --IF CLOBsubstitution is null THEN DBMS_OUTPUT.PUT_LINE('There is an error in data! Empty CLOB substitution'); RETURN; END IF;
    CLOBsize     := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
    pattern      := 'XMI2';
    position     := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset);      --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
    substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
    INSERT INTO securefile_tab VALUES
      (1, kmldoc
      );
    SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
    DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 4, CLOBsize, position, substitution);
    DELETE securefile_tab;
    --REPLACE 'XSE1' pattern
    CLOBsubstitution := TO_CLOB(XSE1); --DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
    --IF CLOBsubstitution is null THEN DBMS_OUTPUT.PUT_LINE('There is an error in data! Empty CLOB substitution'); RETURN; END IF;
    CLOBsize     := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
    pattern      := 'XSE1';
    position     := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset);      --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
    substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
    INSERT INTO securefile_tab VALUES
      (1, kmldoc
      );
    SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
    DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 4, CLOBsize, position, substitution);
    DELETE securefile_tab;
    --REPLACE 'XSE2' pattern
    CLOBsubstitution := TO_CLOB(XSE2); --DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
    --IF CLOBsubstitution is null THEN DBMS_OUTPUT.PUT_LINE('There is an error in data! Empty CLOB substitution'); RETURN; END IF;
    CLOBsize     := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
    pattern      := 'XSE2';
    position     := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset);      --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
    substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
    INSERT INTO securefile_tab VALUES
      (1, kmldoc
      );
    SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
    DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 4, CLOBsize, position, substitution);
    DELETE securefile_tab;
    --REPLACE 'ZXY1' pattern
    CLOBsubstitution := TO_CLOB(ZXY1); --DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
    --IF CLOBsubstitution is null THEN DBMS_OUTPUT.PUT_LINE('There is an error in data! Empty CLOB substitution'); RETURN; END IF;
    CLOBsize     := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
    pattern      := 'ZXY1';
    position     := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset);      --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
    substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
    INSERT INTO securefile_tab VALUES
      (1, kmldoc
      );
    SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
    DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 4, CLOBsize, position, substitution);
    DELETE securefile_tab;
    --REPLACE 'ZXY2' pattern
    CLOBsubstitution := TO_CLOB(ZXY2); --DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
    --IF CLOBsubstitution is null THEN DBMS_OUTPUT.PUT_LINE('There is an error in data! Empty CLOB substitution'); RETURN; END IF;
    CLOBsize     := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
    pattern      := 'ZXY2';
    position     := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset);      --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
    substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
    INSERT INTO securefile_tab VALUES
      (1, kmldoc
      );
    SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
    DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 4, CLOBsize, position, substitution);
    DELETE securefile_tab;
    -- NOW UPDATE TEMPLATE KML FILE
    IF i   < mp.u_tab.LAST THEN
      ump := '<Placemark><name>ID: ZXID</name><description>ZXDE</description><TimeSpan><begin>XYE1-XMO1-XDA1TXHO1:XMI1:XSE1Z</begin><end>XYE2-XMO2-XDA2TXHO2:XMI2:XSE2Z</end></TimeSpan><styleUrl>#blueLine</styleUrl><LineString><altitudeMode>relative</altitudeMode><coordinates>ZXY1,0 ZXY2,0</coordinates></LineString></Placemark>' || CHR(10) || XXXX;
    ELSE
      ump := ' ';
    END IF;--DBMS_OUTPUT.PUT_LINE('ump = ' || TO_CHAR(ump));
    --REPLACE ump pattern
    CLOBsubstitution := TO_CLOB(ump); --DBMS_OUTPUT.PUT_LINE('CLOBsubstitution = ' || TO_CHAR(CLOBsubstitution));
    --IF CLOBsubstitution is null THEN DBMS_OUTPUT.PUT_LINE('There is an error in data! Empty CLOB substitution'); RETURN; END IF;
    CLOBsize     := DBMS_LOB.GETLENGTH(CLOBsubstitution); --DBMS_OUTPUT.PUT_LINE('CLOBsize = ' || TO_CHAR(CLOBsize));
    pattern      := 'XXXX';
    position     := DBMS_LOB.INSTR(kmldoc, pattern, occur, offset);      --DBMS_OUTPUT.PUT_LINE('position = ' || TO_CHAR(position));
    substitution := DBMS_LOB.SUBSTR(CLOBsubstitution, CLOBsize, offset); --DBMS_OUTPUT.PUT_LINE('substitution = ' || substitution);
    INSERT INTO securefile_tab VALUES
      (1, kmldoc
      );
    SELECT clob_data INTO kmldoc FROM securefile_tab WHERE id = 1 FOR UPDATE;
    DBMS_LOB.FRAGMENT_REPLACE (kmldoc, 4, CLOBsize, position, substitution);
    DELETE securefile_tab;
    counter := counter + 1;
  END LOOP;
  -- FINALLY write to disk the transformed KML file
  dbms_xslprocessor.clob2file(kmldoc, 'GML2KML', outKMLfile||'.kml');
END;



PROCEDURE MovingPointTable2WKT(mps mp_array, outWKTfile VARCHAR2, table_name VARCHAR2)
IS
  mp hermes.Moving_Point;
  geom MDSYS.SDO_GEOMETRY;
  txtdoc CLOB;
TYPE CursorType
IS
  REF
  CURSOR;
    cv1 CursorType;
    cv2 CursorType;
  TYPE ID
IS
  TABLE OF INTEGER;
  OBJ_IDs ID;
  TRAJ_IDs ID;
  k pls_integer;
  j pls_integer;
  sql_stm varchar2(2000);
BEGIN
  --load KML TEMPLATE file
  --txtdoc := dbms_xslprocessor.read2clob ('GML2KML', 'MovingPoint_template.kml');--DBMS_OUTPUT.PUT_LINE('txtdoc = ' || TO_CHAR(txtdoc));
  txtdoc := ' ';
  IF mps IS NULL THEN
    IF NOT cv1%ISOPEN THEN
      open cv1 for
      'SELECT DISTINCT OBJECT_ID FROM '||table_name||' ORDER BY OBJECT_ID';
    FETCH cv1 BULK COLLECT INTO OBJ_IDs;
  END IF;
ELSE
  IF NOT cv1%ISOPEN THEN
    OPEN cv1 FOR SELECT 1 FROM DUAL;
    FETCH cv1 BULK COLLECT INTO OBJ_IDs;
  END IF;
END IF;
FOR k IN OBJ_IDs.FIRST .. OBJ_IDs.LAST
LOOP
  IF mps IS NULL THEN
    IF NOT cv2%ISOPEN THEN
      open cv2 for
      'SELECT DISTINCT TRAJ_ID FROM '||table_name||' WHERE OBJECT_ID = '||OBJ_IDs(k);
      FETCH cv2 BULK COLLECT INTO TRAJ_IDs;
    END IF;
  ELSE
    IF NOT cv2%ISOPEN THEN
      OPEN cv2 FOR
      SELECT DISTINCT p.traj_id FROM TABLE(mps) p;
      FETCH cv2 BULK COLLECT INTO TRAJ_IDs;
    END IF;
  END IF;
  FOR j IN TRAJ_IDs.FIRST .. TRAJ_IDs.LAST
  LOOP
    --dbms_output.put_line('TRAJ_ID='||TO_CHAR(TRAJ_IDs(j)) ||'   OBJ_ID='|| OBJ_IDs(k));
    if mps is null then
      sql_stm := 'select a.mpoint from '||table_name||' a where a.OBJECT_ID = '||obj_ids(k)||' and a.TRAJ_ID = '||traj_ids(j);
      execute immediate sql_stm into mp;
    ELSE
      SELECT moving_point(p.u_tab, p.traj_id, p.srid)
      INTO mp
      FROM TABLE(mps) p
      WHERE p.TRAJ_ID = TRAJ_IDs(j);
    END IF;
    IF mp IS NULL THEN
      CONTINUE;
    END IF;
    geom := mp.route();
    --dbms_output.put_line('WKT='|| TO_CHAR(geom.Get_WKT()));
    dbms_lob.append(txtdoc, TO_CLOB(geom.Get_WKT() || CHR(13) || CHR(10)));
  END LOOP;
  CLOSE cv2;
END LOOP;
CLOSE cv1;
-- FINALLY write to disk the txt file
dbms_xslprocessor.clob2file(txtdoc, 'GML2KML', outWKTfile||'.wkt');
--commit;
END;

PROCEDURE MovingPointTable2TXT(mps mp_array, outTXTfile VARCHAR2, table_name VARCHAR2) is
    mp hermes.Moving_Point;
    TRANSgeom MDSYS.SDO_GEOMETRY;
    txtdoc     CLOB;
    i          PLS_INTEGER;
    T_ID  VARCHAR2(20);
    XYTs  VARCHAR2(10);
    XY  VARCHAR2(50);
    TP  VARCHAR2(50);
    SRID pls_integer;
    TYPE CursorType IS REF CURSOR;
    cv1 CursorType;
    cv2 CursorType;
    TYPE ID IS TABLE OF INTEGER;
    OBJ_IDs ID;
    TRAJ_IDs ID;
    k pls_integer;
    j pls_integer;
    counter pls_integer := 0;
    sql_stm varchar2(2000);
   BEGIN
    txtdoc := ' ';
    IF mps IS NULL THEN
      if not cv1%isopen then
          OPEN cv1 FOR 'SELECT distinct OBJECT_ID FROM '||table_name||' order by OBJECT_ID';
          FETCH cv1 BULK COLLECT INTO OBJ_IDs;
      END IF;
    ELSE
      IF NOT cv1%ISOPEN THEN
        OPEN cv1 FOR SELECT 1 FROM DUAL;
        FETCH cv1 BULK COLLECT INTO OBJ_IDs;
      END IF;
    END IF;
      

    FOR k IN OBJ_IDs.FIRST .. OBJ_IDs.LAST LOOP
      IF mps IS NULL THEN
        if not cv2%isopen then
            OPEN cv2 FOR 'SELECT distinct TRAJ_ID FROM '||table_name||' WHERE OBJECT_ID = '||OBJ_IDs(k);
            FETCH cv2 BULK COLLECT INTO TRAJ_IDs;
        END IF;
      ELSE
        IF NOT cv2%ISOPEN THEN
          OPEN cv2 FOR
          SELECT DISTINCT p.traj_id FROM TABLE(mps) p;
          FETCH cv2 BULK COLLECT INTO TRAJ_IDs;
        END IF;
      END IF;

        FOR j IN TRAJ_IDs.FIRST .. TRAJ_IDs.LAST LOOP
            --dbms_output.put_line('TRAJ_ID='||TO_CHAR(TRAJ_IDs(j)) ||'   OBJ_ID='|| OBJ_IDs(k));
            if mps is null then
              sql_stm := 'select a.mpoint from '||table_name||' a where a.OBJECT_ID = '||obj_ids(k)
              ||' and a.TRAJ_ID = '||traj_ids(j);
              execute immediate sql_stm into mp;--case return many trajs is not expected!!!
            else
              SELECT moving_point(p.u_tab, p.traj_id, p.srid)
              INTO mp FROM TABLE(mps) p
              WHERE p.TRAJ_ID = TRAJ_IDs(j);
            end if;
            IF mp IS NULL THEN
              CONTINUE;
            END IF;
            srid := mp.srid;
            counter := counter + 1;
            T_ID  := TO_CHAR(counter);--TO_CHAR(OBJ_IDs(k)) || TO_CHAR(TRAJ_IDs(j));
            XYTs  := TO_CHAR(mp.u_tab.LAST + 1);
            dbms_lob.append(txtdoc, TO_CLOB(T_ID || ' ' || XYTs));

            FOR i IN mp.u_tab.FIRST .. mp.u_tab.LAST LOOP
                  IF mp is null OR mp.u_tab(i) is null OR mp.u_tab(i).p.b.M_Y is null THEN
                    continue;
                  END IF;
                  --TP  := TO_CHAR(365*mp.u_tab(i).p.b.M_Y + 12*mp.u_tab(i).p.b.M_M + 30*mp.u_tab(i).p.b.M_D + 24*mp.u_tab(i).p.b.M_H + 60*mp.u_tab(i).p.b.M_MIN + mp.u_tab(i).p.b.M_SEC);
                  TP  := TO_CHAR(tau_tll.D_timepoint_Sec_package.get_abs_date(mp.u_tab(i).p.b.M_Y,
                   mp.u_tab(i).p.b.M_M, mp.u_tab(i).p.b.M_D, mp.u_tab(i).p.b.M_H, mp.u_tab(i).p.b.M_MIN,
                    mp.u_tab(i).p.b.M_SEC));

                  TRANSgeom := MDSYS.SDO_GEOMETRY (2001,SRID,sdo_point_type (mp.u_tab(i).m.xi,
                   mp.u_tab(i).m.yi, NULL),NULL,NULL); -- insert OR delete "geom" from "TRANSgeom"
                  --TRANSgeom := MDSYS.SDO_CS.TRANSFORM (geom, 8307);
                  XY := SUBSTR(REPLACE(TO_CHAR (TRANSgeom.sdo_point.x), ',', '.'), 0, 16) || ' ' 
                     || SUBSTR(REPLACE(TO_CHAR (TRANSgeom.sdo_point.y), ',', '.'), 0, 16);
                  --DBMS_OUTPUT.PUT_LINE('XY = ' || TO_CHAR(XY));

                  dbms_lob.append(txtdoc, TO_CLOB(' ' || TP || ' ' || XY));

                  -- APPEND LAST (x,y,t)
                  IF i = mp.u_tab.LAST THEN
                      TP  := TO_CHAR(tau_tll.D_timepoint_Sec_package.get_abs_date(mp.u_tab(i).p.e.M_Y,
                       mp.u_tab(i).p.e.M_M, mp.u_tab(i).p.e.M_D, mp.u_tab(i).p.e.M_H, mp.u_tab(i).p.e.M_MIN,
                        mp.u_tab(i).p.e.M_SEC));

                      TRANSgeom := MDSYS.SDO_GEOMETRY (2001,SRID,sdo_point_type (mp.u_tab(i).m.xe, 
                      mp.u_tab(i).m.ye, NULL),NULL,NULL); -- insert OR delete "geom" from "TRANSgeom"
                      --TRANSgeom := MDSYS.SDO_CS.TRANSFORM (geom, 8307);
                      XY := SUBSTR(REPLACE(TO_CHAR (TRANSgeom.sdo_point.x), ',', '.'), 0, 16) || ' ' 
                      || SUBSTR(REPLACE(TO_CHAR (TRANSgeom.sdo_point.y), ',', '.'), 0, 16); 
                      --DBMS_OUTPUT.PUT_LINE('XY = ' || TO_CHAR(XY));

                      dbms_lob.append(txtdoc, TO_CLOB(' ' || TP || ' ' || XY || CHR(13) || CHR(10) ));
                  END IF;
            END LOOP;
        END LOOP;

        CLOSE cv2;
    END LOOP;

    CLOSE cv1;
    -- FINALLY write to disk the txt file
    dbms_xslprocessor.clob2file(txtdoc, 'IO', outTXTfile); --IO is needed by GUI
    --commit;
  END MovingPointTable2TXT;

PROCEDURE semtrajectory2kml(
    semtraj      IN sem_trajectory,
    bln_mpoints   IN   VARCHAR2,
    bln_rect  IN VARCHAR2,
    bln_cent IN VARCHAR2 )
IS
  tolerance   CONSTANT NUMBER        := 100;
  res_mp moving_point;
  res_mps mp_array := mp_array ();
  var_srid NUMBER;
  stmt     VARCHAR2 (5000);
begin
  var_srid := semtraj.srid;
  FOR c IN
  (SELECT DEREF (tlink).sub_mpoint mpoint,
    DEREF (tlink).o_id o_id,
    DEREF (tlink).subtraj_id subtraj_id,
    DEREF (tlink).traj_id traj_id,
    MDSYS.sdo_geom.sdo_centroid (VALUE (s).mbb.getrectangle (var_srid), tolerance ) mbr_centroid,
    VALUE (s).mbb.getrectangle (var_srid) mbb,
    activity_tag,
    episode_tag, defining_tag
  FROM TABLE(semtraj.episodes ) s )
  LOOP
    res_mps := mp_array (c.mpoint);
    IF UPPER (bln_mpoints) = 'TRUE' THEN
    visualizer.movingpointtable2kml ( 'u' || c.o_id || 'traj' || c.traj_id || 'subtraj' || c.subtraj_id 
      || '_MOVPOINT', res_mps );
     END IF;
    IF UPPER (bln_rect) = 'TRUE' THEN
      visualizer.polygon2kml (c.mbb, 4326, 'u' || c.o_id || 'traj' || c.traj_id || 'subtraj' || c.subtraj_id 
        || '_RECTANGLE.kml' );
    END IF;
    IF UPPER (bln_cent) = 'TRUE' THEN
      visualizer.placemark2kml (c.mbr_centroid, 4326, 'u' || c.o_id || 'traj' || c.traj_id || 'subtraj' || c.subtraj_id 
        || '_CENTROID.kml', c.defining_tag || '(activity: ' || c.activity_tag || ')', c.subtraj_id || ' - ' || c.episode_tag );
    END IF;
  END LOOP;
END;

procedure movingpoint2kml(fileprefix varchar2, mpoint moving_point)
  is
  filename varchar2(50);
  l_file utl_file.file_type;
  l_line varchar2(32000);
  xi number;xe number;yi number;ye number;
  geometry sdo_geometry;
  begin
    filename :=fileprefix||'_t'||mpoint.traj_id||'_mpoint.kml';
    l_file := utl_file.fopen('GML2KML', filename, 'W',32765);
    l_line:='<?xml version="1.0" encoding="utf-8"?>
        <kml xmlns="http://earth.google.com/kml/2.2">
          <Document xmlns="">
          <Folder>
            <name>Hermes</name>
            <Style id="blueLine">
            <LineStyle>
              <color>ffff0000</color>
              <width>3</width>
            </LineStyle>
            </Style>';
    utl_file.put_line(l_file, l_line); 
    for i in mpoint.u_tab.first..mpoint.u_tab.last loop
      if (mpoint.srid<>4326) then
        geometry := sdo_cs.transform(sdo_geometry(2001,mpoint.srid,null,sdo_elem_info_array(1,1,1),
          sdo_ordinate_array(mpoint.u_tab(i).m.xi,mpoint.u_tab(i).m.yi)),4326);
        xi:=geometry.sdo_ordinates(1);yi:=geometry.sdo_ordinates(2);
        geometry := sdo_cs.transform(sdo_geometry(2001,mpoint.srid,null,sdo_elem_info_array(1,1,1),
          sdo_ordinate_array(mpoint.u_tab(i).m.xe,mpoint.u_tab(i).m.ye)),4326);
        xe:=geometry.sdo_ordinates(1);ye:=geometry.sdo_ordinates(2);
      else
        xi:=mpoint.u_tab(i).m.xi;
        xe:=mpoint.u_tab(i).m.xe;
        yi:=mpoint.u_tab(i).m.yi;
        ye:=mpoint.u_tab(i).m.ye;
      end if;
      l_line:='<Placemark><name>Segment: '||i||'</name><description>Segment '||i||' of trajectory t'||mpoint.traj_id
        ||'</description><TimeSpan><begin>'||lpad(mpoint.u_tab(i).p.b.m_y,4,'0')||'-'||lpad(mpoint.u_tab(i).p.b.m_m,2,'0')||'-'
        ||lpad(mpoint.u_tab(i).p.b.m_d,2,'0')||'T'||lpad(mpoint.u_tab(i).p.b.m_h,2,'0')||':'||lpad(mpoint.u_tab(i).p.b.m_min,2,'0')
        ||':'||lpad(mpoint.u_tab(i).p.b.m_sec,2,'0')||'Z</begin><end>'||lpad(mpoint.u_tab(i).p.e.m_y,4,'0')||'-'
        ||lpad(mpoint.u_tab(i).p.e.m_m,2,'0')||'-'||lpad(mpoint.u_tab(i).p.e.m_d,2,'0')||'T'||lpad(mpoint.u_tab(i).p.e.m_h,2,'0')
        ||':'||lpad(mpoint.u_tab(i).p.e.m_min,2,'0')||':'||lpad(mpoint.u_tab(i).p.e.m_sec,2,'0')
        ||'Z</end></TimeSpan><styleUrl>#blueLine</styleUrl><LineString><altitudeMode>relative</altitudeMode><coordinates>'
        ||replace(xi,',','.')||','||replace(yi,',','.')||',0 '
        ||replace(xe,',','.')||','||replace(ye,',','.')||',0</coordinates></LineString></Placemark>';
      utl_file.put_line(l_file, l_line);
    end loop;
    l_line:='</Folder>
          </Document>
        </kml>';
    utl_file.put_line(l_file, l_line);
    utl_file.fflush(l_file);
    utl_file.fclose(l_file);
    
    exception when others then
      dbms_output.put_line('Error_Backtrace...' ||
            DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
      utl_file.fclose(l_file);
  end movingpoint2kml;
  
  procedure movingpointtable2kml(fileprefix varchar2, mpoints mp_array)
  is
  filename varchar2(50);
  l_file utl_file.file_type;
  l_line varchar2(32000);
  xi number;xe number;yi number;ye number;
  geometry sdo_geometry;
  mpoint moving_point;
  begin
    filename :=fileprefix||'_mpoints.kml';
    l_file := utl_file.fopen('GML2KML', filename, 'W',32765);
    l_line:='<?xml version="1.0" encoding="utf-8"?>
        <kml xmlns="http://earth.google.com/kml/2.2">
          <Document xmlns="">
          <Folder>
            <name>Hermes</name>
            <Style id="blueLine">
            <LineStyle>
              <color>ffff0000</color>
              <width>3</width>
            </LineStyle>
            </Style>';
    utl_file.put_line(l_file, l_line); 
    xi:=mpoints.count;
    for j in mpoints.first..mpoints.last loop
      mpoint := mpoints(j);
      for i in mpoint.u_tab.first..mpoint.u_tab.last loop
        if (mpoint.srid<>4326) then
          geometry := sdo_cs.transform(sdo_geometry(2001,mpoint.srid,null,sdo_elem_info_array(1,1,1),
            sdo_ordinate_array(mpoint.u_tab(i).m.xi,mpoint.u_tab(i).m.yi)),4326);
          xi:=geometry.sdo_ordinates(1);yi:=geometry.sdo_ordinates(2);
          geometry := sdo_cs.transform(sdo_geometry(2001,mpoint.srid,null,sdo_elem_info_array(1,1,1),
            sdo_ordinate_array(mpoint.u_tab(i).m.xe,mpoint.u_tab(i).m.ye)),4326);
          xe:=geometry.sdo_ordinates(1);ye:=geometry.sdo_ordinates(2);
        else
          xi:=mpoint.u_tab(i).m.xi;
          xe:=mpoint.u_tab(i).m.xe;
          yi:=mpoint.u_tab(i).m.yi;
          ye:=mpoint.u_tab(i).m.ye;
        end if;
        l_line:='<Placemark><name>Segment: '||i||'</name><description>Segment '||i||' of trajectory t'||mpoint.traj_id
          ||'</description><TimeSpan><begin>'||lpad(mpoint.u_tab(i).p.b.m_y,4,'0')||'-'||lpad(mpoint.u_tab(i).p.b.m_m,2,'0')||'-'
          ||lpad(mpoint.u_tab(i).p.b.m_d,2,'0')||'T'||lpad(mpoint.u_tab(i).p.b.m_h,2,'0')||':'||lpad(mpoint.u_tab(i).p.b.m_min,2,'0')
          ||':'||lpad(mpoint.u_tab(i).p.b.m_sec,2,'0')||'Z</begin><end>'||lpad(mpoint.u_tab(i).p.e.m_y,4,'0')||'-'
          ||lpad(mpoint.u_tab(i).p.e.m_m,2,'0')||'-'||lpad(mpoint.u_tab(i).p.e.m_d,2,'0')||'T'||lpad(mpoint.u_tab(i).p.e.m_h,2,'0')
          ||':'||lpad(mpoint.u_tab(i).p.e.m_min,2,'0')||':'||lpad(mpoint.u_tab(i).p.e.m_sec,2,'0')
          ||'Z</end></TimeSpan><styleUrl>#blueLine</styleUrl><LineString><altitudeMode>relative</altitudeMode><coordinates>'
          ||replace(xi,',','.')||','||replace(yi,',','.')||',0 '
          ||replace(xe,',','.')||','||replace(ye,',','.')||',0</coordinates></LineString></Placemark>';
          dbms_output.put_line(length(l_line));
        utl_file.put_line(l_file, l_line);
      end loop;
      utl_file.new_line(l_file,1);
    end loop;
    l_line:='</Folder>
          </Document>
        </kml>';
    utl_file.put_line(l_file, l_line);
    utl_file.fflush(l_file);
    utl_file.fclose(l_file);
    
    exception when others then
      dbms_output.put_line('Error_Backtrace...' ||
            DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
      utl_file.fclose(l_file);
  end movingpointtable2kml;
   
  procedure episode2kml(episode sem_episode)
  is
  filename varchar2(50);
  l_file utl_file.file_type;
  l_line varchar2(32000);
  submpoint sub_moving_point;
  xi number;xe number;yi number;ye number;
  geometry sdo_geometry;
  begin
    select deref(episode.tlink) into submpoint from dual;
    movingpoint2kml(submpoint.subtraj_id,submpoint.sub_mpoint);
    filename :='episode '||submpoint.subtraj_id||' of u'||submpoint.o_id||'t'||submpoint.traj_id||'.kml';
    l_file := utl_file.fopen('GML2KML', filename, 'W',32765);
    if (submpoint.sub_mpoint.srid<>4326) then
      geometry := sdo_cs.transform(sdo_geometry(2001,submpoint.sub_mpoint.srid,null,sdo_elem_info_array(1,1,1),
        sdo_ordinate_array(episode.mbb.minpoint.x,episode.mbb.minpoint.y)),4326);
      xi:=geometry.sdo_ordinates(1);yi:=geometry.sdo_ordinates(2);
      geometry := sdo_cs.transform(sdo_geometry(2001,submpoint.sub_mpoint.srid,null,sdo_elem_info_array(1,1,1),
        sdo_ordinate_array(episode.mbb.maxpoint.x,episode.mbb.maxpoint.y)),4326);
      xe:=geometry.sdo_ordinates(1);ye:=geometry.sdo_ordinates(2);
    else
      xi:=episode.mbb.minpoint.x;
      xe:=episode.mbb.maxpoint.x;
      yi:=episode.mbb.minpoint.y;
      ye:=episode.mbb.maxpoint.y;
    end if;
    l_line:='<?xml version="1.0" encoding="UTF-8"?>
<kml>
<Document>
    <name>Polygon.kml</name>
    <Style id="transGreenPoly">
        <LineStyle>
            <width>1.5</width>
        </LineStyle>
        <PolyStyle>
            <color>0000ff00</color>
        </PolyStyle>
    </Style>
    <Placemark>
        <name>Episode: '||submpoint.subtraj_id||'</name>
    <description>Episode '||submpoint.subtraj_id||' of trajectory u'||submpoint.o_id||'t'||submpoint.traj_id
      ||' tag: '||episode.episode_tag||'activity: '||episode.activity_tag||'</description>
        <styleUrl>#transGreenPoly</styleUrl>
        <Polygon>
            <tessellate>1</tessellate>
            <altitudeMode>relativeToGround</altitudeMode>
            <outerBoundaryIs>
                <LinearRing>
                    <coordinates>'||replace(xi,',','.')||','||replace(yi,',','.')||' '||replace(xe,',','.')
          ||','||replace(yi,',','.')||' '||replace(xe,',','.')||','||replace(ye,',','.')
          ||' '||replace(xi,',','.')||','||replace(ye,',','.')||' '||replace(xi,',','.')
          ||','||replace(yi,',','.')||'</coordinates>
                </LinearRing>
            </outerBoundaryIs>
        </Polygon>        
    </Placemark>
</Document>
</kml>
';
    utl_file.put_line(l_file, l_line);
    utl_file.fflush(l_file);
    utl_file.fclose(l_file);
    
    exception when others then
      dbms_output.put_line('Error_Backtrace...' ||
            DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
      utl_file.fclose(l_file);
  end episode2kml;
  
  procedure mbr2kml(mbb sdo_geometry, tag varchar2) is
    filename varchar2(50);
    l_file utl_file.file_type;
    l_line varchar2(32000);
    xi number;xe number;yi number;ye number;
    geometry sdo_geometry;
  begin
    if (mbb.sdo_gtype!=2003) then
      return;
    end if;
    filename :='mbr of '||tag||'.kml';
    l_file := utl_file.fopen('GML2KML', filename, 'W',32765);
    if (mbb.sdo_srid<>4326) then
      geometry := sdo_cs.transform(mbb,4326);
    else
      geometry:=mbb;
    end if;
    if (geometry.sdo_ordinates.count!=4) then
      geometry:=sdo_geom.sdo_mbr(geometry);
    else
      null;
    end if;
    xi:=geometry.sdo_ordinates(1);yi:=geometry.sdo_ordinates(2);
    xe:=geometry.sdo_ordinates(3);ye:=geometry.sdo_ordinates(4);
    l_line:='<?xml version="1.0" encoding="UTF-8"?>
<kml>
<Document>
    <name>Polygon.kml</name>
    <Style id="transGreenPoly">
        <LineStyle>
            <width>1.5</width>
        </LineStyle>
        <PolyStyle>
            <color>0000ff00</color>
        </PolyStyle>
    </Style>
    <Placemark>
        <name>'||tag||'</name>
    <description>'||tag||'</description>
        <styleUrl>#transGreenPoly</styleUrl>
        <Polygon>
            <tessellate>1</tessellate>
            <altitudeMode>relativeToGround</altitudeMode>
            <outerBoundaryIs>
                <LinearRing>
                    <coordinates>'||replace(xi,',','.')||','||replace(yi,',','.')||' '||replace(xe,',','.')
          ||','||replace(yi,',','.')||' '||replace(xe,',','.')||','||replace(ye,',','.')
          ||' '||replace(xi,',','.')||','||replace(ye,',','.')||' '||replace(xi,',','.')
          ||','||replace(yi,',','.')||'</coordinates>
                </LinearRing>
            </outerBoundaryIs>
        </Polygon>        
    </Placemark>
    <Placemark>
		<name>'||tag||'</name>
		<Point>
			<gx:drawOrder>1</gx:drawOrder>
			<coordinates>'||replace(xi,',','.')||','||replace(yi,',','.')||',0</coordinates>
		</Point>
	</Placemark>   
</Document>
</kml>
';
    utl_file.put_line(l_file, l_line);
    utl_file.fflush(l_file);
    utl_file.fclose(l_file);
    
   /* exception when others then
      dbms_output.put_line('Error_Backtrace...' ||
            DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
      utl_file.fclose(l_file);*/
 end mbr2kml;
 
 procedure mbr2wkt(mbb sdo_geometry, tag varchar2) is
    filename varchar2(50);
    l_file utl_file.file_type;
    l_line varchar2(32000);
    xi number;xe number;yi number;ye number;
    geometry sdo_geometry;
  begin
    if (mbb.sdo_gtype!=2003) then
      return;
    end if;
    filename :=tag||'.wkt';
    l_file := utl_file.fopen('GML2KML', filename, 'W',32765);
    geometry:=mbb;
    if (geometry.sdo_ordinates.count!=4) then
      geometry:=sdo_geom.sdo_mbr(geometry);
    else
      null;
    end if;
    xi:=geometry.sdo_ordinates(1);yi:=geometry.sdo_ordinates(2);
    xe:=geometry.sdo_ordinates(3);ye:=geometry.sdo_ordinates(4);
    l_line:='POLYGON (('||replace(xi,',','.')||' '||replace(yi,',','.')||','||replace(xe,',','.')
          ||' '||replace(yi,',','.')||','||replace(xe,',','.')||' '||replace(ye,',','.')
          ||','||replace(xi,',','.')||' '||replace(ye,',','.')||','||replace(xi,',','.')
          ||' '||replace(yi,',','.')||' ))';
    utl_file.put_line(l_file, l_line);
    utl_file.fflush(l_file);
    utl_file.fclose(l_file);
    
   /* exception when others then
      dbms_output.put_line('Error_Backtrace...' ||
            DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
      utl_file.fclose(l_file);*/
 end mbr2wkt;
 
 procedure geom2wkt(geom sdo_geometry, tag varchar2) is
    filename varchar2(50);
    wkt_geometry clob;
  begin
    filename :=tag||'.wkt';    
    wkt_geometry:=sdo_util.to_wktgeometry(geom);    
    dbms_xslprocessor.clob2file(wkt_geometry, 'GML2KML', filename);
    
   /* exception when others then
      dbms_output.put_line('Error_Backtrace...' ||
            DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
      utl_file.fclose(l_file);*/
 end geom2wkt;

END;
/


