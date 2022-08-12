/*
 *	Circle.pde
 *  ==========
 *
 *	6-2-18
 *
 */
//=====================================================================================================================

class Circle
{
	Circle parent;

	// While branchCircles is a temporary storage used for copying new circles into the Sketch.unbranchedCircles
	// arraylist, the childCircles arraylist is needed for creating new spirals in Spiral.show().
	ArrayList<Circle> childCircles;

    float cntrX,
	      cntrY,
		  diam,
		  radius;

	// An index into the Spiral.rotAngles[] array indicating at what angle measurement the spiral begins to draw.
	int startPosIndex;

	boolean isClockwise;

	//-----------------------------------------------------------------------------------------------------------------

	// CONSTRUCTOR
	// -----------

	public Circle( float cntrX, float cntrY, float diam,
	                            int startPosIndex, boolean isClockwise, Circle parent )
	{
		this.cntrX = cntrX;
		this.cntrY = cntrY;
		this.diam = diam;
		radius = diam / 2.0f;
		this.startPosIndex = startPosIndex;
		this.parent = parent;
		this.isClockwise = isClockwise;
	}

	// end Circle() constructor

	//-----------------------------------------------------------------------------------------------------------------

	// ADD BRANCHES
	// ------------
	/* Calculate the 9 branch positions centered on the start branch position, spaced evenly 'indexSpacing' to either
	 * side of the center position, and store these in the branchPos[] array.
	 *
	 * Loop through each branch position angle, assigning a random diameter to a potential branch circle.
	 * Calculate the center position of the potential circle, then test if it would overlap with existing circles in
	 * both the current branchCircles list, and the allCircles list.
	 *
	 * If the circle fits, add it to the temporary branchCircles list, which is used in init to add circles to
	 * the allCircles list, then emptied. The circle is also added to the childCircles list, which is part of the
	 * Circle object.
	 */

	void addBranches()
	{
		childCircles = new ArrayList<Circle>();

		// Spiral angle measurements are stored in rotAngles[] as floats with one decimal position,
		// 0 to TWO_PI inclusive in 63 indices. So 31 indices added to the circles startIndexPos is 180 degrees
		// opposite, which is the center index position of the 9 possible branch circle start positions, 30 degrees
		// apart.
		int indexSpacing = floor( radians( 30 ) * 10 ),
		    numBranchPos = 9,
		    pos = 0,
		    startBranchPosIndex = ( startPosIndex + 32 ) % numAnglePos;

		// An array of the branch angle positions ( rotAngles[] indices ) of the circle.
	    int[] branchPos = new int[ numBranchPos ];

	    boolean canContinueTest = true;

		// Calculate the branch positions, centered on the start branch position.
		for ( int i = 0; i < numBranchPos; i++ )
		{
			pos = startBranchPosIndex - 4 * indexSpacing + i * indexSpacing;
			pos = pos < 0 ? pos + numAnglePos : pos >= numAnglePos ? pos - numAnglePos : pos;
			branchPos[ i ] = pos;
		}

		// Test potential circles in each of the branch positions.
		for ( int i = 0; i < numBranchPos; i++ )
		{
			canContinueTest = true;

 			// The start angle pos for the spiral is 180 degrees opposite current angle position on the parent circle.
			int curAngPos = branchPos[ i ],
			    startAngPos = ( curAngPos + numAnglePos / 2 + 1 ) % numAnglePos;

			float newDiam = random( minDiam, maxDiam ),
			      newRad = newDiam / 2.0f;

			// Find the vector extending from the current circle's center, through the current branch angle position,
			// and to the center of the new branch circle, which is the current circle's radius plus the new circle's
			// radius distance away. v3 is the new circle's center.
			PVector v1 = new PVector( cntrX, cntrY ),
			        v2 = PVector.fromAngle( rotAngles[ curAngPos ] );
			v2.setMag( radius + newRad );
			PVector v3 = PVector.add( v1, v2 );

			// Test for circle center onscreen.
			if ( v3.x < 0 || v3.x >= width || v3.y < 0 || v3.y >= height )
			{
				canContinueTest = false;
				continue;	// with next i
			}

			// Test for overlap with circles currently in the branchCircles arraylist.
			for ( int j = 0; j < branchCircles.size(); j++ )
			{
				Circle curCirc = branchCircles.get( j );
				if ( curCirc != this )
				{
					float distance = floor( dist( curCirc.cntrX, curCirc.cntrY, v3.x, v3.y ) ),
					      sumRads = floor( curCirc.diam / 2.0f + newRad );

					if ( distance < sumRads + minDist )
					{
						float[] testCircVals = doResizingTest( v1, curCirc, newRad, curAngPos );
						if ( testCircVals[ 0 ] == 0 )
						{
							canContinueTest = false;
							break;
						}
						else
						{
							v3.x = testCircVals[ 1 ];
							v3.y = testCircVals[ 2 ];
							newRad = testCircVals[ 3 ];
							newDiam = newRad * 2.0f;
						}
					}
				}
			}

			// Test for overlap with all previous circles.
			if ( canContinueTest )
			{
				for ( int k = 0; k < allCircles.size(); k++ )
				{
					Circle curCirc = allCircles.get( k );
					if ( curCirc != this )
					{
						float distance = floor( dist( curCirc.cntrX, curCirc.cntrY, v3.x, v3.y ) ),
						      sumRads = floor( curCirc.diam / 2.0f + newRad );

						if ( distance < sumRads + minDist )
						{
							float[] testCircVals = doResizingTest( v1, curCirc, newRad, curAngPos );
							if ( testCircVals[ 0 ] == 0 )
							{
								canContinueTest = false;
								break;
							}
							else
							{
								v3.x = testCircVals[ 1 ];
								v3.y = testCircVals[ 2 ];
								newRad = testCircVals[ 3 ];
								newDiam = newRad * 2.0f;
							}
						}
					}
				}
			}

			// Circle has cleared overlap tests.
			if ( canContinueTest )
			{
				Circle c = new Circle( v3.x, v3.y, newDiam, startAngPos, !isClockwise, this );
				branchCircles.add( c );
				childCircles.add( c );
			}

		} // end for ( i... ) potential branch circles test

	}

	// end addBranches()

	//-----------------------------------------------------------------------------------------------------------------

	// DO RESIZING TEST
	// ----------------

	float[] doResizingTest( PVector parentCenter, Circle existC, float rad, int curAngPos )
	{
		PVector v3 = new PVector();
		// vals[ 0 ] = continueTest flag, 0 = false, 1 = true;
		// vals[ 1 ] = new cntrX, vals[ 2 ] = new cntrY, vals[ 3 ] = new rad
		float[] vals = new float[ 4 ];
		float minRad = minDiam / 2.0f;
		boolean continueTest = true;

		while ( continueTest && rad >= minRad )
		{
			rad--;

			PVector v1 = new PVector( existC.cntrX, existC.cntrY ),
				    v2 = PVector.fromAngle( rotAngles[ curAngPos ] );
			v2.setMag( this.radius + rad );
			// Note that v3 is a measure from the *parent* center to the test circle center.
			v3 = PVector.add( parentCenter, v2 );

			// Test for circle center onscreen.
			if ( v3.x < 0 || v3.x >= width || v3.y < 0 || v3.y >= height )
			{
				continueTest = false;
				vals[ 0 ] = 0;
			}

			// Note that distance is a measure from current existing circle center to test circle center.
			float distance = floor( dist( v1.x, v1.y, v3.x, v3.y ) ),
			      sumRads = floor( existC.radius + rad );

			if ( distance >= sumRads + minDist )
			{
				continueTest = false;
				vals[ 0 ] = 1;
				vals[ 1 ] = v3.x;
				vals[ 2 ] = v3.y;
				vals[ 3 ] = rad;
			}
		}

		return vals;
	}

	// end doResizingTest()

	//-----------------------------------------------------------------------------------------------------------------

	// SHOW
	// ----

	void show()
	{
		stroke( 1.0f, 0.0f, 1.0f );
		ellipse( cntrX, cntrY, diam, diam );

		// Show the intersection point of the parent circle and each of its child circles with a red dot.
		// This is the startPosIndex angle of the child circle.
		stroke( 255, 0, 0 );
		for ( int i = 0; i < childCircles.size(); i++ )
		{
			Circle c = childCircles.get( i );
			PVector v1 = new PVector( c.cntrX, c.cntrY ),
			        v2 = PVector.fromAngle( rotAngles[ c.startPosIndex ] );
			v2.setMag( c.radius );
			PVector v3 = PVector.add( v1, v2 );

			ellipse( v3.x, v3.y, 4, 4 );
		}

	}

	// end show()

	//-----------------------------------------------------------------------------------------------------------------

}

// end class Circle
