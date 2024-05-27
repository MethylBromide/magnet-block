/*
 Light Picture Frame, version 0.0
 Copyright 2024 Tyler Tork
 
 This frame is parameterized using the Customizer to let you specify the dimensions of the artwork and the amount of frame you would like around the picture.

 If you use the "Recess" feature to make a pocket for the artwork to sit in, you may want to print that part with the front facing upwards and lots of supports, to have a nicer-looking upper surface.
 
 Licensed under Creative Commons - Attribution - Non-Commercial - Share Alike
    https://creativecommons.org/licenses/by-nc-sa/4.0/
 */

// Show the various parts:
Layout = "s"; // [s:Assembly diagram, f:Frame only, b:Block only]
/* [Frame dimensions (in mm)] */
// Total depth of frame (minimum -- will be deeper if needed to fit contents).
Frame_depth = 5;
// How wide the frame border is in front.
frame_width = 10; // .5
// How much picture is covered by frame on each edge
frame_overlap = 1; // 0.1
// How far artwork is recessed from front of frame
frame_inset = 2; // 0.1
// Size of hole behind frame opening (size of artwork unless there's a mat or recess)
content_dimensions = [76.7, 102.1];
// Space between the lip of the frame and the backing piece -- to fit artwork, mat, glass,...
add_depth = .28; // 0.01
// A zig-zag shape along the frame's top edge to hang it from a nail or pin.
Add_sawtooth_hanger = true;

/* [Recessed artwork] */
//Should the back piece contain a recess for the artwork?
Recess_shape = "n"; // [n:No recess,r:Rectangular,o:Oval,c:Custom]
Recess_depth = .29; // 0.01
// if you enter a small ledge value -- e.g. 1 -- the recess will have a hole in the back with a lip around the edge this wide.
Recess_ledge = 1000; // 0.01

Recess_size = [40,60]; // 0.1
Recess_svg_filename = "";

/* [Magnet posts] */
posts_for_magnets = 3; // [4: 4 round magnets, 3:3 round magnets, 0:no magnets, 2:platforms for magnet tape]
// The magnet hole should be a little wider than the magnet.
round_magnet_hole_size = [5.5, 1]; // .1

/* [Advanced] */
wall_thickness = 0.7; //0.1
wedge_height = 0.6;
// How much larger the hole in the frame is than the block it contains.
tolerance = 0.11; //0.01

/* [Hidden] */
$fa = 1;
$fs = 0.4;
SR2 = sqrt(2);

ad = max(0,add_depth);

wt = max(wall_thickness, wedge_height,.3);
tol=tolerance;
tol2=tol+tol;
fo=max(0,frame_overlap);
fi=max(wt,frame_inset);
ms = round_magnet_hole_size;
magnetWallT = 0.5;
magnetPostRadius = ms.x/2 + magnetWallT;

/* frame width needs to be at least big enough to accommodate any round magnets */
fw=max(
	frame_width,
	fo+3*wt,
	posts_for_magnets>2
		?(fo+minMagnetClearance())
		:0
	);

bRecess = Recess_shape != "n";
bPunch = bRecess && Recess_ledge == 0;
bBlockPrintUpright = !bRecess || Recess_ledge <= 2;
rdInner = bPunch ? max(Recess_depth, wt) : Recess_depth;
rdOuter = rdInner + (bPunch ? 0: wt);
rs=[max(Recess_size.x, 1), max(Recess_size.y, 1)];

// calculate containing box for the "content" that adds depth to the assembly -- artwork and whatever.
dContent = [min(content_dimensions), max(content_dimensions), ad];
bRotateRecess = (content_dimensions.x != dContent.x);
dRecess = bRotateRecess
	? [Recess_size.y, Recess_size.x, rdOuter]
	: [Recess_size.x, Recess_size.y, rdOuter];
bHasRecess = bRecess && !bPunch;

/* The depth of the frame must contain:
	- The specified frame_inset
	- The added_depth for artwork
	- A back piece called the "block"
	The minimum thickness of the block is 3mm, more if a recess was specified. There's no max.
	Calculate the block dimensions that will result in a frame of the specified depth, more if needed.
*/
dBlock = [
	dContent.x,
	dContent.y,
	3+wt
//	max(
//		Frame_depth-fi-dContent.z-tol,
//		3,
//		bRecess ? (wt+rd) : 0
//	)
	];
hdBlock = dBlock / 2;
	
// calculate containing box for frame, which must include the block and any recess/punch.
dFrame = [dBlock.x+2*(fw-fo+tol), dBlock.y+2*(fw-fo+tol), max(Frame_depth, max(dBlock.z,bRecess ? rdOuter : 0)+dContent.z+fi+tol)];
hdFrame = dFrame/2;

wedgeWidth = max(10,min(dContent.x/5,dContent.y/5));
groovePoly = [
	[0,-.001],
	[wt,-.001],
	[wt,.1],
	[wt-wedge_height,dBlock.z-.5-wedge_height*.7],
	[wt,dBlock.z-.5],
	[wt,dBlock.z],
	[0,dBlock.z],
	[-wedge_height,dBlock.z-.5-wedge_height*.7],
	[0,.1]
	];
	
grooveWidth = wedgeWidth+1+wt*2;

wedgePoly = [ [ -.001, dBlock.z-.5], [wedge_height, dBlock.z-.5-wedge_height*.7], [-.001, dBlock.z-.5-wedge_height*2]];

function minMagnetClearance() =
	(ms[0] + ms[0]/SR2)/2 + magnetWallT*.25 + 2*wt;
	
/* utility functions from tt libraries */
module textlines(texts, size=4, halign="center", font="", lineheight=1.4) {
    lines = is_list(texts) ? texts : [texts];
    delta_y = ((len(lines)-1)*size*lineheight - size)/2;
    for (i=[0:len(lines)-1]) {
        translate([0,delta_y-i*size*lineheight,0]) text( lines[i], font=font, size=size,halign=halign);
    }
}

module hangy_bit() {
	points = [[-.001,-1.5,dFrame.z],
			  [2,0,dFrame.z],
			  [-.001,1.5,dFrame.z],
			  [-.001,0,dFrame.z-3]];
	faces = [ [0,1,2],[2,3,1],[0,1,3],[0,2,3]];
	union() {
		for (i = [-2:1:2]) {
			translate([0,i*1.2,0])
				polyhedron(points, faces, 1);
		}
	}
}

module magnet_post() {
	or = magnetPostRadius;
	ir = or - magnetWallT;
	topZ = dFrame.z;
	cupZ = topZ - ms[1];
	baseZ = cupZ - .71;
	botZ = max(.001,baseZ - or + 1);
	botX = max(1, or-baseZ+botZ);
	points = [ [0,cupZ], [ir,cupZ], [ir,topZ], [or,topZ], [or,baseZ], [botX,botZ], [1,.001], [0,.001]];
	rotate_extrude(convexity=3)
		polygon(points);
}

module groove_section() {
	translate([0,grooveWidth/2,0])
	rotate([90,0,0])
	linear_extrude(grooveWidth)
	polygon(groovePoly);
}

module wedge_section() {
	translate([0,-wedgeWidth/2,0])
	rotate([90,0,180])
	linear_extrude(wedgeWidth)
	polygon(wedgePoly);
}

module frame() {
	coff2 = fw-fo; // distance from frame edge to inside of inner wall
	coff = coff2-wt; // from frame edge to outside of inner wall
	grooveZ = fi+tol;

	color("yellow")
	union() {
		difference() {
			union() {
				difference() {
					// outside box of frame
					cube(dFrame);
					// hollow out to simple open box
					translate([wt,wt,wt]) cube(dFrame-[2*wt,2*wt,0]);
				}
				
				difference() {
					// inner wall
					translate([coff,coff,0])
						cube([dFrame.x-2*coff, dFrame.y-2*coff, dBlock.z + fi + tol]);
					// minus hole for block and artwork
					translate([coff2,coff2,fi])
						cube(dFrame-[2*coff2, 2*coff2, 0]);
				}
			}
			// minus hole we see artwork through
			translate([fw,fw,-.1]) cube(dFrame-[2*fw,2*fw,-.2]);
			// remove an inner wall section for the groove
			translate([hdFrame.x-wedgeWidth/2-.5, coff-.001, grooveZ])
				cube([wedgeWidth+1, dFrame.y-coff*2+.002,dBlock.z+.1]);
			translate([coff-.001, hdFrame.y-wedgeWidth/2-.5, grooveZ])
				cube([dFrame.x-coff*2+.002,wedgeWidth+1, dBlock.z+.1]);
		}
		// add grooved inner wall sections
		{
		translate([coff,dFrame.y/2,grooveZ])
			groove_section();
		translate([dFrame.x-coff,hdFrame.y,grooveZ])
			rotate([0,0,180])
			groove_section();
		translate([hdFrame.x,coff,grooveZ])
			rotate([0,0,90])
			groove_section();
		translate([hdFrame.x,dFrame.y-coff,grooveZ])
			rotate([0,0,-90])
			groove_section();
		}
		if (posts_for_magnets == 2) {
			locs = [[-1,-1,0],[1,-1,90],[-1,1,-90],[1,1,180]];
			delta = hdFrame-[wt,wt,0];
			
			for (p = locs) {
				translate([hdFrame.x+p.x*delta.x,hdFrame.y+p.y*delta.y,0])
				rotate([0,0,p[2]])
				tape_platform();
			}
		} else if (posts_for_magnets > 2) {
			centerOK = fw-fo-2*wedge_height-2*tol > 2*magnetPostRadius;
			fromEdge = magnetPostRadius+wt-magnetWallT*.75;
			locs = posts_for_magnets == 4
				? [[-1,1],[-1,-1],[1,1],[1,-1]]
				: [[1,-1], [1,1], [-1,centerOK?0:1]];
			offsets = [hdFrame.x-fromEdge, hdFrame.y-fromEdge];
			for (d = locs) {
				translate([hdFrame.x+offsets.x*d.x, hdFrame.y+offsets.y*d.y, 0])
					magnet_post();
			}
		}
		if (Add_sawtooth_hanger) {
			translate([dFrame.x-wt, hdFrame.y, 0])
				rotate([0,0,180])
				hangy_bit();
			translate([hdFrame.x, wt, 0])
				rotate([0,0,90])
				hangy_bit();
		}
	}
}

module recessOutline() {
	if (Recess_shape == "o") {
		scale([1, dRecess.y/dRecess.x, 1]) circle(d=dRecess.x);
	} else if (Recess_shape == "r" || Recess_svg_filename == "") {
		square([dRecess.x, dRecess.y], center=true);
	} else if (bRotateRecess) {
		translate([dRecess.y/2, -dRecess.x/2,0])
			rotate([0,0,90])
			resize([dRecess.x, dRecess.y, 0])
			import(Recess_svg_filename, convexity=10);
	} else {
		translate([-dRecess.x/2, -dRecess.y/2,0])
			resize([dRecess.x, dRecess.y, 0])
			import(Recess_svg_filename, convexity=10);
	}
}

module recess(outer=true) {
	translate([dBlock.x/2, dBlock.y/2, 0])
	if (bRecess) {
		if (outer) {
			linear_extrude(height=dRecess.z,convexity=6)
				offset(r=wt)
				recessOutline();
		} else {
			translate([0, 0, bPunch?-.5:(-1-wt)])
				linear_extrude(height=dRecess.z+1,convexity=6)
				recessOutline();
			if (Recess_ledge > 0 && min(dRecess) > Recess_ledge*2) {
				linear_extrude(height=dRecess.z+wt+1,convexity=6)
					offset(r=-Recess_ledge)
					recessOutline();
			}
		}
	}
}

module tape_platform() {
	e = .001;
	wid = min(13, fw-fo)-wt;
	freeHt = wid*.8;
	ht = min(freeHt, dFrame.z-wt+e);
	points = freeHt == ht
			? [[-e,dFrame.z], [wid, dFrame.z], [-e, dFrame.z-ht]]
			: [[-e,dFrame.z], [wid, dFrame.z], [wid-ht, wt-e], [-e,wt-e]];
	pw = min(dFrame.x,dFrame.y,150)*.3;
	union() {
		rotate([90,0,90])
			linear_extrude(height = pw)
			polygon(points);
		translate([0,pw,0])
			rotate([90,0,0])
			linear_extrude(height = pw)
			polygon(points);
	}
}

module block() {
	difference() {
		union() {
			difference() {
				// begin with open-topped box, sides wt thick.
				cube(dBlock);
				translate([wt,wt,wt])
					cube(dBlock-[2*wt,2*wt,0]);
			}
			// add the outer part that will contain the recess -- we cut the hole out later.
			recess(true);
			// add a wedge on the outside of the box at the middle of each side.
			translate([0,hdBlock.y,0])
			wedge_section();
			translate([dBlock.x,hdBlock.y,0])
				rotate([0,0,180])
				wedge_section();
			translate([hdBlock.x,0,0])
				rotate([0,0,90])
				wedge_section();
			translate([hdBlock.x,dBlock.y,0])
				rotate([0,0,-90])
				wedge_section();
		}
		// cut out the hole from the recess.
		recess(false);
	}
}

/* Create an object representing the artwork that will be inserted in the frame. Only used for assembly diagram mode. */
module artwork() {
	thik = max(.01,dRecess.z-0.5);
	if (bRecess) {
		color("#90ffff", 0.3)
		translate([hdFrame.x,hdFrame.y,thik/2])
		linear_extrude(height=thik, center=true)
		offset(r=2)
		offset(r=-2.5)
		recessOutline();
	}
}

module fill() {
	color("#9090ff", 0.15)
	cube([dBlock.x, dBlock.y, ad], center=true);
}

/* Display the parts as an assembly diagram */
module assembly_diagram() {
    frame();
	dz = dFrame.z + 30;
	if (ad > 0) {
		translate([hdFrame.x, hdFrame.y, dz+ad/2])
			fill();
	}
	dz2 = dz + (ad > 0 ? (30+ad) : 0);
    translate([hdFrame.x-hdBlock.x, hdFrame.y-hdBlock.y, dz2]) block();
//	translate([0,0,dz2]) artwork();
}

/* Display the parts laid out for printing. */
module print_layout() {
    frame();
	trBlock = bBlockPrintUpright ? [dFrame.x + fw, 0, 0] : [dFrame.x + fw + dBlock.x, 0, dBlock.z];
    translate(trBlock)
		rotate([0, bBlockPrintUpright ? 0: 180, 0])  
		block();
}

module cutaway() {
	difference()
	{
	union() {
	frame();
	translate([hdFrame.x-hdBlock.x,hdFrame.y-hdBlock.y, fi+dContent.z+tol]) block();
	}
	cube([40,40,dFrame.z*2+1],center=true);
	}
}

module debug() {
	hangy_bit();
//	tape_platform();
//	cutaway();
//	artwork();
//	wedge_section(); translate([-wt-tol, 0, 0]) groove_section();
//	groove_section();
//	polygon(groovePoly);
//	frame();
}

module main() {
    if (Layout == "d") {
		debug();
    } else if (Layout == "s" && $preview) {
		assembly_diagram();
	} else if (Layout == "b") {
		trBlock = bBlockPrintUpright ? [0, 0, 0] : [dBlock.x, 0, dBlock.z];
		translate(trBlock)
			rotate([0, bBlockPrintUpright ? 0 : 180, 0]) 
			block();
	} else if (Layout == "f") {
		frame();
	} else {
	    print_layout();
    }
}

main();