/*
 *  Pipes.pde
 *  =========
 *
 *  'pipes' by w.j.baker
 *
 *  2-22-22
 *
 *  ENTER key restarts sketch
 *  SPACEBAR exits sketch
 *
 *  Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) 
 *  https://creativecommons.org/licenses/by-nc-sa/4.0/
 *
 */
//=====================================================================================================================

import java.util.*;

ArrayList<Cylinder> pipes;

Cylinder curPipe,
         nextPipe;

PVector posTotal,
        posAvg,
        curRotPosAvg,
        moveToPosAvg;

static final float FOUR_PI = PI * 4.0f;

float minPipeRadius = 125,
      maxPipeRadius = 525 - minPipeRadius,
      pipeRadius,
      rx,
      ry,
      cameraZ,
      piDiv3,
      wDivH,
      zNear,
      zFar,
      rotAngle,
      rotAngleIncr = -0.00125f,
      moveToPosFrac,
      textAlpha;

static final int N = 0,
                 E = 1,
                 S = 2,
                 W = 3,
                 IN = 4,
                 OUT = 5;

int pipeStrokeClr,
    pipeFillClr,
    numSides = 36,
    pipeMinLength = 1000,   // 750
    pipeMaxLength = 7500,   // 5000
    curPipeTargetLength,
    changeSpeed = 100,
    initOriginZCoord = -21000,  // Negative values move origin into screen, away from viewer.
    originZCoord,
    curDir,
    oldDir,
    curPipeNum,
    centerX,
    centerY;

boolean isFirstPipe;

//-----------------------------------------------------------------------------------------------------------------

// SETUP
// -----

void setup()
{
    fullScreen( P3D ); 
    centerX = width / 2;
    centerY = height / 2;
    background( 0 );
    noCursor();

    /* --------------------------------------------------
     * https://processing.org/reference/perspective_.html
     *
     * https://discourse.processing.org/t/
     *         what-is-the-distance-of-the-camera-from-the-x-y-0-plane-in-p3d/4388
     *
     * "After decoding the mysterious (height/2)/(tan(pi/6)) value in the default preset for the
     * camera() function, I've noticed it is just the height of an equilateral triangle, meaning the
     * camera has an angular span of 120 degrees and is sqrt(3)/2*height pixels away from the drawn plane."
     *
     * --------------------------------------------------
     */

    // Default values for perspective()
    cameraZ = ( ( height / 2.0f ) / tan( PI * 60.0f / 360.0f ) );   // 935.30743
    piDiv3 = PI / 3.0f;
    wDivH = width / height;
    zNear = cameraZ * 0.1f;     // 93.53075  orig:cameraZ / 10.0f;
    zFar =  cameraZ * 100.0f;   // 93530.74  orig:cameraZ * 10.0f;
    // --------------------------------------------------

    pipes = new ArrayList<Cylinder>();

    int range = 300;
    pipeRadius = maxPipeRadius + minPipeRadius; 
    curDir = floor( random( 6 ) );
    curPipeTargetLength = floor( random( pipeMinLength, pipeMaxLength ) );
    
    // For 'ENTER' restart
    curPipeNum = 0;
    frameCount = 1;
    rotAngle = 0;
    isFirstPipe = true;
    originZCoord = initOriginZCoord;
    moveToPosFrac = 0.0f;

    //PVector end1 = new PVector( centerX, centerY, originZCoord / 3 ),
    PVector end1 = new PVector( random( -range, range ),
                                random( -range, range ),
                                originZCoord * 0.25f ),
            end2 = getStartDirection( end1, curDir );

    posTotal = PVector.add( end1, end2 );
    posAvg = PVector.div( posTotal, 2.0f );
    curRotPosAvg = posAvg.copy();
    moveToPosAvg = curRotPosAvg.copy();

    // PIPE COLORS
    pipeStrokeClr = color( 255 );
    stroke( pipeStrokeClr );
    pipeFillClr = color( 80, 112, 255 );
    fill( pipeFillClr );

    //PVector end1, PVector end2, int numSides, float radius,
    //                                          boolean addCap1, boolean addCap2, int cap1Type, int cap2Type
    curPipe = new Cylinder( end1, end2, numSides, pipeRadius, false, false, 0, 0 );
    pipes.add( curPipe );
}

// end setup()

//-----------------------------------------------------------------------------------------------------------------

// DRAW
// ----
    
void draw()
{
    background( 0 );
    perspective( piDiv3, wDivH, zNear, zFar );  // Added this to reset zFar to greater distance.

    translate( centerX, centerY, originZCoord );

    ambientLight(102, 102, 102);
    lightSpecular(204, 204, 204);
    directionalLight(102, 102, 102, 0, 0, -1);
    specular(255, 255, 255);
    shininess(5.0f);

    //doManualRotation();
    //drawAxes();
    translate( moveToPosAvg.x, moveToPosAvg.y, moveToPosAvg.z );
    rotateY( rotAngle );
    rotateX( rotAngle * 0.5f );
    translate( -moveToPosAvg.x, -moveToPosAvg.y, -moveToPosAvg.z );
    rotAngle += rotAngleIncr;


    for ( Cylinder c : pipes )
    {
        shape( c.cyl );
    }

    //------------------------------------------------------------------

    if ( curPipe.length < curPipeTargetLength )
    {
        curPipe.changeLength( changeSpeed );
    }

    else
    {
        if ( isFirstPipe )
        {
            isFirstPipe = false;

            // Add both end caps to first pipe.
            curPipe = new Cylinder( curPipe.end1, curPipe.end2, numSides, pipeRadius,
                                    true, true, Cylinder.BALL, Cylinder.BALL );
        }
        else
        {
            // Add an end cap to curPipe.
            curPipe = new Cylinder( curPipe.end1, curPipe.end2, numSides, pipeRadius,
                                    false, true, 0, Cylinder.BALL );
        }

        // Remove the old version of curPipe and replace it with the finished version.
        pipes.remove( pipes.size() - 1 );
        pipes.add( curPipe );

        // Create the next pipe.
        PVector newEnd = changeDirection( curPipe, curDir );
        newEnd.normalize();
        newEnd.setMag( 100 );
        newEnd.add( curPipe.end2 );

        pipeRadius = minPipeRadius + maxPipeRadius * ( 1.0f - abs( sin( frameCount * 0.0005f ) ) );
        nextPipe = new Cylinder( curPipe.end2, newEnd, numSides, pipeRadius, false, false, 0, 0 );
        pipes.add( nextPipe );

        // Transfer the curPipe designation to the newest pipe.
        curPipeNum++;
        curPipe = pipes.get( curPipeNum );
        curPipeTargetLength = floor( random( pipeMinLength, pipeMaxLength ) );

        // 'posTotal' is a running sum of all newEnd positions. 'posAvg' is the average position, which
        // will be used as the rotation point. 'moveToPosAvg' is a fraction of the distance between current
        // rotation position and posAvg, and is used to gradually move toward the average position to
        // avoid the jerking motion of moving suddenly to the new average position.
        posTotal = PVector.add( posTotal, newEnd );
        posAvg = PVector.div( posTotal, curPipeNum );

        if ( moveToPosFrac < 0.35f )
        {
            moveToPosFrac = frameCount / 50000.0f;
        }

        moveToPosAvg = PVector.lerp( curRotPosAvg, posAvg, moveToPosFrac );
    }
}

// end draw()

//-----------------------------------------------------------------------------------------------------------------

// GET START DIRECTION
// -------------------

PVector getStartDirection( PVector v1, int dir )
{
    PVector v2 = new PVector();

    switch( dir )
    {
        case N:
            v2 = new PVector( v1.x + 0.001f, v1.y - 1, v1.z + 0.001f );
        break;

        case E:
            v2 = new PVector( v1.x + 1, v1.y + 0.001f, v1.z + 0.001f );
        break;

        case S:
            v2 = new PVector( v1.x + 0.001f, v1.y + 1, v1.z + 0.001f );
        break;

        case W:
            v2 = new PVector( v1.x - 1, v1.y + 0.001f, v1.z + 0.001f );
        break;

        case IN:
            v2 = new PVector( v1.x + 0.001f, v1.y + 0.001f, v1.z - 1 );
        break;

        case OUT:
            v2 = new PVector( v1.x + 0.001f, v1.y + 0.001f, v1.z + 1 );
        break;
    }

    return v2;
}

// end getStartDirection()

//---------------------------------------------------------------------------------------------------------------

// CHANGE DIRECTION
// ----------------

// I finally discovered that for direction changes to in or out, the offset from the end2 must be *very* large.
// If it's small, the direction is completely wrong.

PVector changeDirection( Cylinder can, int curDirection )
{
    //-----------------------------------
    // The field of view is wider with greater z-depth ( dist from viewer ).
    // Modify edge limits by z-depth, which is always positive.

    float frustumOffset = abs( can.end2.z * 0.65f ),    // value from repeated observation
          minViewX = 0 - frustumOffset,
          maxViewX = width + frustumOffset,
          minViewY = 0 - frustumOffset,
          maxViewY = height + frustumOffset,
          minViewZ = -30000,                    // min here refers to farZ
          maxViewZ = 0;                         // and max to nearZ

    //-----------------------------------
    oldDir = curDirection;

    PVector v = new PVector();
    int choice = floor( random( 4 ) );

    //-----------------------------------
    if ( curDirection == N )
    {
        // Test whether x-pos is offscreen, if so turn opposite direction.
        if ( can.end2.x >= maxViewX )
        {
            choice = 1;
        }
        else if ( can.end2.x <= minViewX )
        {
            choice = 0;
        }
        else if ( can.end2.z <= minViewZ )
        {
            choice = 3;
        }
        else if ( can.end2.z >= maxViewZ )
        {
            choice = 2;
        }

        //--------------------------------

        switch( choice )
        {
            case 0: // turn east
                v = PVector.sub( can.end2, can.end1 );
                v.rotate( HALF_PI );
                curDir = E;
            break;

            case 1: // turn west
                v = PVector.sub( can.end2, can.end1 );
                v.rotate( -HALF_PI );
                curDir = W;
            break;

            case 2: // turn in
                v = new PVector( can.end2.x, can.end2.y, can.end2.z - 1000000000 );
                curDir = IN;
            break;

            case 3: // turn out
                v = new PVector( can.end2.x, can.end2.y, can.end2.z + 1000000000 );
                curDir = OUT;
            break;
        }

    } // end if ( curDirection == N )

    //-----------------------------------
    else if ( curDirection == E )
    {
        // Test whether y-pos is offscreen, if so turn opposite direction.
        if ( can.end2.y >= maxViewY )
        {
            choice = 0;
        }
        else if ( can.end2.y <= minViewY )
        {
            choice = 1;
        }
        else if ( can.end2.z <= minViewZ )
        {
            choice = 3;
        }
        else if ( can.end2.z >= maxViewZ )
        {
            choice = 2;
        }
        //--------------------------------

        switch( choice )
        {
            case 0: // turn north
                v = PVector.sub( can.end2, can.end1 );
                v.rotate( -HALF_PI );
                curDir = N;
            break;

            case 1: // turn south
                v = PVector.sub( can.end2, can.end1 );
                v.rotate( HALF_PI );
                curDir = S;
            break;

            case 2: // turn in
                v = new PVector( can.end2.x, can.end2.y, can.end2.z - 1000000000 );
                curDir = IN;
            break;

            case 3: // turn out
                v = new PVector( can.end2.x, can.end2.y, can.end2.z + 1000000000 );
                curDir = OUT;
            break;
        }
    } // end else if ( curDirection == E )

    //-----------------------------------
    else if ( curDirection == S )
    {
        // Test whether x-pos is offscreen, if so turn opposite direction.
        if ( can.end2.x >= maxViewX )
        {
            choice = 1;
        }
        else if ( can.end2.x <= minViewX )
        {
            choice = 0;
        }
        else if ( can.end2.z <= minViewZ )
        {
            choice = 3;
        }
        else if ( can.end2.z >= maxViewZ )
        {
            choice = 2;
        }
        //--------------------------------

        switch( choice )
        {
            case 0: // turn right
                v = PVector.sub( can.end2, can.end1 );
                v.rotate( -HALF_PI );
                curDir = E;
            break;

            case 1: // turn left
                v = PVector.sub( can.end2, can.end1 );
                v.rotate( HALF_PI );
                curDir = W;
            break;

            case 2: // turn in
                v = new PVector( can.end2.x, can.end2.y, can.end2.z - 1000000000 );
                curDir = IN;
            break;

            case 3: // turn out
                v = new PVector( can.end2.x, can.end2.y, can.end2.z + 1000000000 );
                curDir = OUT;
            break;
        }

    } // end else if ( curDirection == S )


    //-----------------------------------
    else if ( curDirection == W )
    {
        // Test whether y-pos is offscreen, if so turn opposite direction.
        if ( can.end2.y >= maxViewY )
        {
            choice = 0;
        }
        else if ( can.end2.y <= minViewY )
        {
            choice = 1;
        }
        else if ( can.end2.z <= minViewZ )
        {
            choice = 3;
        }
        else if ( can.end2.z >= maxViewZ )
        {
            choice = 2;
        }
        //--------------------------------

        switch( choice )
        {
            case 0: // turn up
                v = PVector.sub( can.end2, can.end1 );
                v.rotate( HALF_PI );
                curDir = N;
            break;

            case 1: // turn down
                v = PVector.sub( can.end2, can.end1 );
                v.rotate( -HALF_PI );
                curDir = S;
            break;

            case 2: // turn in
                v = new PVector( can.end2.x, can.end2.y, can.end2.z - 1000000000 );
                curDir = IN;
            break;

            case 3: // turn out
                v = new PVector( can.end2.x, can.end2.y, can.end2.z + 1000000000 );
                curDir = OUT;
            break;
        }
    } // end else if ( curDirection == W )

    //-----------------------------------
    else if ( curDirection == IN )
    {
        // Test whether x-pos is offscreen, if so turn opposite direction.
        if ( can.end2.x >= maxViewX )
        {
            choice = 3;
        }
        else if ( can.end2.x <= minViewX )
        {
            choice = 2;
        }
        // Test whether y-pos is offscreen, if so turn opposite direction.
        else if ( can.end2.y >= maxViewY )
        {
            choice = 0;
        }
        else if ( can.end2.y <= minViewY )
        {
            choice = 1;
        }
        //--------------------------------

        switch( choice )
        {
            case 0: // turn up
                v = new PVector( can.end2.x, can.end2.y - 1000000000, can.end2.z );
                curDir = N;
            break;

            case 1: // turn down
                v = new PVector( can.end2.x, can.end2.y + 1000000000, can.end2.z );
                curDir = S;
            break;

            case 2: // turn right
                v = new PVector( can.end2.x + 1000000000, can.end2.y, can.end2.z );
                curDir = E;
            break;

            case 3: // turn left
                v = new PVector( can.end2.x - 1000000000, can.end2.y, can.end2.z );
                curDir = W;
            break;
        }
    } // end else if ( curDirection == IN )

    //-----------------------------------
    else if ( curDirection == OUT )
    {
        // Test whether x-pos is offscreen, if so turn opposite direction.
        if ( can.end2.x >= maxViewX )
        {
            choice = 3;
        }
        else if ( can.end2.x <= minViewX )
        {
            choice = 2;
        }
        // Test whether y-pos is offscreen, if so turn opposite direction.
        else if ( can.end2.y >= maxViewY )
        {
            choice = 0;
        }
        else if ( can.end2.y <= minViewY )
        {
            choice = 1;
        }
        //--------------------------------

        switch( choice )
        {
            case 0: // turn up
                v = new PVector( can.end2.x, can.end2.y - 1000000000, can.end2.z );
                curDir = N;
            break;

            case 1: // turn down
                v = new PVector( can.end2.x, can.end2.y + 1000000000, can.end2.z );
                curDir = S;
            break;

            case 2: // turn right
                v = new PVector( can.end2.x + 1000000000, can.end2.y, can.end2.z );
                curDir = E;
            break;

            case 3: // turn left
                v = new PVector( can.end2.x - 1000000000, can.end2.y, can.end2.z );
                curDir = W;
            break;
        }
    } // end else if ( curDirection == OUT )

    v.x += 0.01f;
    v.y -= 0.01f;
    v.z -= 0.01f;

    return v;
}

// end changeDirection()

//---------------------------------------------------------------------------------------------------------------

// KEY PRESSED
// -----------

public void keyPressed() 
{
    if ( keyCode == 10 )        // ENTER
    {
        setup();
        loop();
    }
    else if ( keyCode == 32 )   // SPACEBAR
    {
        noLoop();
        exit(); 
    }
}    

// end keyPressed()

//-----------------------------------------------------------------------------------------------------------------







