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

// Rotation of the two parts
rotate = false;


// Geometry of first side

// Number of legs on side 1
numLegs1 = 2;

// Outer radius (or half-width) of the legs on side 1
outerRadius1 = 5.0;

// Radius of the inner whole in the legs on side 1
innerRadius1 = 1.75;

// Thickness of each leg on side 1
legThickness1 = 3.0;

// Length of the leg
legLength1 = 20;

// Distance between the legs on side 1
legSpacing1 = 3.5;

// Number of supports on the first leg
legSupports1 = 0;

// Number of leg which should have a hex coutout (0 = none)
innerHexPos1 = 1;

// Radius of the Hex cutout, usually more than the inner radius
innerHexRadius1 = 3.1;

// Depth of the inner hexcutout. Use negative values for first leg and positive values for last leg
innerHexDepth1 = -1.5;



// Geometry of second  side

// Number of legs on side 2
numLegs2 = 3;

// Outer radius (or half-width) of the legs on side 2
outerRadius2 = 5;

// Radius of the inner whole in the legs on side 2
innerRadius2 = 1.75;

// Thickness of each leg on side 2
legThickness2 = 3.0;

// Length of the leg
legLength2 = 20;

// Distance between the legs on side 2
legSpacing2 = 3.5;

// Number of supports on the first leg
legSupports2 = 0;

// Number of leg which should have a hex coutout (0 = none) on side 2
innerHexPos2 = 1;

// Radius of the Hex cutout on side 2, usually more than the inner radius
innerHexRadius2 = 3.1;

// Depth of the inner hexcutout. Use negative values for first leg and positive values for last leg
innerHexDepth2 = -1.5;

/////////////////////////////////////////////////////////////
// Nothing more to edit here
/////////////////////////////////////////////////////////////

// Main program

// Rotate to printing position, legs spaced along the y-axis
rotate ([90,0,0]) {
    union() {
        // Create first side
        side(numLegs1, legLength1, legSupports1, outerRadius1, innerRadius1, legThickness1, legSpacing1, innerHexPos1, innerHexRadius1, innerHexDepth1);
        

        // Create other side, mirror (by double rotation) to extend in -x direction
        if (rotate == true) {
            rotate ([90,0,180]) side(numLegs2, legLength2, legSupports2, outerRadius2, innerRadius2, legThickness2, legSpacing2, innerHexPos2, innerHexRadius2, innerHexDepth2);
            maxHeight=max(height(numLegs1, legThickness1, legSpacing1), 2 * outerRadius2);
            maxWidth=max(2 * outerRadius1, height(numLegs2, legThickness2, legSpacing2));
            // Connecting base plate
            cube ([baseThickness, maxWidth, maxHeight], true);
        } else {
            rotate ([0,0,180]) side(numLegs2, legLength2, legSupports2, outerRadius2, innerRadius2, legThickness2, legSpacing2, innerHexPos2, innerHexRadius2, innerHexDepth2);
            maxWidth=max(outerRadius1, outerRadius2);
            maxHeight=max(height(numLegs1, legThickness1, legSpacing1), height(numLegs2, legThickness2, legSpacing2));
            // Connecting base plate
            cube ([baseThickness, 2 *maxWidth, maxHeight], true);
        }            
        
    }
}

// Create one side of the adapter with the specified number of legs and spacing
// The result is aligned with the legs stacked vertically and the base plate centered on the y-axis
module side(numLegs=2, legLength=0, legSupports=2, outer=2, inner=1, thickness=1, space=1, innerHexPos=0, innerHexRadius=0, innerHexDepth=0) {
    
    // Distance between the outside surfaces of the outermost legs
    totalHeight = height(numLegs, thickness, space);
    
    // Offset for positioning the legs vertically
    totalHeightOffset = ((numLegs - 1) * (thickness + space)) / 2;
        
    // translate ([-(2*outer -baseThickness/2) ,0,0]) 
    translate ([-(outer + legLength + baseThickness/2) ,0,0]) 
        union() {
                for (i=[1:numLegs]) {
                    
                    vOffset=(thickness + space) * (i-1);
                    

                    translate ([0,0,vOffset - totalHeightOffset]) 
                        union() {
                            if (i == innerHexPos) {
                                leg(outer, inner, thickness, true, innerHexRadius, innerHexDepth, legLength);
                            } else {
                                leg(outer, inner, thickness, false, innerHexRadius, innerHexDepth, legLength);
                            }
                            
                        }
                }
            // Add supports for the legs
            if (legSupports > 0) {
                dist = outer * 2;
                for (l=[0:(legSupports-1)]) {
                    offset=((legLength - outer) / (legSupports)) * l + 2 * outer;
                    translate ([offset, 0, 0]) cube([thickness, 2*outer, height(numLegs, thickness, space)], true);
                }
            }
        }
}

// Create one leg, consisting of a circle and a box, with a hole in the circle
// The leg will be centered on the origin with the circles' center and aligned
// on the x/y-axis
module leg(outer=2, inner=1, thickness=1, innerHex=false, hexRadius=0, hexDepth=0, legLength=0) {
       difference() {
            union() {
                cylinder(thickness,outer,outer,true,$fn=16);
                translate ([(outer + legLength)/2,0,0]) cube([outer + legLength,2 * outer, thickness], true);
            }    
            
            union() {
                cylinder(thickness * 1.1,inner, inner,true,$fn=16);
                
                if (innerHex) {
                    if (hexDepth > 0) {
                        translate ([0, 0, thickness - hexDepth]) cylinder(thickness * 1.01, hexRadius, hexRadius,true,$fn=6);
                    } else {
                        translate ([0, 0, - (hexDepth + thickness)]) cylinder(thickness * 1.01, hexRadius, hexRadius,true,$fn=6);
                    }
                    
                }
            }
    }
}

// Calculate total height of the specified legs
function height(numLegs=1,thickness=1, space=1) = (numLegs  * thickness + (numLegs - 1) * space);   


