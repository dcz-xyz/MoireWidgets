/* 
This is the companion visualization tool for the MoiréWidgets project. 
*/ 


import processing.pdf.*;
import controlP5.*;
import com.jsevy.jdxf.*;
import java.io.*;
import java.awt.*; 


ControlP5 cp5;

//Based on Monitor Specs 
int pixelDensity = 227; // ppi 

float animationOffset = 0;
boolean animate = false;
boolean forward = true;
float animationSpeed = 1; // Default speed
float lineThicknessMM = 0.4;
String patternType = "Linear"; // Default pattern type
color labelColor = color(10,10,10);
color textfieldColor = color(166, 185, 255); 
float strokeWidth = 0.4; //for rendering not 

Textlabel labels; 

//LINEAR PATTERN VARIABLES
float opaqueLayerWidth = 200;
float opaqueLayerHeight = 100;
float transparentLayerWidth = 100;
float transparentLayerHeight = 100;
float opaqueLineSpacing = 10;
float transparentLineSpacing = 5; 

Textfield opaqueLengthField, transparentLengthField, opaqueWidthField, transparentWidthField; 
Textfield opaqueOffsetField, transparentOffsetField; 

//RADIAL PATTERN TEXTFIELDS 
float transparentLayerDiameter = 100; 
float opaqueLayerDiameter = 100; 
float transparentLayerInnerDiameter = 33; 
float opaqueLayerInnerDiameter = 33; 
float transparentLayerOffsetAngle = 5;
float opaqueLayerOffsetAngle = 10;
float rotationAngle = 0; 

Textfield opaqueLayerOffsetAngleField, transparentLayerOffsetAngleField; 
Textfield opaqueLayerDiameterField, transparentLayerDiameterField;
Textfield transparentLayerInnerDiameterField, opaqueLayerInnerDiameterField; 


//DXF EXPORT VARIABLES //////////////////////////////////////////
// Create a DXF document and get its associated DXFGraphics instance
DXFDocument dxfDocumentOpaque = new 
    DXFDocument("Opaque");
DXFGraphics dxfGraphicsOpaque = 
    dxfDocumentOpaque.getGraphics();
    
    
DXFDocument dxfDocumentTransparent = new 
    DXFDocument("Transparent");
DXFGraphics dxfGraphicsTransparent = 
    dxfDocumentTransparent.getGraphics();

java.awt.BasicStroke stroke = new BasicStroke(1.14); // stroke width for Lines 1.13386 is about 0.4mm 

PrintWriter output; 




//needed to set size of window to A4 Screen
void settings() {
  size(617, 841);  
  // Render using all pixels on high-res displays
  pixelDensity(2);  
}

void setup() {
  setupControls();   
  dxfDocumentOpaque.setUnits(4); 
  dxfDocumentTransparent.setUnits(4);
  strokeWeight(strokeWidth); 
}

void draw() {
  
  background(250); // White background
  //Add Title and Disclaimers
  textSize(50); 
  fill(0,0,0);
  text("Moiré Visualizer", 150, 120);
  textSize(12);
  //textFont(font);
  text("Choose Radial or Linear Moiré", 50, 155);
  //text("This tool helps you preview how two Moiré patterns will interact", 50, 100);
  //text("*Screen resolution and different displays impact the appearance of the Moiré Patterns", 50, 115);
  //text("*We therefore recommend you export and print the files using opaque and transparency paper to verify", 50, 130);
  
  //Add Subtitles
  textSize(30); 
  text("Opaque Layer", 50, 200);
  text("Transparent Layer", 300, 200);
  text("Animation Preview", 50, 550);
  
  if (patternType.equals("Linear")) {
    // Draw linear pattern (rectangles with lines)
    // ... existing linear pattern drawing code
        // Draw the opaque layer preview with vertical lines
    drawLines(50, 340, opaqueLayerWidth, opaqueLayerHeight, 
              opaqueLineSpacing,  color(255, 0, 255)); // Purple border
    
    // Draw the transparent layer preview with vertical lines
    drawLines(300, 340, transparentLayerWidth, transparentLayerHeight,
              transparentLineSpacing, color(0, 255, 0)); // Green border
    
    // If animation is toggled, move the transparent layer
    if (animate) {
      
      if (forward) {
        animationOffset += animationSpeed; // Use the slider value for speed
        if (50 + animationOffset + transparentLayerWidth > 50 + opaqueLayerWidth) {
          forward = false; 
        }
      } else {
        animationOffset -= animationSpeed; // Use the slider value for speed
        if (animationOffset < 0) {
          forward = true; 
        }
      }
      drawLines(50, 580, opaqueLayerWidth, opaqueLayerHeight, 
              opaqueLineSpacing,  color(255, 0, 255)); // Purple border   
        
      
      drawLines(50 + animationOffset, 580, transparentLayerWidth, 
                transparentLayerHeight, transparentLineSpacing, color(0, 255, 0)); // Green border
    } else {
      drawLines(50, 580, opaqueLayerWidth, opaqueLayerHeight, 
              opaqueLineSpacing,  color(255, 0, 255)); // Purple border   
       
      drawLines(50 + animationOffset, 580, transparentLayerWidth, 
                transparentLayerHeight, transparentLineSpacing, color(0, 255, 0)); // Green border
    }
  } else if (patternType.equals("Radial")) {
    //println("DRAW RADIAL LINES"); 
    //// Draw radial pattern (circles with lines)
    drawRadialLines(width/4, 355, opaqueLayerDiameter, opaqueLayerInnerDiameter, opaqueLayerOffsetAngle);
    drawRadialLines(3*width/4, 355, transparentLayerDiameter, transparentLayerInnerDiameter, transparentLayerOffsetAngle);

    if (animate) {
      animationOffset += animationSpeed;
      //drawRadialLines(width/2, 640, opaqueLayerDiameter, opaqueLayerOffsetAngle, 0);
      //drawRadialLines(width/2, 640, transparentLayerDiameter, transparentLayerOffsetAngle,  animationOffset);
    }
    drawAnimatedPreview(width/2, 640, opaqueLayerDiameter, opaqueLayerInnerDiameter, opaqueLayerOffsetAngle, 
                        transparentLayerDiameter,transparentLayerInnerDiameter, transparentLayerOffsetAngle, animationOffset);
    }
   
    
}

// Function to draw vertical lines within a given area
void drawLines(float x, float y, float w, float h, float lineSpacing, color border) {
  stroke(0); // Black lines
  for (float i = x; i < x + w; i += lineSpacing) {
    line(i, y, i, y + h);
  }
  noFill();
  stroke(border); // Border color
  rect(x, y, w, h); // Drawing the border
}

void drawRadialLines(float centerX, float centerY, float diameter, float innerDiameter, float offsetAngle) {
  float radius = diameter / 2.0;
  float angleStep = radians(offsetAngle);
  stroke(1);
  //strokeWeight(mmToPixels(lineThicknessMM));
  fill(255, 0);
  ellipse(centerX, centerY, diameter, diameter); // Draw the circle at the new origin
 
  for (float angle = 0; angle < TWO_PI; angle += angleStep) {
    float x = centerX + cos(angle) * radius;
    float y = centerY + sin(angle) * radius;
    line(centerX, centerY, x, y);
  }
  fill(255); 
  ellipse(centerX, centerY, innerDiameter, innerDiameter); 
}

void drawAnimatedPreview(float centerX, float centerY, float diameter1, float innerDiameter1, 
                        float offsetAngle1, float diameter2, float innerDiameter2, float offsetAngle2, float rotation) {
  pushMatrix();
  translate(centerX, centerY);
  
  // Draw first static circle
  drawRadialLines(0, 0, diameter1, innerDiameter1, offsetAngle1);
  
  // Draw second spinning circle
  rotate(radians(rotation));
  drawRadialLines(0, 0, diameter2, innerDiameter2, offsetAngle2);
  
  popMatrix();
}

public void controlEvent(ControlEvent event) {
  
   // Check for changes in the dropdown list
  if (event.isFrom("patternType")) {
    DropdownList dl = (DropdownList)event.getController();
    animationOffset = 0;
    if (dl.getValue() == 0) {
      patternType = "Linear";
      //show linear controls
      opaqueLengthField.setVisible(true);
      opaqueWidthField.setVisible(true);
      transparentLengthField.setVisible(true);
      transparentWidthField.setVisible(true);
      opaqueOffsetField.setVisible(true);
      transparentOffsetField.setVisible(true);
      
      // Hide radial controls
      opaqueLayerDiameterField.setVisible(false);
      transparentLayerDiameterField.setVisible(false);
      opaqueLayerInnerDiameterField.setVisible(false);
      transparentLayerInnerDiameterField.setVisible(false);
      opaqueLayerOffsetAngleField.setVisible(false); 
      transparentLayerOffsetAngleField.setVisible(false);
    } else if (dl.getValue() == 1) {
      patternType = "Radial";
      // Show radial controls
      opaqueLayerDiameterField.setVisible(true);
      transparentLayerDiameterField.setVisible(true);
      opaqueLayerInnerDiameterField.setVisible(true);
      transparentLayerInnerDiameterField.setVisible(true);
      opaqueLayerOffsetAngleField.setVisible(true); 
      transparentLayerOffsetAngleField.setVisible(true);
      
      // Hide linear Controls 
      opaqueLengthField.setVisible(false);
      opaqueWidthField.setVisible(false);
      transparentLengthField.setVisible(false);
      transparentWidthField.setVisible(false);
      opaqueOffsetField.setVisible(false);
      transparentOffsetField.setVisible(false);
    }
  }
  if (event.isAssignableFrom(Textfield.class)) {
    try {
      String name = event.getName();
      String text = event.getStringValue();
      Float value = Float.parseFloat(text);  
      println(value);
      
      
      switch(name) {
        
        //linear input fields
        case "opaqueLength":
          opaqueLayerWidth = value;
          break;
        case "opaqueWidth":
          opaqueLayerHeight = value;
          break;
        case "transparentLength":
          transparentLayerWidth = value;
          break;
        case "transparentWidth":
          transparentLayerHeight = value;
          break;
        case "opaqueOffset":
          opaqueLineSpacing = value;
          break;
        case "transparentOffset":
          transparentLineSpacing = value;
          break;
        
        //radial input fields
         case "opaqueDiameter":
          opaqueLayerDiameter = value;
          break;
        case "transparentDiameter":
          transparentLayerDiameter = value;
          break;
       case "opaqueInnerDiameter":
          opaqueLayerInnerDiameter = value;
          break;
        case "transparentInnerDiameter":
          transparentLayerInnerDiameter = value;
          break;
        case "opaqueOffsetAngle":
          opaqueLayerOffsetAngle = value;
          break;
        case "transparentOffsetAngle":
          transparentLayerOffsetAngle = value;
          break;

      }
    } catch(NumberFormatException e) {
      println("Please enter a valid number");
    }
  }
}

// Callback function for the toggle animation button
public void toggleAnimation(float theValue) {
  animate = !animate;
}

// Callback function for the animation speed slider
public void animationSpeed(float speed) {
  animationSpeed = speed;
}

// Callback function for the export PDF button
public void exportPDF(float theValue) {
  // Set up the PDF export
  PGraphicsPDF pdf;
  
  // Export the opaque layer
  pdf = (PGraphicsPDF)beginRecord(PDF, "opaqueLayer.pdf");
  pdf.beginDraw();
  pdf.scale(72.0 / 25.4); // scale to match mm
  //drawLinesPDF(pdf, 0, 0, mmToPixels(opaqueLayerWidth), mmToPixels(opaqueLayerHeight), opaqueLineSpacing);
  pdf.dispose();
  endRecord();

  // Export the transparent layer
  pdf = (PGraphicsPDF)beginRecord(PDF, "transparentLayer.pdf");
  pdf.beginDraw();
  pdf.scale(72.0 / 25.4); // scale to match mm
  //drawLinesPDF(pdf, 0, 0, mmToPixels(transparentLayerWidth), mmToPixels(transparentLayerHeight), transparentLineSpacing);
  pdf.dispose();
  endRecord();
  
  println("PDFs exported.");
}



// Helper function to draw lines for PDF export
void drawLinesPDF(PGraphics pdf, float x, float y, float w, float h, int lineSpacing) {
  pdf.stroke(0);
  for (float i = x; i < x + w; i += lineSpacing) {
    pdf.line(i, y, i, y + h);
  }
  pdf.noFill();
  pdf.stroke(0);
  pdf.rect(x, y, w, h);
}

// Callback function for the export DXF button
public void exportDXF(float theValue) {
  // Export the opaque layer
  println("Exporting DXF Files");
  dxfDocumentOpaque.setLayer("Opaque");
  dxfGraphicsOpaque.setStroke(stroke);
  noFill();
  
  // Check to see which pattern to draw
  if (patternType == "Linear") {
    //Draw Opaque Pattern
    dxfGraphicsOpaque.drawRect(0, 0, opaqueLayerWidth, opaqueLayerHeight);
    for (float i = 0; i < opaqueLayerWidth; i += opaqueLineSpacing) {
      dxfGraphicsOpaque.drawLine(i, 0, i, opaqueLayerHeight);
    }
    //Draw Transparent Pattern
    dxfGraphicsTransparent.drawRect(0, 0, transparentLayerWidth, transparentLayerHeight);
    for (float i = 0; i < transparentLayerWidth; i += transparentLineSpacing) {
      dxfGraphicsTransparent.drawLine(i, 0, i, transparentLayerHeight);
    }
  } else if (patternType == "Radial") {
    //Draw Opaque Circles and Lines
    dxfGraphicsOpaque.drawOval(-opaqueLayerDiameter / 2, -opaqueLayerDiameter / 2, opaqueLayerDiameter, opaqueLayerDiameter);
    dxfGraphicsOpaque.drawOval(-opaqueLayerInnerDiameter/2, -opaqueLayerInnerDiameter/2, opaqueLayerInnerDiameter, opaqueLayerInnerDiameter);
    
    float opaqueAngleStep = radians(opaqueLayerOffsetAngle);
    
    //draw lines from center of circle
    for (float angle = 0; angle < TWO_PI; angle += opaqueAngleStep) {
      float x = cos(angle) * opaqueLayerDiameter / 2;
      float y = sin(angle) * opaqueLayerDiameter / 2;
      float startx = cos(angle) * opaqueLayerInnerDiameter / 2; 
      float starty = sin(angle) * opaqueLayerInnerDiameter / 2; 
      dxfGraphicsOpaque.drawLine(startx, starty, x, y);
    }
    //Draw Opaque Circles and Lines
    dxfGraphicsTransparent.drawOval(-transparentLayerDiameter / 2, -transparentLayerDiameter / 2, transparentLayerDiameter, transparentLayerDiameter);
    dxfGraphicsTransparent.drawOval(-transparentLayerInnerDiameter/2, -transparentLayerInnerDiameter/2, transparentLayerInnerDiameter, transparentLayerInnerDiameter);
    
    float transparentAngleStep = radians(transparentLayerOffsetAngle);
    
    //draw lines from center of circle
    for (float angle = 0; angle < TWO_PI; angle += transparentAngleStep) {
      float x = cos(angle) * transparentLayerDiameter / 2;
      float y = sin(angle) * transparentLayerDiameter / 2;
      float startx = cos(angle) * transparentLayerInnerDiameter / 2; 
      float starty = sin(angle) * transparentLayerInnerDiameter / 2; 
      dxfGraphicsTransparent.drawLine(startx, starty, x, y);
    }    
  }

  String stringOutput_Opaque = dxfDocumentOpaque.toDXFString(); 
  String filePath_Opaque = "opaqueMoiré.dxf"; 
  output = createWriter(filePath_Opaque);
  output.println(stringOutput_Opaque);
  output.flush();
  output.close();
  
  String stringOutput_Transparent = dxfDocumentTransparent.toDXFString(); 
  String filePath_Transparent = "transparentMoiré.dxf"; 
  output = createWriter(filePath_Transparent);
  output.println(stringOutput_Transparent);
  output.flush();
  output.close();

}

// Function to convert mm to pixels
float mmToPixels(float mm) {
  return mm * (72.0 / 25.4);
}

// Function to convert mm to pixels 
int mmToPixels2(float mm, int ppi){
  // 1 inch = 25.4mmm 
  return round(mm * (ppi / 25.4));
}


void setupControls() {
  
  cp5 = new ControlP5(this);
  
  PFont font = createFont("arial",10);  
  
  labels = cp5.addTextlabel("Length")
                     .setColor(color(255,0,0));

   //Dropdown item to control what sort of widget to show
   cp5.addDropdownList("patternType")
     .setPosition(210, 140)
     .setItemHeight(20)
     .setBarHeight(20) 
     .setCaptionLabel("Pattern Type")
     .addItem("Linear", 0)
     .addItem("Radial", 1)
     .setValue(0)
     .setColorActive(color(255,128));

  // LINEAR PATTERN CONTROLS //////////////////////////////////////////
  // Create textfields for opaque layer dimensions
  opaqueLengthField = cp5.addTextfield("opaqueLength")
     .setPosition(50, 230)
     .setSize(50, 20)
     .setFont(font)
     .setFocus(true)
     .setAutoClear(false)
     .setInputFilter(2) // Allow Only 1) INTEGER 2)FLOAT 3)BITFONT 4)DEFAULT
     .setLabel("Opaque Window Length (mm)")
     .setVisible(true)
     .setColorLabel(labelColor);
  
  opaqueWidthField = cp5.addTextfield("opaqueWidth")
     .setPosition(50, 280)
     .setSize(50, 20)
     .setFont(font)
     .setFocus(true)
     .setAutoClear(false)
     //.setColor(textfieldColor)
     .setInputFilter(2) // Allow Only 1) INTEGER 2)FLOAT 3)BITFONT 4)DEFAULT
     .setLabel("Opaque Window Height (mm)")
     .setVisible(true)
     .setColorLabel(labelColor);
  
  // Create textfields for transparent layer dimensions
  transparentLengthField = cp5.addTextfield("transparentLength")
     .setPosition(300, 230)
     .setSize(50, 20)
     .setFont(font)
     .setAutoClear(false)
     .setFocus(true)
     //.setColor(textfieldColor)
     .setInputFilter(2) // Allow Only 1) INTEGER 2)FLOAT 3)BITFONT 4)DEFAULT
     .setLabel("Transparent Window Length (mm)")
     .setVisible(true)
     .setColorLabel(labelColor);
  
  transparentWidthField = cp5.addTextfield("transparentWidth")
     .setPosition(300, 280)
     .setSize(50, 20)
     .setFont(font)
     .setAutoClear(false)
     .setInputFilter(2) // Allow Only 1) INTEGER 2)FLOAT 3)BITFONT 4)DEFAULT
     .setLabel("Transparent Window Height (mm)")
     .setVisible(true)
     .setColorLabel(labelColor);
     
   opaqueOffsetField = cp5.addTextfield("opaqueOffset")
     .setPosition(50, 450)
     .setSize(50, 20)
     .setFont(font)
     .setAutoClear(false)
     .setInputFilter(2) // Allow Only 1) INTEGER 2)FLOAT 3)BITFONT 4)DEFAULT
     .setLabel("Opaque Layer Offset Distance (mm)")
     .setVisible(true)
     .setColorLabel(labelColor);
     
   transparentOffsetField = cp5.addTextfield("transparentOffset")
     .setPosition(300, 450)
     .setSize(50, 20)
     .setFont(font)
     .setAutoClear(false)
     .setInputFilter(2) // Allow Only 1) INTEGER 2)FLOAT 3)BITFONT 4)DEFAULT
     .setLabel("Transparent Layer Offset Distance  (mm)")
     .setVisible(true)
     .setColorLabel(labelColor);
     
  // RADIAL PATTERN CONTROLS //////////////////////////////////////////
  
    // Create textfields for diameters of circles for radial pattern
  opaqueLayerDiameterField = cp5.addTextfield("opaqueDiameter")
     .setPosition(50, 210)
     .setSize(50, 20)
     .setFont(font)
     .setColorLabel(labelColor)
     .setAutoClear(false)
     .setInputFilter(2) // Allow Only 1) INTEGER 2)FLOAT 3)BITFONT 4)DEFAULT
     .setLabel("Opaque Layer Diameter (mm)")
     .setText("100") // Default diameter
     .setVisible(false); // Hidden by default
     
  transparentLayerDiameterField = cp5.addTextfield("transparentDiameter")
     .setPosition(300, 210)
     .setSize(50, 20)
     .setFont(font)
     .setAutoClear(false)
     .setInputFilter(2) // Allow Only 1) INTEGER 2)FLOAT 3)BITFONT 4)DEFAULT
     .setColorLabel(labelColor)
     .setLabel("Transparent Layer Diameter (mm)")
     .setText("100") // Default diameter
     .setVisible(false); // Hidden by default
     
  opaqueLayerInnerDiameterField = cp5.addTextfield("opaqueInnerDiameter")
     .setPosition(50, 250)
     .setSize(50, 20)
     .setFont(font)
     .setColorLabel(labelColor)
     .setAutoClear(false)
     .setInputFilter(2) // Allow Only 1) INTEGER 2)FLOAT 3)BITFONT 4)DEFAULT
     .setLabel("Opaque Layer Inner Diameter (mm)")
     .setText("33") // Default diameter
     .setVisible(false); // Hidden by default
     
  transparentLayerInnerDiameterField = cp5.addTextfield("transparentInnerDiameter")
     .setPosition(300, 250)
     .setSize(50, 20)
     .setFont(font)
     .setAutoClear(false)
     .setInputFilter(2) // Allow Only 1) INTEGER 2)FLOAT 3)BITFONT 4)DEFAULT
     .setColorLabel(labelColor)
     .setLabel("Transparent Layer Inner Diameter (mm)")
     .setText("33") // Default diameter
     .setVisible(false); // Hidden by default
     
   // Create textfields for offsetAngles of the lines 
   opaqueLayerOffsetAngleField = cp5.addTextfield("opaqueOffsetAngle")
     .setPosition(50, 460)
     .setSize(50, 20)
     .setFont(font)
     .setColorLabel(labelColor)
     .setAutoClear(false)
     .setInputFilter(2) // Allow Only 1) INTEGER 2)FLOAT 3)BITFONT 4)DEFAULT
     .setLabel("Opaque Layer Offset Angle")
     .setText("10") // Default angle
     .setVisible(false); // Hidden by default
 
  transparentLayerOffsetAngleField = cp5.addTextfield("transparentOffsetAngle")
     .setPosition(300, 460)
     .setSize(50, 20)
     .setFont(font)
     .setColorLabel(labelColor)
     .setAutoClear(false)
     .setInputFilter(2) // Allow Only 1) INTEGER 2)FLOAT 3)BITFONT 4)DEFAULT
     .setLabel("transparent Layer Offset Angle")
     .setText("5") // Default angle
     .setVisible(false); // Hidden by default 
  
  // ANIMATION CONTROLS //////////////////////////////////////////
  cp5.addButton("toggleAnimation")
     .setValue(1)
     .setPosition(50, 700)
     .setSize(100, 19)
     .setLabel("Toggle Animation");
     
  // Add a slider for controlling the animation speed
  cp5.addSlider("animationSpeed")
     .setPosition(50, 740)
     .setSize(100, 20)
     .setFont(font)
     .setRange(0.1, 2) // Speed range from 0.1 to 3
     .setValue(1) // Default speed
     .setLabel("Playback Speed")  
     .setColorLabel(labelColor);

  // EXPORT CONTROLS //////////////////////////////////////////
   // Add a button for exporting to PDF
   cp5.addButton("exportPDF")
     .setBroadcast(false)
     .setValue(0)
     .setPosition(50, 780)
     .setSize(100, 19)
     .setBroadcast(true)
     .setLabel("Export PDF");
     
  // Add a button for exporting to DXF
  cp5.addButton("exportDXF")
     .setBroadcast(false)
     .setValue(0)
     .setPosition(200, 780)
     .setSize(100, 19)
     .setBroadcast(true)
     .setLabel("Export DXF");
}
