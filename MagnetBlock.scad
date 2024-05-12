/*
 Magnet Block Frame
 Copyright 2024 Tyler Tork
 
 This model is a snap-together case for a refrigerator magnet, to contain artwork that's folded around a 3D-printed block to make a block with "painted" sides, then a transparent sleeve that snaps on from the back to cover the edges of the work in a clear layer that lets their color show through.
 
 This model is parameterized using the Customizer to let you specify the dimensions of the artwork. It assumes art that's laid out as a rectangular picture with a flap attached to each side. Select the Layout as "Artwork template" to get the outline to cut out the paper that will fit the block.
 
 It's designed for easy printing. No supports are required. The "shell" part doesn't have a large surface area in contact with the plate, so you may want a brim. The "block" part has a nice big first layer so it should be fine.
 
 I suggest glueing the back of the artwork to the block so it lies flat. It's up to you whether to use glue to secure the two parts together -- it's not easy to separate them once they snap together so I don't bother.
 
 You will of course have to glue the magnets into position, if you choose to add some.

 The shell is intended to be printed in clear ("natural") material that has a bit of flex to it -- regular old PLA is fine.

 The block doesn't need to be clear, but a light color is good if your artwork is thin enough that the color might show through a little.
 
 The Layout option lets you choose to export either the shell or the block for printing -- not both together. Since they don't need to both be transparent and you can use any inexpensive material for the block, it's unlikely you'll want to print them in a single job.

 Licensed under Creative Commons - Attribution - Non-Commercial - Share Alike
    https://creativecommons.org/licenses/by-nc-sa/4.0/
 */

Layout = "d"; // [d: Assembly diagram, b: Block only, s: Shell only, a:Artwork template]
// (mm) leeway allowed for imprecise printing, depending on your printer and material used.
tolerance = .16; // .01

/* [Artwork dimensions] */

// (mm) Size of picture to appear on front of block:
picture_size = [76.7, 102.1];
// (mm) colored margin to fold around the sides:
flap_width = 4; // .1
// .21=cardstock, .29=photo paper
paper_thickness = .29; // .01

/* [Shell dimensions] */
side_thickness = 0.5;
back_thickness = 0.5;

/* [Block dimensions] */
front_thickness = 0.6;
block_side_thickness = 4.0; // 0.1

/* [Magnet settings] */
magnet_option = 3; // [3:3 round magnets,4:4 round magnets,0:none,1:platforms for magnet tape]
// Need not be a tight fit.
magnet_diameter = 5.6; // .1
// Let magnet protrude a little for better contact in case back not perfectly flat.
magnet_depth = 1.2; // .1

/* [Hidden] */
$fa = 1;
$fs = 0.4;
Tol = tolerance;
fw = flap_width;
ft = front_thickness;
fs = side_thickness;
pt = paper_thickness;
fb = back_thickness;
bs = block_side_thickness;
fsi = 1.0;
fe = bs + pt + 2*Tol + fsi + fs;
hmm = magnet_option;
mw = magnet_diameter;
md = magnet_depth;
magnet_offset = bs + 3 + (hmm == 1 ? 0 : mw/2); // distance of center of magnet post from edge of block
dPic = [min(picture_size), max(picture_size)]; // orient small dimension along X axis because the magnet positioning code assumes this is the case.
dBlock = [dPic.x, dPic.y, fw-pt ];
dShell = dBlock + [(fs+pt)*2+Tol, (fs+pt)*2+Tol, Tol+2*pt+fb];
bfw = bs-.5; // width of diagonal-cut flap on artwork
wedge_ht = .5;
wedge_len = [min(30, dBlock.x/4), min(30, dBlock.y/4)];
magnet_post_ht = dShell.z-ft-pt;

// inward-facing protrusion for the clip fastening.
wedge_poly = [[-.001,0],
    [0, 0],
    [wedge_ht, 1.5],
    [0, 2],
    [0, 2.501],
    [-.001,2.501]
 ];

// the shell's inner vertical surface has a beveled edge along the "flat" part and a groove to mate with the block's wedge.
function groove_poly(flat=false) =
    let(top = Tol+pt+dBlock.z-ft)
    flat
    ? [ [0,-.001],
        [0,top-.5],
        [.5,top],
        [fsi,top],
        [fsi,-.001] ]
    : [ [0,-.001],
        [0,top-2.5],
        [wedge_ht,top-1],
        [0,top-.5],
        [.5,top],
        [fsi,top],
        [wedge_ht+fsi,top-1],
        [fsi,top-3],
        [fsi,-.001] ];

/* create a part-cylinder with a specified angle, and optionally a poking-out bit to connect it to an adjacent slab. For making rounded corners to join flat pieces. The result is oriented like a cylinder -- with the center of curvature at the origin.
    
    extend: if >0 add a connecting piece to overlap the cube you want to butt up against the flat faces.
*/
module roundedCorner(h=10,r=2,angle=90,extend=0, center=false) {
    steps=floor(angle/$fa);
    step = max(1,angle/steps);
    endpoint = [r*cos(angle),r*sin(angle)];
    endExtend = (extend > 0? (extend*[cos(angle+90), sin(angle+90)]):[0,0]);
    echo("endpoint", endpoint, "endExtend", endExtend);
    
    points = concat(
        extend>0?([[0,0],[0,-extend],[r,-extend],[r,0]]):[[0,0],[r,0]],
        [for(a=[0:step:angle-.001]) [r*cos(a),r*sin(a)]],
        [endpoint],
        extend>0?([endpoint+endExtend, endExtend, [0,0]]) : [[0,0]]
    );
    
    linear_extrude(height=h, center=center)
    polygon(points);
}

/* support post for cylindrical magnets, designed to be just tall enough to sit on the back surface of the block and come out flush with the back surface of the shell after they snap together (i.e. it's a little taller than the outer walls of the block). */
module magnetSupport() {
    mr = mw / 2;
    ht = magnet_post_ht+.001;
    points = [ [0,md], [mr,md], [mr,0], [mr+.5,0],
                [mr+.5,ht], [0,ht]];
    
    rotate_extrude()
     polygon(points);
}

/* Create a flat shape showing the cut outline for a paper that will wrap exactly around the block. */
module art_template() {
    pX = [
            [-dPic.x/2, 0],
            [bfw-dPic.x/2, bfw],
            [dPic.x/2-bfw, bfw],
            [dPic.x/2, 0]
         ];
    pY = [
            [0,-dPic.y/2],
            [bfw, bfw-dPic.y/2],
            [bfw, dPic.y/2-bfw],
            [0, dPic.y/2]
         ];
         
    color("yellow") square(dPic, center = true);
    for (d = [-1, 1]) {
        color("gold")
            translate([d*(dPic.x+fw)/2,0,0])
            square([flap_width, dPic.y], center=true);

        color("gold")
            translate([0, d*(dPic.y+fw)/2,0])
            square([dPic.x, flap_width], center=true);
        
        color("white")
            translate([0,d*(fw + dPic.y/2),0])
            scale([1,d,1])
            polygon(pX);
        
        color("white")
            translate([d*(fw + dPic.x/2),0])
            scale([d,1,1])
            polygon(pY);
    }
}

/* The part of inner upright of the shell that includes one corner and two adjacent "flat" sections, up to where they touch the "grooved" section in the middle of the side. */
module shellInnerCorner(x,y) {
    m=.001;
    // create a corner cube beveled on two sides
    ptFlat = groove_poly(true);
    rotate([90,0,0])
    intersection()
    {
        translate([-fsi,0,0]) linear_extrude(fsi) polygon(ptFlat);
            translate([-fsi,0,fsi]) rotate([0,90,0]) linear_extrude(fsi) polygon(ptFlat);
    }
    // attach a wall to the corner that's beveled on one edge.
    translate([-m,-fsi,0])
        rotate([90,0,90])
        linear_extrude(x+m)
        polygon(ptFlat);
    translate([-fsi,y,0])
        rotate([90,0,0])
        linear_extrude(y+m)
        polygon(ptFlat);            
}

/* shell is the transparent outer shell.
   Render oriented for printing, with one corner at the origin. */
module shell() {
    dInner = dShell-[2*fe, 2*fe, 0];
    color("#ccccff", .5)
    union() {
        difference() {
            // the outer box
            cube(dShell);
            // carve out the inside to make a box
            translate([fs,fs,fb])
                cube(dShell-[2*fs,2*fs,0]);
            // cut a hole in the bottom of the box
            translate([fe,fe,-.1])
                cube(dInner);
        }
        // build walls on the inside of the shell to make a U-shaped cross section.
        p = wedge_len+[1,1];
        e = [(dInner.x-p.x)/2, (dInner.y-p.y)/2];
        t = e + [bs,bs];
        // cross section of grooved wall to snap to the wedge on the block part.
        ptFlat = groove_poly(true);
        // cross section of flat beveled wall.
        ptGroove = groove_poly(false);
        center = [dShell.x/2, dShell.y/2];
        xoff = dInner.x/2;
        yoff = dInner.y/2;
        // place a right-angled bit of wall at each inside corner
        for(dx = [-1,1], dy=[-1,1]) {
            translate([center.x-dx*xoff, center.y-dy*yoff, fb])
            scale([dx, dy, 1])
            shellInnerCorner(e.x,e.y);
        }
        // fill in the gaps in the middle of each wall with a grooved section.
        for(par=[[p.y,-1,0],[p.y,1,0],[p.x,0,-1],[p.x,0,1]]) {
            angle = 90*(1+par[1]+par[2]+abs(par[2]));
            translate([center.x+par[1]*(fsi+xoff),center.y+par[2]*(fsi+yoff),fb])
                rotate([90,0,angle])
                linear_extrude(par[0]+.002, center=true)
                polygon(ptGroove);
        }
    }
}

/* block:
    create the part the picture is folded around.
    This is generated with a corner at the origin and laid flat on the XY plane, in printing orientation (front facing down).
*/
module block() {
    // basic shape of block is hollow box.
    color("#ffdddd")
    translate(dBlock/2)
    union() {
        difference() {
            cube(dBlock, center=true);
            translate([0,0,ft])
            cube(dBlock-[bs*2,bs*2,0], center=true);
        }
        
        if (hmm == 1) {
            // customizer selected flat areas for magnetic tape.
            translate([0,dBlock.y/2-magnet_offset-6.5,0])
                cube([dBlock.x-magnet_offset*2, 13, dBlock.z], center=true);
            translate([0,-(dBlock.y/2-magnet_offset-6.5),0])
                cube([dBlock.x-magnet_offset*2, 13, dBlock.z], center=true);
        } else if (hmm != 0) {
            // magnet support posts were selected.
            off = [dBlock.x/2-magnet_offset,dBlock.y/2-magnet_offset,ft-dBlock.z/2+magnet_post_ht];
            // 3 or 4 posts
            locs = hmm == 3
                ? [[-1,-1],[1,-1],[0,1]]
                : [[-1,-1],[-1,1],[1,-1],[1,1]];
            for(p = locs) {
                translate([off.x*p.x,off.y*p.y,off.z])
                rotate([0,180,0])
                magnetSupport();
            }
        }
        
        // wedges in the middle of each inner side.
        pads = [[1,0],[0,1],[-1,0],[0,-1]];
        for (i=[0:3]) {
            oy = i%2;
            ox = floor(i/2);
            translate([(dBlock.x/2-bs)*pads[i].x, (dBlock.y/2-bs)*pads[i].y,2.5+ft-dBlock.z/2])
            rotate([90,180,i*90]) linear_extrude(wedge_len[1-oy],center=true) polygon(wedge_poly);
        }
        echo("wedge_len", wedge_len);
    }
}

/* unused, incomplete. */
module foldedPicture() {
    color("gold")
    translate([paper_thickness,paper_thickness,flap_width])
     cube([dPic.x, dPic.y, paper_thickness]);
     
    translate([pt,pt,flap_width])
    rotate([-90,-90,-90])
    roundedCorner(h=dPic.x,r=pt,extend=.001);

    translate([pt,pt,flap_width])
    rotate([-90,180,0])
    roundedCorner(h=dPic.y,r=pt,extend=.001);

    translate([pt+dPic.x,pt+dPic.y,flap_width])
    rotate([0,-90,0])
    roundedCorner(h=dPic.x,r=pt,extend=.001);

    translate([pt+dPic.x,pt,flap_width])
    rotate([-90,-90,0])
    roundedCorner(h=dPic.y,r=pt,extend=.001);
    color("yellow") {
        translate([0,pt,0])
        cube([pt,dPic.y,flap_width]);
        
        translate([pt,0,0])
        cube([dPic.x,pt,flap_width]);

        translate([dPic.x+pt,pt,0])
        cube([pt,dPic.y,flap_width]);
        
        translate([pt,dPic.y+pt,0])
        cube([dPic.x,pt,flap_width]);
    }
    
    if (false) {
    difference() {
        cube([dPic.x+2*paper_thickness, dPic.y+2*paper_thickness, flap_width+paper_thickness]);
        translate([paper_thickness,paper_thickness,-.001])
        cube([dPic.x, dPic.y, flap_width+paper_thickness+.002]);
    }
    if (back_flap_width > 0) {
        translate([dPic.x/2+paper_thickness,dPic.y/2+paper_thickness,0])
        color("white") {
            for (d = [-1, 1]) {
                translate([d*(dPic.x-back_flap_width)/2,0,paper_thickness/2])
                cube([back_flap_width, dPic.y-2*flap_corner_cut-2, paper_thickness], center=true);
            
                translate([0, d*(dPic.y-back_flap_width)/2,paper_thickness/2])
                cube([dPic.x-2*flap_corner_cut-2, back_flap_width, paper_thickness], center=true);
    }    }
        
    }
    }
}

/* Show both parts positioned as they would be when the frame is assembled, with cutouts to view cross section. */
module assemblyDiagram() {
    sleeveOffset = (dShell.x-dBlock.x)/2;
    
    difference() {
        translate([sleeveOffset+dBlock.x, sleeveOffset, dShell.z-pt]) rotate([0,180,0]) block();
        // cross-section chunks to cut out of the block
        translate([dShell.x, 0, 0]) cube([30,magnet_offset*2+fs,20], center=true);
        translate([dShell.x*.75+1, dShell.y/2, -.1]) cube([dShell.x/4, wedge_len.y/2-3, dShell.z+1]);
    }
    
    difference() {
        shell();
        // cross-section chunks to cut out of the shell
        translate([dShell.x, 0, 0]) cube([30,magnet_offset*2+fs,20], center=true);
        translate([dShell.x*.75+1, dShell.y/2, -.1]) cube([dShell.x/4, wedge_len.y/2-2, dShell.z+1]);
    }

    % rotate([90, 0, 0]) translate([0,-7,0]) linear_extrude(.01) text("Pieces are removed to display cross-sections.", size=4);
}

/* Lay out all parts in printing orientation. Normally you won't want to do this because they are generally in different materials. */
module printLayout() {
    shell();
   translate([dShell.x + 8, 0, 0])
        block();
}

module debug() {
    // make a call to whatever module you're debugging.
}

module main() {
    if (Layout == "d")
        if ($preview) assemblyDiagram();
		else printLayout();
    else if (Layout == "a")
        art_template();
    else if (Layout == "x") // not currently selectable.
        debug();
    else if (Layout == "b")
        block();
    else if (Layout == "s")
        shell();
    else // not currently selectable
        printLayout();
}

main();
