/* 
 *    CylinderBetweenTwo3DPoints.pde
 *    ------------------------------
 *   
 *    2-8-22
 *  
 *    ENTER key draws new randomly positioned cylinder.
 *    Any other key exits sketch.
 *
 *
 *    For a long time I searched for a way to draw a cylinder between two random 3d points in Processing code.
 *  
 *    There's source code by Jeremy Douglass at https://editor.p5js.org/jeremydouglass/sketches/rbRfS7TSd to 
 *    accomplish this in p5.js but this relies on the built-in cylinder primitive that Processing is missing.
 *
 *    Jeremy Behreandt wrote another version in p5.js at https://openprocessing.org/sketch/859123 
 *    I tried, got very confused, and failed to convert his code to Processing. ( I probably could have tried
 *    harder, but part of the motivation for this project was to create code I could understand. )
 * 
 *    Eventually I discovered a page on Paul Bourke's website : http://paulbourke.net/geometry/rotate/
 *    with example code by Ronald Goodman at http://paulbourke.net/geometry/rotate/source.c that rotates
 *    a point about an arbitrary axis in 3d. Using that enabled me to write a sketch in Processing to
 *    draw a cylinder between two random 3d points.
 *
 *    Since this was written ( 2-8-22 ) I've found another version by Jeremy Behreandt for Processing at 
 *    https://discourse.processing.org/t/cylinder-into-a-spline/1811/6
 *
 */
//=====================================================================================================================

import java.awt.Robot;


Robot robot;

PVector[] nearRing,
          farRing;

PVector v1,             // The beginning and end coords of the line about which the offset points are rotated.
        v2,             // The line connecting these points runs the length of the cylinder at its center.

        offset1,        // A point offset from the rotate-about line, at the radius of the desired cylinder.
        offset2;

float rx,
      ry,
      offsetLength,
      angIncr,
      cylinderLength;

int centerX,
    centerY,
    numCylSides = 16;

//---------------------------------------------------------------------------------------------------------------------
    
// SETUP
// -----

void setup()
{
    fullScreen( P3D ) ;
    centerX = width / 2;
    centerY = height / 2;
    background( 0 );

    angIncr = TWO_PI / numCylSides;
    offsetLength = random( 10, 200 );

    nearRing = new PVector[ numCylSides ];
    farRing = new PVector[ numCylSides ];

    v1 = new PVector( random( -300, 300 ), random( -300, 300 ), random( -300, 300 ) );
    v2 = new PVector( random( -300, 300 ), random( -300, 300 ), random( -300, 300 ) );
    cylinderLength = PVector.sub( v2, v1 ).mag();
    
    offset1 = v1.cross( v2 );
    offset1.normalize();
    offset1.setMag( offsetLength );
    offset1.add( v1 );

    // Get a perpendicular at v2.
    offset2 = v1.cross( v2 );
    offset2.normalize();
    offset2.setMag( offsetLength );
    offset2.add( v2 );

    calcCylinderVerts();

    // Place cursor in top left corner, which properly aligns the axes to x = right, y = down, z = to viewer.
    try
    {
        robot = new Robot();
    }
    catch( java.awt.AWTException e )
    {
        println( "Error creating robot object. Program ended." );
        exit();
    }
    robot.mouseMove( 0, 0 );

    // Pause while cylinder and axes are oriented to mouse position 0,0, otherwise the drawing "jumps".
    delay( 200 );
}

// end setup()

//---------------------------------------------------------------------------------------------------------------------

// DRAW
// ----
    
void draw()
{
    background( 0 );
    
    pushMatrix(); // To enable text to be drawn at the end of draw() in normal screen coordinates.

    int distFromViewScreen = 100; // positive z out of screen
    translate( centerX, centerY, distFromViewScreen );

    doRotation();
    drawAxes();

    stroke( 255 );
    strokeWeight( 2 );
    fill( 0, 0, 255 );

    PShape cylinder = createShape();
    cylinder.beginShape( QUADS );

    for ( int i = 0; i < numCylSides; i++ )
    {
        PVector v1 = nearRing[ i % numCylSides ],
                v2 = farRing[ i % numCylSides ],
                v3 = farRing[ ( i + 1 ) % numCylSides ],
                v4 = nearRing[ ( i + 1 ) % numCylSides ];

        cylinder.vertex( v1.x, v1.y, v1.z );
        cylinder.vertex( v2.x, v2.y, v2.z );
        cylinder.vertex( v3.x, v3.y, v3.z );
        cylinder.vertex( v4.x, v4.y, v4.z );
    }
    cylinder.endShape( CLOSE );

    shape( cylinder );      

    // Draw two endpoints and a line between them that runs through the center of the cylinder.
    stroke( 128, 0, 255 );
    strokeWeight( 5 );
    line( v1.x, v1.y, v1.z, v2.x, v2.y, v2.z );

    pushMatrix();
    translate( v1.x, v1.y, v1.z );
    noStroke();
    fill( 255, 0, 0 );
    sphere( 5 );
    popMatrix();

    pushMatrix();
    translate( v2.x, v2.y, v2.z );
    noStroke();
    fill( 0, 255, 0 );
    sphere( 5 );
    popMatrix(); 
    
    popMatrix();    // End for text draw.
    
    PVector va = v1.copy(),    // For text formatting.
            vb = v2.copy();
            
    String vax = nf( va.x, 0, 1 ),
           vay = nf( va.y, 0, 1 ),
           vaz = nf( va.z, 0, 1 ),
           vbx = nf( vb.x, 0, 1 ),
           vby = nf( vb.y, 0, 1 ),
           vbz = nf( vb.z, 0, 1 );          
            
    String one = "Endpoint 1 : ( " + vax + ", " + vay + ", " + vaz + " ) ",
           two = "Endpoint 2 : ( " + vbx + ", " + vby + ", " + vbz + " ) ";
    
    fill( 255 );
    textSize( 24 );
    text( "Cylinder radius : " + nf( offsetLength, 0, 1 ), 10, 100 );
    text( "Cylinder length : " + nf( cylinderLength, 0, 1 ), 10, 200 );
    text( one, 10, 300 );   
    text( two, 10, 400 );   
}

// end draw()

//---------------------------------------------------------------------------------------------------------------------

// CALC CYLINDER VERTS
// -------------------

void calcCylinderVerts()
{
    for ( int i = 0; i < numCylSides; i++ )
    {
        // NOTE: 'angle' denotes the ANGLE INCREMENT between points, NOT a cumulative angle;
        // i.e., always uses only the angIncr, NOT 'angle + angIncr'.

        offset1 = rotatePointAboutLine( offset1, angIncr, v1, v2 );

        nearRing[ i ] = new PVector( offset1.x, offset1.y, offset1.z );

        offset2 = rotatePointAboutLine( offset2, angIncr, v1, v2 );

        farRing[ i ] = new PVector( offset2.x, offset2.y, offset2.z );
    }
}

// end calcCylinderVerts()

//---------------------------------------------------------------------------------------------------------------------

// ROTATE POINT ABOUT LINE
// -----------------------

/*  From Paul Bourke's article, "Rotate a point about an arbitrary axis (3 dimensions)"
 *  http://paulbourke.net/geometry/rotate/
 *  Code: http://paulbourke.net/geometry/rotate/example.c   by Ronald Goldman
 *
 *  Rotation of a point in 3 dimensional space by theta about an arbitrary axis
 *  defined by a line between two points P1 = (x1,y1,z1) and P2 = (x2,y2,z2) can be achieved by the following steps:
 *
 *  (1) translate space so that the rotation axis passes through the origin
 *
 *  (2) rotate space about the x axis so that the rotation axis lies in the xz plane
 *
 *  (3) rotate space about the y axis so that the rotation axis lies along the z axis
 *
 *  (4) perform the desired rotation by theta about the z axis
 *
 *  (5) apply the inverse of step (3)
 *
 *  (6) apply the inverse of step (2)
 *
 *  (7) apply the inverse of step (1)
 */

// NOTE: THETA denotes the ANGLE INCREMENT between points, NOT a cumulative angle; i.e., always pass only
// the angIncr, NOT 'angle + angIncr'.

PVector rotatePointAboutLine( PVector p, float theta, PVector p1, PVector p2 )
{
    /* Step 1 */
    PVector q1 = PVector.sub( p, p1 );
    PVector u = PVector.sub( p2, p1 );
    u.normalize();
    float d = sqrt( u.y * u.y + u.z * u.z );

    /* Step 2 */
    PVector q2 = new PVector();
    if ( d != 0 )
    {
        q2.x = q1.x;
        q2.y = q1.y * u.z / d - q1.z * u.y / d;
        q2.z = q1.y * u.y / d + q1.z * u.z / d;
    }
    else
    {
        q2 = q1;
    }

    /* Step 3 */
    q1.x = q2.x * d - q2.z * u.x;
    q1.y = q2.y;
    q1.z = q2.x * u.x + q2.z * d;

    /* Step 4 */
    q2.x = q1.x * cos( theta ) - q1.y * sin( theta );
    q2.y = q1.x * sin( theta ) + q1.y * cos( theta );
    q2.z = q1.z;

    /* Inverse of step 3 */
    q1.x =   q2.x * d + q2.z * u.x;
    q1.y =   q2.y;
    q1.z = - q2.x * u.x + q2.z * d;

    /* Inverse of step 2 */
    if ( d != 0 )
    {
        q2.x =   q1.x;
        q2.y =   q1.y * u.z / d + q1.z * u.y / d;
        q2.z = - q1.y * u.y / d + q1.z * u.z / d;
    }
    else
    {
        q2 = q1;
    }

    /* Inverse of step 1 */
    q1.x = q2.x + p1.x;
    q1.y = q2.y + p1.y;
    q1.z = q2.z + p1.z;

    return( q1 );
}

// end rotatePointAboutLine()

//---------------------------------------------------------------------------------------------------------------------

void doRotation()
{
    // Mouse rotation control.
    //-----------------------------------------
    ry = map( mouseX, 0, width, 0, TWO_PI );
    rx = map( mouseY, 0, height, 0, TWO_PI );
    rotateX( rx );
    rotateY( ry );

    // Show only when rotation is in use, otherwise looks bad.
    fill( 0, 255, 255 );
    text( "z", 0, -5, 500 );
}

// end doRotation()

//---------------------------------------------------------------------------------------------------------------------

// DRAW AXES
// ---------

void drawAxes()
{
    textSize( 10 );

    strokeWeight( 4 );
    stroke( 255, 0, 0 );
    line( 0, 0, 0, 500, 0, 0 );         // x
    fill( 255, 0, 0 );
    text( "x", 520, -5, 0 );

    stroke( 0, 255, 0 );
    line(  0, 0, 0, 0, 400, 0 );        // y
    fill( 0, 255, 0 );
    text( "y", 0, 420, 0 );

    stroke( 0, 255, 255 );
    line( 0, 0, 0, 0, 0, 500 );         // z
}

// end drawAxes()

//---------------------------------------------------------------------------------------------------------------------

// KEY PRESSED
// -----------

public void keyPressed() 
{
    if ( keyCode == 10 )    // ENTER
    {
        setup();
        loop();
    }
    else
    {
        noLoop();
        exit();
    }   
}    

// end keyPressed()

//---------------------------------------------------------------------------------------------------------------------
