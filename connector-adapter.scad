// GoPro-like connector adapter
// Version 1
//
// Adapter to connect a GoPro connector to something else in similar shape.
//
// Each side of the adapter consists of a number of legs that end in a semicircle and
// have a hole in the middle. The geometry can be specified for each side (see variable 
// definitions in the code below).
//
// For printing, supports must be used, especially if the outer radii of both sides differ. 
//
// Copyright (c) 2021 regenschein71
// https://github.com/regenschein71/gopro-adapter

/////////////////////////////////////////////////////////////
// Edit geometry here
/////////////////////////////////////////////////////////////

// Thickness of the plate connecting the parts
baseThickness = 4;

// Geometry of first side

// Number of legs on side 1
numLegs1 = 2;

// Outer radius (or half-width) of the legs on side 1
outerRadius1 = 4.0;

// Radius of the inner whole in the legs on side 1
innerRadius1 = 1.5;

// Thickness of each leg on side 1
legThickness1 = 4.0;

// Length of the leg
legLength1 = 20;

// Distance between the legs on side 1
legSpacing1 = 10.0;

// Number of leg which should have a hex coutout (0 = none)
innerHexPos1 = 0;

// Radius of the Hex cutout, usually more than the inner radius
innerHexRadius1 = 2;


// Geometry of second  side
// The predefined values fit a GoPro mount.

// Number of legs on side 2
numLegs2 = 2;

// Outer radius (or half-width) of the legs on side 2
outerRadius2 = 7.5;

// Radius of the inner whole in the legs on side 2
innerRadius2 = 2.65;

// Thickness of each leg on side 2
legThickness2 = 2.9;

// Length of the leg
legLength2 = 100;

// Distance between the legs on side 2
legSpacing2 = 3.3;

// Number of leg which should have a hex coutout (0 = none) on side 2
innerHexPos2 = 0;

// Radius of the Hex cutout on side 2, usually more than the inner radius
innerHexRadius2 = 4;


/////////////////////////////////////////////////////////////
// Nothing more to edit here
/////////////////////////////////////////////////////////////

// Main program

// Rotate to printing position, legs spaced along the y-axis
rotate ([90,0,0]) {
    union() {
        // Create first side
        side(numLegs1, legLength1, outerRadius1, innerRadius1, legThickness1, legSpacing1, innerHexPos1, innerHexRadius1);
        
        // Create other side, rotate to extend in -x direction
        rotate ([0,0,180]) side(numLegs2, legLength2, outerRadius2, innerRadius2, legThickness2, legSpacing2, innerHexPos2, innerHexRadius2);
        
        maxWidth=max(outerRadius1, outerRadius2);
        maxHeight=max(height(numLegs1, legThickness1, legSpacing1), height(numLegs2, legThickness2, legSpacing2));
        
        // Connecting base plate
        cube ([baseThickness, 2 *maxWidth, maxHeight], true);
    }
}

// Create one side of the adapter with the specified number of legs and spacing
// The result is aligned with the legs stacked vertically and the base plate centered on the y-axis
module side(numLegs=2, legLength=0, outer=2, inner=1, thickness=1, space=1, innerHexPos=0, innerHexRadius=0) {
    
    // Distance between the outside surfaces of the outermost legs
    totalHeight = height(numLegs, thickness, space);
    
    // Offset for positioning the legs vertically
    totalHeightOffset = ((numLegs - 1) * (thickness + space)) / 2;
        
    // translate ([-(2*outer -baseThickness/2) ,0,0]) 
    translate ([-(outer + legLength + baseThickness/2) ,0,0]) 
        union() {
            for (i=[1:numLegs]) {
                
                vOffset=(thickness + space) * (i-1);
                
                if (i == innerHexPos) {
                    translate ([0,0,vOffset - totalHeightOffset]) leg(outer, innerHexRadius, thickness, true, legLength);
                } else {
                    translate ([0,0,vOffset - totalHeightOffset]) leg(outer, inner, thickness, false, legLength);
                }
            }
        }
}

// Create one leg, consisting of a circle and a box, with a hole in the circle
// The leg will be centered on the origin with the circles' center and aligned
// on the x/y-axis
module leg(outer=2, inner=1, thickness=1, innerHex=false, legLength=0) {
       difference() {
            union() {
                cylinder(thickness,outer,outer,true,$fn=16);
                translate ([(outer + legLength)/2,0,0]) cube([outer + legLength,2 * outer, thickness], true);
            }    
            if (innerHex) {
                cylinder(thickness * 1.1,inner, inner,true,$fn=6);
            } else {
                cylinder(thickness * 1.1,inner, inner,true,$fn=16);
            }
    }
}

// Calculate total height of the specified legs
function height(numLegs=1,thickness=1, space=1) = (numLegs  * thickness + (numLegs - 1) * space);   


