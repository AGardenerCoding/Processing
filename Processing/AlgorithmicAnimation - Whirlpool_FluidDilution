/*
 * Whirlpool_FluidDilution.pde
 * ===========================
 *
 *  8-6-22
 *
 *  Port of a java application, Whirlpool aka Fluid Dilution, written 9-1-2010 by w.j.baker
 * 
 */
 //--------------------------------------------------------------------------------------------------------------------
 
 PVector[] distortMap;

double rotAngle,
       scale = 2.0;

int numPixels,
    centerX,
    centerY,
    halfWidth,
    halfHeight;

boolean palWrapOn = true,
        modOn = true;
        
//--------------------------------------------------------------------------------------------------------------------
    
// SETUP
// -----

void setup()
{
    fullScreen();
    frameRate( 8 );
    
    // Avoid having to click sketch window to close with a keypress.
    ((java.awt.Canvas) surface.getNative()).requestFocus(); 
    
    numPixels = width * height;
    centerX = width / 2;
    centerY = height / 2;
    halfWidth = centerX;
    halfHeight = centerY;
    
    distortMap = new PVector[ numPixels ];
    
    for ( int i = 0, x = 0, y = 0; i < numPixels; i++ )
    {
        distortMap[ i ] = new PVector( x, y );           
        
        x++;
        if ( x == width )
        {
            x = 0;
            y++;
        }   
    }
    
    setUpDistortMaps();

}

// end setup()

//--------------------------------------------------------------------------------------------------------------------

// DRAW
// ----
    
public void draw()
{
    double xSqd,
           ySqd,
           newX,
           newXSqd,
           newY,
           newYSqd,
           factor,
           angRads = rotAngle * (Math.PI/180.0),
           sinAngRads = Math.sin(angRads),
           cosAngRads  = Math.cos(angRads),
           multiX = -0.017, //0.0105
           multiY = 0.023;  //0.0197

    int x,
        y,
        tempX,
        tempY,
        rotX,
        rotY,
        dist,
        xDist,
        yDist,
        r,
        gr,
        b,
        scrnX = 0,
        scrnY = 0,
        clrNum,
        clrChangeVal;
          
    // Makes centerX oscillate between left and right sides of window; the multiplicand
    // affects the speed of movement because it specifies the number of cycles across
    // the screen width (or up and down)
    
    // NOTE: reversing sign of half width and height reverses orientation
    centerX = ( int ) ( ( halfWidth * Math.sin( frameCount * multiX ) + halfWidth ) );
    
    // Makes centerY oscillate between top and bottom of window
    centerY = ( int ) ( ( halfHeight * Math.cos( frameCount * multiY ) + halfHeight ) );
    
    //-----------------------------------
    
    loadPixels();
    
    for ( int i = 0; i < numPixels; i++ )
    {
        x = floor( distortMap[ i ].x );
        y = floor( distortMap[ i ].y );
        
        xDist = centerX - x;
        yDist = centerY - y;
        dist = ( int ) ( Math.sqrt( xDist * xDist + yDist * yDist ) );
                    
        //---------------------------------------------------------
        // ROTATIONS
        //----------
        // Subtracting by centerX and centerY rotates around center
        //---------------------------------------------------------
        // Using absolute value makes quadrants mirrored across centerPoint,
        // without abs val, everything rotates.
        //tempX = Math.abs(x - centerX);
        //tempY = Math.abs(y - centerY);
        
        tempX = x - centerX;
        tempY = y - centerY;
        //tempX *= scale;
        //tempY *= scale;
        
        rotX = ( int ) ( ( tempX * cosAngRads - tempY * sinAngRads ) );
        rotY = ( int ) ( ( tempX * sinAngRads + tempY * cosAngRads ) );
                                
        gr = ( int ) ( Math.getExponent( ( rotX * tempX ) * ( rotY * tempY ) ) * dist * 0.25 );
        gr |= ( xDist ^ yDist ) | dist;
        
        r = ( int ) ( gr - frameCount );
        r &= gr;
        
        b = gr + ( rotX | rotY );
        
        r |= b;
        gr -= b;
        b -= r;         
        
        //---------------------
        
        clrChangeVal = frameCount;
        
        r  += ( int ) ( clrChangeVal * 0.19 * sinAngRads ); // 0.19
        gr += ( int ) ( clrChangeVal * 0.17 * cosAngRads ); // 0.17         
        b  += ( int ) ( clrChangeVal * 0.23 * angRads ); // 0.23
            
        //------------------------------------
        // palWrap and mod are on by default, but if palWrap is on, mod
        // does not get accessed
        if ( palWrapOn )
        {
            r &= 511;
            gr &= 511;
            b &= 511;
            
            if (  r > 255 ) {   r = 511 - r;    }
            if ( gr > 255 ) {   gr = 511 - gr;  }
            if (  b > 255 ) {   b = 511 - b;    }                                   
        }
        else if ( modOn )
        {
            r %= 256;
            gr %= 256;
            b %= 256;
            r &= 255;
            gr &= 255;
            b &= 255;                    
        }
        else
        {
            r &= 255;
            gr &= 255;
            b &= 255;                    
         }
            //--------
        
        clrNum = color( r, gr, b );
        pixels[ i ] = clrNum;

        if ( scrnX < width - 1 )
        {
            scrnX++;
        }
        else
        {
            scrnX = 0;
            scrnY++;
        }           

        //rotAngle += 0.1;
        
    } // end for ( i... )

    updatePixels();
    rotAngle += 0.5; 

    if ( frameCount % 100 == 0 )
    {
        println( frameRate );
    }
}

// end draw()

//--------------------------------------------------------------------------------------------------------------------
    
void setUpDistortMaps()
{
    inversion( width * 0.3, centerX - 150, centerY + 100 );         
    
    //spiral(double maximum angle of rotation, int xCenter, int yCenter)
    spiral( 160.0, centerX, centerY );

    //cone(double thetaMod, double radiusMod)     // theta Modifier : even whole numbers only
    cone( 6, 400 );

    inversion( width * 0.185, centerX + 150, centerY - 50 );
}

//--------------------------------------------------------------------------------------------------------------------

// INVERSION
//----------

private void inversion( double invCircleRadius, double invCntrX, double invCntrY )                                                  
{       
    // The inversion of {x,y} with respect to a circle centered at {a,b} 
    // and radius r is 
    // newX=a + (r^2*(-a + x))/((a - x)^2 + (b - y)^2)
    // newY=b + (r^2*(-b + y))/((a - x)^2 + (b - y)^2) 
    
    
    double r = invCircleRadius,
           rSqd = r * r,
           a = invCntrX,
           b = invCntrY,
           aMinusXSqd = 0,
           bMinusYSqd = 0;
    
    float x = 0,
          y = 0,
          newX = 0, 
          newY = 0;
            
    for( int i = 0; i < numPixels; i++ )
    {
        x = distortMap[ i ].x;
        y = distortMap[ i ].y;
        
        aMinusXSqd = ( a - x ) * ( a - x );
        bMinusYSqd = ( b - y ) * ( b - y );
        newX = ( float ) ( a + ( rSqd * ( -a + x ) ) / ( aMinusXSqd + bMinusYSqd ) );                                                                           
        newY = ( float ) ( b + ( rSqd * ( -b + y ) ) / ( aMinusXSqd + bMinusYSqd ) );
        
        distortMap[ i ] = new PVector( newX, newY );
    }   

    
} // end Inversion()

//--------------------------------------------------------------------------------------------------------------------

// ROTATION in the xy plane, around the z-axis
// --------

private void rotation( double rotAngle, double xOff, double yOff )
{
    double x = 0.0,
           y = 0.0,
           angRads = rotAngle * (Math.PI / 180.0),
           sinAngRads = Math.sin(angRads),
           cosAngRads = Math.cos(angRads),
           xOffset = centerX - xOff,
           yOffset = centerY - yOff;
    
    for( int i = 0; i < numPixels; i++ )
    {
        x = distortMap[ i ].x - xOffset;
        y = distortMap[ i ].y - yOffset;                       
        distortMap[ i ] = new PVector( ( float ) ( x * cosAngRads - y * sinAngRads + xOffset ),  
                                       ( float ) ( x * sinAngRads + y * cosAngRads + yOffset ) );
    }   
    
} // end rotation()

//--------------------------------------------------------------------------------------------------------------------

// SPIRAL
// ------

/*
 *  Modified from "KickAss Java Programming", by Tonny Espeset, ImageProcessor class
 */

public void spiral( double angle, int xCenter, int yCenter )
{
    double xPos=0,
           yPos=0,        
           tempx = 0.0,
           tempy = 0.0,
           newx = 0.0,
           newy = 0.0,        
           transx = 0,
           transy = 0,
           angleRadians = angle / ( 180.0 / Math.PI ),
           maxDist = Math.sqrt( width * width + height * height ),
           scale = angleRadians / maxDist,        
           ang = 0,
           cosAng = 0,
           sinAng = 0;
            
    int yLine = 0;
    int index = 0;
    
    for ( int y = 0; y < height; y++ )
    {             
        yLine = y * width;
        
        for ( int x = 0; x < width; x++ )
        {
            index = yLine + x;
            
            tempx = distortMap[ index ].x - xCenter;
            tempy = distortMap[ index ].y - yCenter;
            
            ang = Math.sqrt( tempx * tempx + tempy * tempy ) * scale;
            cosAng = Math.cos( ang );
            sinAng = Math.sin( ang );
            
            // spiral transform 
            transx = tempx * cosAng - tempy * sinAng;
            transy = tempy * cosAng + tempx * sinAng;
         
            distortMap[ index ] = new PVector( ( float ) ( transx + xCenter ), ( float ) ( transy + yCenter ) );
        }
    }
}

// end spiral()

//--------------------------------------------------------------------------------------------------------------------

// CONE
// ----

/* From Chapter 4, Altered Images, in the book "Beyond Photography"
 *
 *  "The effect is that the image shrinks toward the center. You can think
 *   of it as the projection of the image onto a cone, with the tip of the
 *   cone in the middle of the picture."
 *
 *  x = sqrt(radius * 400) * cos(angle)
 *  y = sqrt(radius * 400) * sin(angle)
 * 
 *  Note: modified by multiplying theta by 2. Without this, the cone
 *        reaches only 180 degrees around (right side only). Multiplying by
 *        2 makes the cone stretch the full 360 degrees. 1-3-09
 *
 *
    "...transformed with the
    following expression, where r and a give radius and angle of location x , y .
    Function sqr t computes a square root, and cartx and carty convert from polar
    coordinates to Cartesian coordinates.
    
    new[x , y ] = [cartx (sqrt (r *400), a), carty (sqrt (r *400), a)]
    
    The effect is that the image shrinks toward the center. You can think of it as a
    projection of the image onto a cone, with the tip of the cone in the middle of
    the picture."
 
 */ 
 
 /* As odd as this seems, the modifications to the equations below seem to be
  * the closest I can get to what seems to be correct, visually anyhow.
  * 
  * It required adding tempx * 2 and tempy * 2 to the transx and transy equations,
  * then transx / 2 and transy / 2 in the final lines. I don't know why, this was
  * completely trial and error.
  */
 
public void cone( double thetaMod, double radiusMod )     // theta Modifier : even whole numbers only
{
    double tempx = 0.0,
           tempy = 0.0,
           transx = 0,
           transy = 0,       
           theta = 0,
           radius = 0;
            
    int yLine = 0,
        index = 0;
    
    
    for ( int y = 0; y < height; y++ )
    {             
        yLine = y * width;
        
        for ( int x = 0; x < width; x++ )
        {
            index = yLine + x;
            
            tempx = distortMap[ index ].x - centerX;
            tempy = distortMap[ index ].y - centerY;
            
            // wjb modified theta 
            theta = thetaMod * Math.atan( tempy  / tempx );
            radius = Math.sqrt( tempx * tempx + tempy * tempy ) * radiusMod;
            
            // cone transform : cart(sqrt r, theta), cart(sqrt r, theta))
            // polar to cartesian conversion: x = r * cos(theta), y = r * sin(theta)
            transx = Math.sqrt( radius ) * Math.cos( theta ) + tempx * 2;
            transy = Math.sqrt( radius ) * Math.sin( theta ) + tempy * 2;
                                           
            distortMap[index] = new PVector( ( float ) ( ( transx / 2 ) + centerX ),
                                             ( float ) ( ( transy / 2 ) + centerY ) );    
        }
    }
} 

// end cone()

//--------------------------------------------------------------------------------------------------------------------

// KEY PRESSED
// -----------

public void keyPressed() 
{
    noLoop();
    exit(); 
}    

// end keyPressed()

//--------------------------------------------------------------------------------------------------------------------
