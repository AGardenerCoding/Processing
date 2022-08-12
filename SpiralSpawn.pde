/*
 *	SpiralSpawn.pde
 *  ---------------
 *
 *  6-2-18
 *
 */
//=====================================================================================================================

import java.util.*;

ArrayList<Circle> unbranchedCircles,
                  allCircles,
                  branchCircles;

ArrayList<Spiral> spirals;

float[] rotAngles;	// The angle measurements around a circle in even tenths from 0 to TWO_PI.

float maxDiam = 180,	// Max and min of random size circles.
      minDiam = 75,
      minDist = 10,		// Minimum separation between ellipses that are not parent and child.
      baseClr;
      
int count,
    centerX,
    centerY,
	numAnglePos = 63,	// Based on dividing angles 0 to TWO_PI by tenths.
    clrType,
    numClrTypes = 6;
    
boolean isDrawing = true;

//---------------------------------------------------------------------------------------------------------------------

// SETUP
// -----

void setup()
{
	fullScreen();
    ((java.awt.Canvas) surface.getNative()).requestFocus();
    noCursor();
    
    centerX = width / 2;
    centerY = height / 2;
	background( 0 );
	strokeWeight( 3 );
	noFill();
	colorMode( HSB, 1.0f );
	
	maxDiam = random( 100, 250 );
	minDiam = random( 50, maxDiam - 40 );

	// CREATE CIRCLE PATTERN
	// ---------------------
	unbranchedCircles = new ArrayList<Circle>();
	allCircles = new ArrayList<Circle>();
	branchCircles = new ArrayList<Circle>();

	// Initialize the rotAngles array.
	storeRotAngles();

	// Angles are always rounded down ( floor )
	int startIndex = getIndexFromAngle( PI );	// starting at 9 o'clock position
	float diam = random( minDiam, maxDiam );

	// Start circle is radius away from left screen edge, at centerY.
	Circle startCircle = new Circle( random( 100, width - 100 ), random( 100, height - 100 ), 
	                                 diam, startIndex, true, null );

	unbranchedCircles.add( startCircle );
	allCircles.add( startCircle );

	// Create a list of a screenfull of connected circles which will be used as a pattern from which
	// to draw the spirals.
	while ( !unbranchedCircles.isEmpty() )
	{
		// Branch. For each unbranched circle, add branch circles into branchCircles arraylist in Circle.java.
		for ( int i = 0; i < unbranchedCircles.size(); i++ )
		{
			unbranchedCircles.get( i ).addBranches();
		}

		// All the unbranched circles have now had branch circles added, if possible, so clear the arraylist.
		unbranchedCircles.clear();

		// Transfer the new, unbranched circles into the arraylist for next loop.
		unbranchedCircles.addAll( branchCircles );
		allCircles.addAll( branchCircles );
		// Empty the new circles arraylist for next loop.
		branchCircles.clear();
	}
	// end while()

	// CREATE FIRST SPIRAL
	// -------------------
	spirals = new ArrayList<Spiral>();
	spirals.add( new Spiral( startCircle, 0 ) );	
}

// end setup()

//---------------------------------------------------------------------------------------------------------------------

// DRAW
// ----

void draw()
{
	// Test of circle pattern
//	for ( Circle c : allCircles )
//	{
//		c.show();
//	}
	//---------------------------
	
	if ( clrType == 5 )
	{
		strokeWeight( 11 );
		
		if ( frameCount % 7 == 0 )
		{
			fill( 0, 0.075f );
			noStroke();
			rect( 0, 0, width, height );
		}
	}
   
	// Limit the number of spirals drawing at one time, unless the count increment is commented out.
	int maxConcurrentSpirals = 3;
	count = 0;

	if ( isDrawing )
	{
		for ( int i = 0; i < spirals.size(); i++ )
		{
			Spiral sp = spirals.get( i );

			if ( !sp.isFinished )
			{
				if ( count < maxConcurrentSpirals )
				{
                    switch( clrType )
                    {
                        case 0:
                                strokeWeight( 3 ); // resets for clrTypes 0 - 3
                                stroke( i / ( float ) spirals.size(), 1.0f, 1.0f );                                                   
                        break;
                        
                        case 1:
                                stroke( baseClr, 1.0f - i / ( float ) spirals.size(), 1.0f );                       
                        break;
                        
                        case 2:
                            stroke( 1.0f - i / ( float ) spirals.size(), 
                                    1.0f - i / ( float ) spirals.size(), 1.0f ); 
                        break;
                        
                        case 3:
                            if ( frameCount % 2 == 0 )
                            {                
                                stroke( baseClr, i / ( float ) spirals.size(), 1.0f );
                            }
                            else
                            {
                               stroke( ( baseClr + 0.5f ) % 1.0f, 
                                       1.0f - i / ( float ) spirals.size(), 1.0f );                            
                            }
                        break;
                        
                        case 4:
                                strokeWeight( 1 );
                                stroke( baseClr, 1.0f - i / ( float ) spirals.size(), 1.0f );                       
                                // Spiral.show() contains code to draw circles instead of lines.
                        break;
                        
                        case 5:
                                stroke( i / ( float ) spirals.size(), 1.0f, 1.0f );                                                   
                        break;

                    } // end switch
                        
					sp.show( i );
				}
			}
			else
			{
				spirals.remove( sp );
			}

			// Comment out to NOT limit num spirals at one time.
//			count++;
		}
	}

	// Restart
	//--------
	if ( spirals.isEmpty() )
	{
		setup();   
        clrType++;
        clrType %= numClrTypes;
        
        if ( clrType == 1 || clrType == 4 )
        {
            baseClr = random( 1.0f );
        }
        
		redraw();
	}
}

// end draw()

//---------------------------------------------------------------------------------------------------------------------

// STORE ROT ANGLES
// ----------------

void storeRotAngles()
{
	int numIndices = numAnglePos;

	rotAngles = new float[ numIndices ];

	for ( int i = 0; i < numIndices; i++ )
	{
		rotAngles[ i ] = i / 10.0f;
	}
}

// end storeRotAngles()

//---------------------------------------------------------------------------------------------------------------------

// GET INDEX FROM ANGLE
// --------------------
// Convenience method to return the index into the rotAngles[] array from a float angle measurement.
// 'angle' is always rounded down ( floor )

int getIndexFromAngle( float angle )
{
	// floor( 3.14159 * 10 ) = 31, rotAngles[ 31 ] = 3.1
	// mod by 63 to allow any angle measure argument
	int index = floor( angle * 10 ) % numAnglePos;

	return index;
}

// end getIndexFromAngle()

//----------------------------------------------------------------------------------------------------------------

// KEY PRESSED
// -----------

public void keyPressed()
{
	noLoop();
	exit();

}

// end keyPressed()

//---------------------------------------------------------------------------------------------------------------------
