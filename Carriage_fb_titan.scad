$fn=64;


/** Ideas/Bugs:
holey plate can have two columns of holes if it gets wider than height/2-ish
Bottom fan mount can be moved on top of the bltouch mount
Top fan mount is extended into space.  Top plate needs to be lengthened to hold it.
BLTouch mount can be moved around a bit more, but my scalar defines are not up to snuff yet.
Beltclips scalars are duplicated in beltclips.scad. Should be passed as parameters instead.
**/

use <ducting.scad>;
use <beltclips.scad>;

// Extruder mount
extruder_offset = 4;    // Must be at least plate_depth, or else vertical wall must be removed
plate_depth = 3;
base_width = 28;
hotend_displacement = 4;    // Horizontal offset from center of carriage

//Carriage dimensions
bearing_length=45;
bearing_diameter=15.2;
rod_spacing=43.25;
carriage_length=bearing_length+13 + extruder_offset;
shell = 1.5; // thickness of bearing shell

// Belt clips
belt_gap=1.5;
belt_post=4.5;
belt_height=8.5;

lower_belt_z = 1.5;
upper_belt_z = bearing_diameter - 2;

// BLTouch
bltouch_angle=45;
bltouch_swing=15;
bltouch_z_offset=3.5;
bltouch_offset=12;

module bearing_cutout() {
    delta = carriage_length - bearing_length - 1;
    #translate([0,0,-carriage_length]) cylinder(d=9, h=carriage_length*3);
    translate([0,0,-1]) cylinder(d=bearing_diameter-0.6, h=carriage_length+2);
    translate([0,0,delta/2]) cylinder(d=bearing_diameter, h=bearing_length+1);
    translate([0,0,bearing_length+delta/2+2]) cylinder(d=bearing_diameter, h=delta/2);
    translate([0,0,-1]) cylinder(d=bearing_diameter, h=delta/2);
    //translate([0,0,carriage_length - delta/2+1]) cylinder(d=bearing_diameter, h=delta/2+1);

}

// pathways we want completely cleared (might be called multiple times)
module cutouts() {
    // cut bearing holes
    rotate([-90,0,0]) {
        translate([rod_spacing,0,0])
        mirror([1,0,0])
            bearing_cutout();
        bearing_cutout();
    }

    // Trim negative-y
    translate([-carriage_length, -0.01, -10])
    mirror([0,1,0])
    cube([carriage_length*2, carriage_length*2, carriage_length*2]);

    // Cut gaps/slits in bearing pushfit tubes
    gap = 8; // Cylinder opening width
    rotate([-90,0,0]) {
    translate([-4,4,-1])
        translate([0,-2,0])
            cube([gap,10,carriage_length+2]);

        translate([rod_spacing,0,0])
        mirror([1,0,0])
        translate([-4,4,-1])
            translate([0,-2,0])
                cube([gap,10,carriage_length+2]);
    }

    // cut hotend hole
    spacing = rod_spacing-bearing_diameter-shell*2 - 1;
    translate([hotend_displacement, 0, 0])
    translate([19.5,47/2,32])
    rotate([0,-90,0])
    translate([0, -5/2, 0]) {
        hull() {
            rotate([90,0,90]) {
                // Hotend heat sink
                translate([11.1+2+extruder_offset, -1.5, -30])
                    cylinder( d=spacing, h=30, center=true);
                // Make room for air flow
                translate([5, spacing/2-14.25, -30])
                    cylinder( d=spacing, h=30, center=true);
            }
        }
    }

    // Cut gap around belt clips
    clip_cutouts();

    place_bltouch_cutout();
}

//left bearing tube
module bearing(){
    cylinder(d=bearing_diameter + shell*2, h=carriage_length);
}

//right bearing tube
module bearingtube(){
    bearing();
    translate([rod_spacing,0,0])
    mirror([1,0,0])
    	bearing();
}

//main carriage
module basecarriage(){
    rotate([-90,0,0])
        bearingtube();

    translate([0,0,6.5-bearing_diameter])
        cube([rod_spacing,carriage_length,bearing_diameter+shell*2]);
}

module clips() {
    // Top left
    translate([bearing_diameter/2+hotend_displacement/2,-shell/2,bearing_diameter/2-belt_height+upper_belt_z])
    beltclip2(shell);

    // Bottom left
    translate([rod_spacing-bearing_diameter/2,-shell/2,-bearing_diameter/2-shell+lower_belt_z])
    mirror([0,0,1])
    mirror([1,0,0])
    beltclip(shell);


    // Bottom right
    translate([bearing_diameter/2,carriage_length+shell/2,-bearing_diameter/2-shell/2+lower_belt_z])
    mirror([0,1,0])
    mirror([0,0,1])
    beltclip(shell);

    // Top right
    translate([rod_spacing-bearing_diameter/2,carriage_length+shell/2,bearing_diameter/2-belt_height+upper_belt_z])
    mirror([0,1,0])
    mirror([1,0,0])
    beltclip2(shell);
}

module clip_cutouts() {
    // Top left
    translate([bearing_diameter/2+hotend_displacement/2,-shell/2,bearing_diameter/2-belt_height+upper_belt_z])
    beltclip_cutout(shell);

    // Bottom left
    translate([rod_spacing-bearing_diameter/2,0,-bearing_diameter/2-shell])
    for (z=[0,-5])
    translate([0,0,z])
    mirror([0,0,1])
    mirror([1,0,0])
    beltclip_cutout(shell);

    // Bottom right
    translate([bearing_diameter/2,carriage_length+shell/2,-bearing_diameter/2-shell/2+lower_belt_z])
    for (z=[0,-5])
    translate([0,0,z])
    mirror([0,1,0])
    mirror([0,0,1])
    beltclip_cutout(shell);

    // Top right
    #translate([rod_spacing-bearing_diameter/2,carriage_length+shell/2,bearing_diameter/2-belt_height+upper_belt_z])
    mirror([0,1,0])
    mirror([1,0,0])
    beltclip_cutout(shell);
}

module four_screw_holes(offset, d, height) {
    for (i = [-1,1])
        for (j = [-1,1])
            translate([i*offset/2, j*offset/2, 0])
                cylinder(d=d, h=height, center=true);
}

module m3_nut(height) {
    cylinder(d=5.3, h=height, center=true, $fn=6);
}

// Determined empirically; TODO: Move this to a global and use it
base_height = bearing_diameter/2 + plate_depth - 1.1;
module bltouch_cutout() {
    gap = 2.5;
    // cutout
    translate([hotend_displacement, 0, 0])
    translate([-14-bltouch_swing,bltouch_offset,base_height - plate_depth - gap/2 - bltouch_z_offset])
    rotate([0,0,bltouch_angle]) {
        bltouch_head(gap, 5, 0.5);

        translate([0,0,-34/2])
        // hull()
        {
            cylinder(d=13.5, h=34+plate_depth/2, center=true);
            translate([0,5,0])
                cube([12, 5, 34+plate_depth/2], center=true);

        }
        cylinder(d=3, h=plate_depth*5, center=true);

        translate([0,0,-34/2-plate_depth-gap-.1])
            cylinder(d=17, h=34, center=true);

        for (y=[-9, 9]) {
            translate([y, 0, plate_depth/2])
                cylinder(d=3, h=plate_depth*5, center=true);
            translate([y, 0, plate_depth-0.1])
                rotate([0,0,30])
                m3_nut(plate_depth);
        }
    }
}

// The shape of the bltouch head
module bltouch_head(height, r=4, extra=0) {
    hull() {
        cube([6+extra, 11.53+extra, height], center=true);
        for (y=[-9, 9])
            translate([y, 0, 0])
                cylinder(r=r+extra, h=height+extra, center=true);
    }
}

module bltouch_mount() {
    gap = 2.5;
    height = plate_depth * 2 + gap;
    interface = 5;

    translate([hotend_displacement, 0, 0])
    hull() {
        translate([-14-bltouch_swing,bltouch_offset,base_height-height/2+0.1 - bltouch_z_offset])
        rotate([0,0,bltouch_angle]) {
            bltouch_head(height, 5);
        }

        translate([-base_width+10+interface, interface/2, base_height - plate_depth/2 - bltouch_z_offset])
            cube([interface+1, interface, plate_depth + bltouch_z_offset], center=true);
        translate([-base_width+10+interface, -interface/2, base_height - plate_depth/2 - bltouch_z_offset])
            cube([interface+1, interface, plate_depth + bltouch_z_offset], center=true);
    }
}

module bltouch() {
    // TODO: Add mounting holes for BLTouch z-probe module
    // BLTouch mounting footprint
    height=2.3;
    translate([hotend_displacement, 0, 0])
    translate([-14-bltouch_swing,bltouch_offset,9.5 - plate_depth - height/2 - bltouch_z_offset])
    rotate([0,0,bltouch_angle]) {
    difference() {
        color("white")
            bltouch_head(height);

        for (y=[-9, 9])
            translate([y, 0, 0])
                cylinder(d=3, h=height*10, center=true);
    }

    color("silver")
    translate([0,0,-height/2-34/2])
        cylinder(d=13, h=34, center=true);
    color("white")
    translate([0,0,-height/2-34-4.4])
        cylinder(d=1, h=8.8, center=true);
    }
}

module titan_motor() {
    depth=23;
    shaft=22;
    translate([0,0,depth/2])
    difference() {
        union() {
            color("black")
            cube([43, 43, depth], center=true);

            // motor shaft
            translate([0, 0, -depth/2-shaft/2])
                rotate([0,0,90])
                color("grey")
                    cylinder( d=5, h=shaft, center=true);
        }

        for (i = [45,135,-135,-45])
            rotate([0,0,i])
                translate([1.4*43/2,0,0])
                color("black")
                cube([4,10,depth+0.1], center=true);

        four_screw_holes(31, 3.5, depth+1);
    }
}

module e3dtitan(){
    depth=25;
    difference() {
        union() {
            color("silver")
            cube([44, 47, depth], center=true);

            // extrude wheel
            translate([29/2, 26/2, 6])
                color("black") cylinder(d=34, h=2, center=true);

            // Position relative to motor shaft
            translate([0, -5/2, 0]) {
                // Filament path
                translate([29/2, 11.1, -1.5])
                    rotate([90,0,90])
                    color("blue")
                        cylinder( d=3, h=190, center=true);

                translate([-72.5,-5,10])
                %rotate([180,0,90])
                import("e3dv6.stl");
            }
        }

        translate([-2/2, -5/2, 0]) union() {
            // Motor flange hole
            cylinder(d=23, h=depth*2+0.2, center=true);
            // screw-holes
            four_screw_holes(31, 4.5, depth+1);
            }

        translate([-2/2, -5/2, 0])
        rotate([0,0,-135])
            translate([1.4*42/2,0,0])
            color("silver")
            cube([4,10,depth+0.1], center=true);
    }
}

module holey_plate(x,y) {
    r = min(y * 0.2, x * 0.1);
    difference() {
        cube([x, y, plate_depth], center=true);
        for (d=[-1:1]) {
            side=(d==0) ? -1 : 1;
            translate([d*r*3,0,0])
            hull() {
                translate([-r*.5,side*2,0])
                    cylinder(r=r, h=plate_depth+0.1, center=true);
                translate([r*1.2,r*side+2*side-r/10*side,0])
                    cylinder(r=r/10, h=plate_depth+0.1, center=true);
            }
        }
    }
}

module titanmount(){
    translate([hotend_displacement, 0, 0])
    rotate([-90,0,0])
    difference() {
        translate([21.6-13.5,-43.2/2-6.5-shell,21.5])
        rotate([-90,0,-90])
        {
            translate([plate_depth/2, -extruder_offset, -plate_depth/2]) {
                difference() {
                    translate([0, extruder_offset/2, 0])
                    union() {
                        // Vertical plate (separator)
                        translate([0,0,-plate_depth/2])
                            cube([43+plate_depth*2, 43+extruder_offset, plate_depth], center=true);
                        // Bottom plate
                        translate([-43/2-plate_depth/2, 0, 0.1-base_width/2-plate_depth])
                            rotate([90,0,-90])
                            holey_plate(43+extruder_offset, base_width+0.1);
                            // cube([plate_depth, 43+extruder_offset, base_width+plate_depth], center=true);
                        // Top plate
                        translate([43/2+plate_depth/2, 0, 0.1-base_width/2-plate_depth])
                            rotate([90,0,-90])
                            holey_plate(43+extruder_offset, base_width+0.1);
                            // cube([plate_depth, 43+extruder_offset, base_width+plate_depth], center=true);
                    }

                    // Motor flange hole
                    cylinder(d=23, h=plate_depth*2+0.2, center=true);

                    // screw-holes
                    translate([0, 0, -plate_depth/2])
                        four_screw_holes(31, 4.5, plate_depth+0.2);
                }
            }
            if ( extruder_offset >= plate_depth )
                // Vertical stabilizer
                translate([plate_depth/2, 43/2-plate_depth/2, 0.1-base_width/2-1.5*plate_depth])
                    rotate([90,0,0])
                    holey_plate(43+0.2, base_width+0.1);
                    // cube([43+0.2, plate_depth, base_width+0.2], center=true);
        }
    }
}

module cage_fan(){
    difference() {
        union() {
            // 50mm squirrel cage fan
            color("darkgrey") {
            cylinder(d=48, h=15,center=true);
            rotate([0,0,-45])
            hull() {
                translate([-28,0,0])
                cylinder(d=7,h=15,center=true);
                translate([28,0,0])
                cylinder(d=7,h=15,center=true);
            }
            translate([13.5,12.5,0])
            cube([20,30,15],center=true);
            }
        }

        color("darkgrey") {
        rotate([0,0,-45]) {
            translate([-28,0,0])
            cylinder(d=4,h=40,center=true);
            translate([28,0,0])
            cylinder(d=4,h=40,center=true);
        }
        cylinder(d=46, h=13,center=true);
        translate([13.5,12.6,0])
            cube([17,35,13],center=true);
        }
    }
}

module place_heatsink_fan(){
    translate([hotend_displacement, 0, 0])
    translate([8.6-base_width-plate_depth, extruder_offset-7.8,0]) {
        translate([0.1, 43+plate_depth-0.3, bearing_diameter/2-plate_depth-2+0.1])
        mirror([1,0,0])
        rotate([-90,-90,90])
        mirror([0,1,0])
            raised_screw_hole();

        translate([0, 12.5+32.7, 43+10+2*plate_depth])
        rotate([-90,90,-90])
        mirror([0,1,0])
            raised_screw_hole();
    }
    translate([hotend_displacement, 0, 0])
    translate([-base_width-6, 17.5+extruder_offset, 36+plate_depth])
    rotate([-90,0,90])
    {
        cage_fan();
    }
}

module place_cooling_fan(){
    color("blue")
    translate([50, 75, 35])
    rotate([-90,-5,0])
    %cage_fan();

    color("orange")
    translate([-10, -5, 35])
    rotate([-90,5,180])
    %cage_fan();
}

module place_bltouch_cutout(){
    translate([0, 0,0])
        bltouch_cutout();
}

module place_bltouch(){
    translate([0, 0,0]) {
        bltouch_mount();
        %bltouch();
    }
}

module place_bltouch_mount(){
    translate([0, 0,0]) {
        bltouch_mount();
    }
}

module place_heatsink_duct() {
    translate([hotend_displacement, 0, 0])
    translate([-base_width-6, 28, 36+plate_depth])
    rotate([-90,0,90])
    color("purple")
    translate([extruder_offset + 3.5, 28.5, 0])
        heat_sink_duct(shell);
}

//combine clips and carriage
module carriage(){
    difference() {
        union() {
            basecarriage();
            titanmount();

            place_heatsink_fan();
            // place_cooling_fan();
            place_heatsink_duct();
            place_bltouch();
            place_bltouch_mount();
        }
        cutouts();
    }
    clips();
    // place_heatsink_duct();
}

// Place a mountpoint against a flat surface
module raised_screw_hole(d=7.82) {
    depth=4;
    width=18;
    difference() {
        hull() {
            cylinder(d=d, h=depth, center=true);
            translate([d/2,d/2,0])
                cube([0.1, width, depth], center=true);
        }
        translate([7.82-d,0,0]) {
            translate([0,0,depth-2])
            rotate([0,0,30])
                m3_nut(3);
            cylinder(d=3, h=depth+0.2, center=true);
        }
    }
}

//Place e3d-titan for alignment comparison
module e3TitanPlacement(){
    translate([19 + hotend_displacement,47/2 + extruder_offset, 32])
    rotate([0,-90,0])
        e3dtitan();

    translate([6.5-plate_depth + hotend_displacement,43/2 + extruder_offset,31])
    rotate([0,-90,0])
        titan_motor();
}

// rotate([-45,0,0])
//     rotate([0,-90,90])
//         heat_sink_duct();

rotate([90,0,0]) {
    carriage();
    %e3TitanPlacement();
}
