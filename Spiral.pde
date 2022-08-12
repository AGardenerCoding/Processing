/*
 *	Spiral.pde
 *  ==========
 *
 *	5-28-18
 *
 */
//=====================================================================================================================

class Spiral
{
	// The parent contains all the info needed by a spiral.
	Circle parent;

	float minRad = 3,	// Radius measure at which spiral is finished and stops drawing
	      curRad,
	      radDecr = 0.2f,
	      cntrX,
	      cntrY,
	      oldX,
	      oldY;

	// An index into the Spiral.rotAngles[] array indicating the current angle measurement on the spiral.
	int angIndex,
	    count,
	    curChild;

	boolean isFinished;

	//----------------------------------------------------------------------------------------------------------------

	// CONSTRUCTOR
	// -----------

	public Spiral( Circle c, float radOffset )
	{
		parent = c;
		cntrX = c.cntrX;
		cntrY = c.cntrY;
		curRad = c.radius + radOffset;
		angIndex = c.startPosIndex;

		if ( rotAngles == null )
		{
			storeRotAngles();
		}
	}

	//----------------------------------------------------------------------------------------------------------------

	// SHOW
	// ----

	void show( int curSp )
	{
		if ( curRad >= minRad )
		{
			float ang = rotAngles[ angIndex ],
			      x = cntrX + curRad * cos( ang ),
			      y = cntrY + curRad * sin( ang );

			if ( count > 0 )
			{
                if ( clrType != 4 )
                {
                    line( oldX, oldY, x, y );
                }
                else
                {
                    strokeWeight( 1 );
                    circle( x, y, 14 );	
                }			

			}

			// Test for branch. Because the branch positions may be positioned before the cur angle position, it's
			//=================	necessary to test all the branch positions.
			for ( int i = 0; i < parent.childCircles.size(); i++ )
			{
				Circle c = parent.childCircles.get( i );

				if ( angIndex == ( c.startPosIndex + numAnglePos / 2 + 1  ) % numAnglePos )
				{
         			// Because the radius of the spiral is decreasing, the point where the parent circle and
         			// child circle intersected is not actually touching the spiral itself, so the child spiral
         			// starts diconnected from the parent spiral. This enlarges the child circle's radius so it
         			// contacts the parent spiral at the child spiral's start.
					float radOffset = parent.radius - curRad;

					spirals.add( new Spiral( c, radOffset ) );
					parent.childCircles.remove( c );
				}
			}

			// Next angle.
			//=============
			if ( parent.isClockwise )
			{
				angIndex = angIndex < numAnglePos - 1 ? angIndex + 1 : 0;
			}
			else
			{
				angIndex = angIndex > 0 ? angIndex - 1 : numAnglePos - 1;
			}

			count++;
			curRad -= radDecr;
			oldX = x;
			oldY = y;

		} // end if ( curRad >= minRad )
		else
		{
			isFinished = true;
		}
	}

	// end show()

	//----------------------------------------------------------------------------------------------------------------
}

// end class Spiral
