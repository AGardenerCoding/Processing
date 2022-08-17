/*
 *  Cylinder.pde
 *  ------------
 *
 *  2-10-22
 *
 */
 //--------------------------------------------------------------------------------------------------------------------

class Cylinder
{
    PShape cyl,
           tube,
           cap1,
           cap2;
    
    PVector[] end1Verts,
              end2Verts;
    
    PVector end1,           // End points of the central cylinder axis.
            end2,
            offset1,
            offset2;
    
    float radius,
          angIncr;
    
    static final int FLAT = 0,
                     BALL = 1,
                     CONE = 2;
    
    int numSides,
        cap1Type,
        cap2Type;
    
    boolean addCap1,
            addCap2;
    
    //---------------------------------------------------------------------------------------------------------------------
        
    // CONSTRUCTOR
    // -----------
    
    public Cylinder( PVector end1, PVector end2, int numSides, float radius,
                     boolean addCap1, boolean addCap2, int cap1Type, int cap2Type )
    {
        this.end1 = end1;
        this.end2 = end2;
        this.numSides = numSides;
        this.radius = radius;
        this.addCap1 = addCap1;
        this.addCap2 = addCap2;
        this.cap1Type = cap1Type;
        this.cap2Type = cap2Type;
    
        angIncr = TWO_PI / numSides;
        end1Verts = new PVector[ numSides ];
        end2Verts = new PVector[ numSides ];
    
        cyl = createShape( GROUP );
        calcCylinderVerts();
    
        if ( addCap1 )
        {
            cap1 = createCap( end1, end1Verts, cap1Type );
            cyl.addChild( cap1 );
        }
        if ( addCap2 )
        {
            cap2 = createCap( end2, end2Verts, cap2Type );
            cyl.addChild( cap2 );
        }
    }
    
    // end Cylinder() constructor
    
    //---------------------------------------------------------------------------------------------------------------------
    
    // CALC CYLINDER VERTS
    // -------------------
    
    void calcCylinderVerts()
    {
        offset1 = end1.cross( end2 );
        offset1.normalize();
        offset1.setMag( radius );
        offset1.add( end1 );
    
        // Get a perpendicular at end2.
        offset2 = end1.cross( end2 );
        offset2.normalize();
        offset2.setMag( radius );
        offset2.add( end2 );
    
        for ( int i = 0; i < numSides; i++ )
        {
            // NOTE: 'angle' denotes the ANGLE INCREMENT between points, NOT a cumulative angle;
            // i.e., always uses only the angIncr, NOT 'angle + angIncr'.
    
            offset1 = rotatePointAboutLine( offset1, angIncr, end1, end2 );
    
            end1Verts[ i ] = new PVector( offset1.x, offset1.y, offset1.z );
    
            offset2 = rotatePointAboutLine( offset2, angIncr, end1, end2 );
    
            end2Verts[ i ] = new PVector( offset2.x, offset2.y, offset2.z );
        }
    
        tube = createShape();
        tube.beginShape( QUADS );
    
        for ( int i = 0; i < numSides; i++ )
        {
            PVector end1 = end1Verts[ i % numSides ],
                    end2 = end2Verts[ i % numSides ],
                    v3 = end2Verts[ ( i + 1 ) % numSides ],
                    v4 = end1Verts[ ( i + 1 ) % numSides ];
    
            tube.vertex( end1.x, end1.y, end1.z );
            tube.vertex( end2.x, end2.y, end2.z );
            tube.vertex( v3.x, v3.y, v3.z );
            tube.vertex( v4.x, v4.y, v4.z );
        }
        tube.endShape( CLOSE );
    
        cyl.addChild( tube );
    }
    
    // end calcCylinderVerts()
    
    //---------------------------------------------------------------------------------------------------------------------
    
    // ROTATE POINT ABOUT LINE
    // -----------------------
    
    // http://paulbourke.net/geometry/rotate/example.c
    // by Ronald Goldman
    
    // NOTE: THETA denotes the ANGLE INCREMENT between points, NOT a cumulative angle; i.e., always pass only
    // the angIncr, NOT 'angle + angIncr'.
    
    /*  Code from Paul Bourke's article, "Rotate a point about an arbitrary axis (3 dimensions)"
     *  http://paulbourke.net/geometry/rotate/
     *  Code: http://paulbourke.net/geometry/rotate/example.c
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
    
    // CREATE CAP
    // ----------
    
    PShape createCap( PVector center, PVector[] verts, int type )
    {
        PShape s = null;
    
        if ( type == FLAT )
        {
            s = createShape();
            s.beginShape( TRIANGLE_FAN );
            s.vertex( center.x, center.y, center.z );
    
            for ( int i = 0; i < verts.length; i++ )
            {
                s.vertex( verts[ i ].x, verts[ i ].y, verts[ i ].z );
            }
    
            s.vertex( verts[ 0 ].x, verts[ 0 ].y, verts[ 0 ].z );
            s.endShape();
        }
        else if ( type == BALL )
        {
            pushMatrix();
            noStroke();
            s = createShape( SPHERE, radius );
            s.translate( center.x, center.y, center.z );
            popMatrix();
        }
        else if ( type == CONE )
        {
            PVector cylCenter;
    
            if ( center.x == end1.x && center.y == end1.y && center.z == end1.z )
            {
                cylCenter = PVector.sub( end1, end2 );
                cylCenter.setMag( radius * 2 );
                cylCenter.add( end1 );
            }
            else
            {
                cylCenter = PVector.sub( end2, end1 );
                cylCenter.setMag( radius * 2 );
                cylCenter.add( end2 );
            }
    
            s = createShape();
            s.beginShape( TRIANGLE_FAN );
            s.vertex( cylCenter.x, cylCenter.y, cylCenter.z );
    
            for ( int i = 0; i < verts.length; i++ )
            {
                s.vertex( verts[ i ].x, verts[ i ].y, verts[ i ].z );
            }
    
            s.vertex( verts[ 0 ].x, verts[ 0 ].y, verts[ 0 ].z );
            s.endShape();
        }
    
        return s;
    }
    
    // end createCap()
    
    //---------------------------------------------------------------------------------------------------------------------
}
// end class Cylinder   

 
 
 
 
 
 
 
 
 
 
 