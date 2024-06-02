/*
 Picture Mat, version 2.0
 Copyright 2024 Tyler Tork
 Licensed under Creative Commons - Attribution - Non-Commercial - Share Alike
    https://creativecommons.org/licenses/by-nc-sa/4.0/
 
 This script creates a flat rectangular insert of a specified size, with a cutout in the middle. This is intended to be placed over a piece of framed artwork to set it off against the frame.
 
 This script uses the roof() built-in function, which is available in recent OpenSCAD client builds if you enable it on the Edit > Preferences > Features screen.
 
 You have to option of selecting "Custom" shape of the mat opening, and using an SVG file to specify that shape. However, if you are running the script on Makerworld, SVG file importing is not supported.
 
 The cutout has an adjustable edge slant from 30 to 90 degrees from the horizontal.
 */

/* [Mat] */
Mat_width = 100;  // 0.1
Mat_height = 131;  // 0.1
Mat_depth = 1.3; // 0.1
/* [Cutout] */
Cutout_width = 73; // 0.1
Cutout_height = 104; // 0.1
Cutout_shape = "r"; // [r:Rectangular,o:Oval,c:Custom]
Cutout_offset_x = 0; // 0.1
Cutout_offset_y = 0; // 0.1
Cutout_angle = 45; //[30:1:90]
// If you use Custom shaped cutout, path of SVG file that defines the shape. This requires OpenSCAD client.
SVG_filename = "";
// if you selected Rectangular shape
Rectangle_corner_radius = 0; // 0.2
// if the cutout has pointy corners, the corresponding corners at the top of the opening should be...
Corner_shape = "p"; // [p:pointy,r:rounded]

/* [Hidden] */
$fa = 1;
$fs = 0.4;
dMat = [Mat_width, Mat_height, Mat_depth];
offs = Mat_depth*tan(90-Cutout_angle);
dHole = [min(Cutout_width, dMat.x-2*offs-2), min(Cutout_height, dMat.y-2*offs-2)];
leeway = (dMat-dHole-[2*offs+2,2*offs+2])/2;

moveHole = [max(min(leeway.x, Cutout_offset_x), -leeway.x), max(min(leeway.y, Cutout_offset_y), -leeway.y), 0];

rad = min(max(Rectangle_corner_radius, 0), dHole.x/2-.01, dHole.y/2-.01);
type = Cutout_shape == "r" && rad > 0 ? "rr" : Cutout_shape;
bHull = Cutout_angle != 90 && (type == "c" || (type == "r" && Corner_shape != "p"));
ratio = [(2*offs)/dHole.x, (2*offs)/dHole.y];

module hole_shape(bTop = false) {
	cOffs = bTop ? [offs,offs] : [0.0];
	if (bTop) {
		if (Corner_shape == "r") {
			offset(r = offs) hole_shape(false);
		} else {
			offset(delta=offs, chamfer=(Corner_shape == "c")) hole_shape(false);
		}
	} else if (type == "r") {
		square(dHole, center = true);
	} else if (type == "rr") {
		offset(r=rad) square(dHole-2*[rad,rad], center = true);
	} else if (type == "o") {
		scale([1, dHole.y/dHole.x]) circle(d=dHole.x);
	} else if (type == "c") {
		translate(dHole/-2) resize(dHole) import(SVG_filename);
	}
}

module roof_hole() {
	dOuter = [dHole.x+offs*3,dHole.y+offs*3,offs];
	scale([1,1,(.002+dMat.z)/offs])
	difference() {
		translate([-dOuter.x/2,-dOuter.y/2,0])
			cube(dOuter);
		translate([0,0,-.001])
		roof(method=Corner_shape == "p" ? "straight" : "voronoi")
		difference() {
			square(dHole + [offs,offs]*6, center=true);
			hole_shape();
		}
	}
}

module hole() {
	htHole = dMat.z+.002;
	if (bHull) {
		color("pink")
		translate([0,0,-dMat.z/2-.001])
		roof_hole();
	} else {
		color("blue")
		linear_extrude(height=htHole, center=true, scale=[(dHole.x+2*offs)/dHole.x, (dHole.y+2*offs)/dHole.y])
		hole_shape();
	}
}

module main() {
	render()
	difference() {
		cube(dMat, center= true);
		translate(moveHole) hole();
	}
}

main();
//roof_hole();