  /*
 * changes by Rolf Hut:
 * changed to only plot incoming serial data, works with the standard
 * AnalogReadSerial from the Arduino. 
 * However, the time axis becomes dependent on the size of the incomming 
 * serial string, so is slower 
  
  
 * Oscilloscope
 * Gives a visual rendering of analog pin 0 in realtime.
 * 
 * This project is part of Accrochages
 * See http://accrochages.drone.ws
 * 
 * (c) 2008 Sofian Audry (info@sofianaudry.com)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */ 
import processing.serial.*;

int portNumber = 9; //which port to select. Run the 

Serial port;  // Create object from Serial class
float val;      // Data received from the serial port
float[] valuesX;
float[] valuesY;
float[] valuesZ;
float zoom;
byte lf = 10;
//float[] values;

void setup() 
{
  size(640, 480);
  // Open the port that the board is connected to and use the same speed (9600 bps)
  println(Serial.list());
  port = new Serial(this, Serial.list()[portNumber], 115200);
  port.bufferUntil(lf);
  valuesX = new float[width];
  valuesY = new float[width];
  valuesZ = new float[width];
  //values = new float[3];
  zoom = 1.0f;
  smooth();
}

int getY(float val) {
  return (int)(((height/2) - val / 40.0f * (height))-1);
}

void serialEvent(Serial port) {
  String[] values = split(port.readString(),",");
  if (values.length ==3){
    pushValue(float(values[0]),float(values[1]),float(values[2]));
  }
  
}

//
void pushValue(float valueX,float valueY,float valueZ) {
  for (int i=0; i<width-1; i++){
    valuesX[i] = valuesX[i+1];
    valuesY[i] = valuesY[i+1];
    valuesZ[i] = valuesZ[i+1];
  }
  valuesX[width-1] = valueX;
  valuesY[width-1] = valueY;
  valuesZ[width-1] = valueZ;
}

void drawLines() {
  stroke(255);
  
  int displayWidth = (int) (width / zoom);
  
  int k = valuesX.length - displayWidth;
  
  int x0 = 0;
  int yX0 = getY(valuesX[k]);
  int yY0 = getY(valuesY[k]);
  int yZ0 = getY(valuesZ[k]);
  for (int i=1; i<displayWidth; i++) {
    k++;
    int x1 = (int) (i * (width-1) / (displayWidth-1));
    int yX1 = getY(valuesX[k]);
    int yY1 = getY(valuesY[k]);
    int yZ1 = getY(valuesZ[k]);
    stroke(255);
    line(x0, yX0, x1, yX1);
    stroke(255,0,0);
    line(x0, yY0, x1, yY1);
    stroke(0,255,0);
    line(x0, yZ0, x1, yZ1);
    x0 = x1;
    yX0 = yX1;
    yY0 = yY1;
    yZ0 = yZ1;
  }
}

void drawGrid() {
  stroke(255, 0, 0);
  line(0, height/2, width, height/2);
}

void keyReleased() {
  switch (key) {
    case '+':
      zoom *= 2.0f;
      println(zoom);
      if ( (int) (width / zoom) <= 1 )
        zoom /= 2.0f;
      break;
    case '-':
      zoom /= 2.0f;
      if (zoom < 1.0f)
        zoom *= 2.0f;
      break;
  }
}

void draw()
{
  background(0);
  drawGrid();
  drawLines();
}
