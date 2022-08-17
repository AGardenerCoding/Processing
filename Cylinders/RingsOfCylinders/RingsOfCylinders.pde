/*
 *  RingsOfCylinders.pde
 *  --------------------
 *
 *  2-10-22
 *
 */
 //--------------------------------------------------------------------------------------------------------------------

Cylinder[][] pipes;

float rx,
      ry,
      pipeRadius = 50,
      ringRadius = 500,
      angle,
      angleIncr = 0.01f;

int centerX,
    centerY,
    numPipes = 28;

//---------------------------------------------------------------------------------------------------------------------

// SETUP
// -----

void setup()
{
    fullScreen( P3D ); 
    centerX = width / 2;
    centerY = height / 2;
    background( 0 );
    noCursor();

    // PIPE COLORS
    noStroke();
    fill( 80, 112, 255 );

    pipes = new Cylinder[ 3 ][ numPipes ];

    float angle = 0.0f,
          angleIncr = TWO_PI / numPipes,
          oldx0 = 0,
          oldy0 = 0,
          oldz0 = 0,
          oldx1 = 0,
          oldy1 = 0,
          oldz1 = 0,
          oldx2 = 0,
          oldy2 = 0,
          oldz2 = 0;

    for ( int i = 0; i <= numPipes; i++ )
    {
        float x0 = ringRadius * cos( angle ),
              y0 = ringRadius * sin( angle ),
              z0 = 0,
              x1 = 0,
              y1 = x0,
              z1 = y0,
              x2 = y0,
              y2 = 0,
              z2 = x0;

        if ( i > 0 )
        {
            PVector v1 = new PVector( oldx0, oldy0, oldz0 ),
                    v2 = new PVector( x0, y0, z0 );

            pipes[ 0 ][ ( i - 1 ) % numPipes ]
                       = new Cylinder( v1, v2, 16, pipeRadius, false, true, Cylinder.BALL, Cylinder.BALL );
            //--------------------------------

            v1 = new PVector( oldx1,  oldy1, oldz1 );
            v2 = new PVector( x1, y1, z1 );

            pipes[ 1 ][ ( i - 1 ) % numPipes ]
                       = new Cylinder( v1, v2, 16, pipeRadius, false, true, Cylinder.BALL, Cylinder.BALL );
            //--------------------------------

            v1 = new PVector( oldx2,  oldy2, oldz2 );
            v2 = new PVector( x2, y2, z2 );

            pipes[ 2 ][ ( i - 1 ) % numPipes ]
                       = new Cylinder( v1, v2, 16, pipeRadius, false, true, Cylinder.BALL, Cylinder.BALL );
        }

        angle += angleIncr;
        oldx0 = x0;
        oldy0 = y0;
        oldz0 = z0;
        oldx1 = x1;
        oldy1 = y1;
        oldz1 = z1;
        oldx2 = x2;
        oldy2 = y2;
        oldz2 = z2;
    }
}
    
// end setup()

//---------------------------------------------------------------------------------------------------------------------

// DRAW
// ----
    
void draw()
{
    background( 0 );

    int originZCoord = -200;    // Negative values move origin into screen, away from viewer.
    translate( centerX, centerY, originZCoord );

    ambientLight(102, 102, 102);
    lightSpecular(204, 204, 204);
    directionalLight(102, 102, 102, 0, 0, -1);
    specular(255, 255, 255);
    shininess(5.0f);

    rotateX( angle * 0.5f );
    rotateY( angle );
    rotateZ( angle * 0.1f );
    angle += angleIncr;

    for ( int i = 0; i < numPipes; i++ )
    {
        shape( pipes[ 0 ][ i ].cyl );
        shape( pipes[ 1 ][ i ].cyl );
        shape( pipes[ 2 ][ i ].cyl );
    }

    fill( 128, 96, 255 );
    sphere( pipes[ 0 ][ 0 ].radius * 7 );    
}

// end draw()

//---------------------------------------------------------------------------------------------------------------------

// KEY PRESSED
// -----------

public void keyPressed() 
{
    noLoop();
    exit(); 
}    

// end keyPressed()

//---------------------------------------------------------------------------------------------------------------------
