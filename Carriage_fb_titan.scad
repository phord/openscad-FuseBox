$fn=64;

// Extruder mount
extruder_offset = 10;
plate_depth = 3;
base_width = 25;

//Carriage dimensions
bearing_length=45;
bearing_diameter=15.2;
rod_spacing=43.25;
carriage_length=bearing_length+13 + extruder_offset;
shell = 1.5; // thickness of bearing shell


//belt clip module
module beltclip_(x1,x2){
    difference(){

        translate([-1.85,0,0])
            cube([12,11,8.5]);

        translate([2.2,-1,1])
            cube([1.1,12,11]);

        translate([5.25,-1,1])
            cube([1.1,12,11]);

        translate([-5,11,0])
        rotate([20.6,0,0])
            cube([16,5,9]);
    }
    for (y=[1,3,5,7]) {
        translate([x1,y+.5,0])
            cylinder(d=1, h=8.5);
        translate([x2,y+.5,0])
            cylinder(d=1, h=8.5);
    }
}

module beltclip(){
    beltclip_(3.4, 5.1);
}

//belt clip module
module beltclip2(){
    beltclip_(2.1, 6.5);
}

module bearing_cutout() {
    delta = carriage_length - bearing_length - 1;
    translate([0,0,-1]) cylinder(d=bearing_diameter-1, h=carriage_length+2);
    translate([0,0,delta/2]) cylinder(d=bearing_diameter, h=bearing_length+1);
    translate([0,0,-1]) cylinder(d=bearing_diameter, h=delta/2);
    translate([0,0,carriage_length - delta/2+1]) cylinder(d=bearing_diameter, h=delta/2+1);

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
    spacing = rod_spacing-bearing_diameter-shell*2;
    translate([19.5,47/2,32])
    rotate([0,-90,0])
    translate([0, -5/2, 0]) {
        hull() {
            rotate([90,0,90]) {
                // Hotend heat sink
                translate([11.1+2+extruder_offset, -1.5, -30])
                    cylinder( d=spacing, h=30, center=true);
                // Make room for air flow
                translate([3, spacing/2-14.25, -30])
                    cylinder( d=spacing, h=30, center=true);
            }
        }
    }

    // Cut gap around belt clips
    clip_cutouts();
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

//top belt clips
module topclip(){
    translate([9.5,0,1])
        beltclip2();

    translate([33.8,carriage_length,1])
    rotate([0,0,180])
        beltclip();
}

//lower belt clip
module clips() {
    topclip();
    translate([43.35,0,0])
        rotate([180,0,180])
        topclip();
}

module clip_cutout() {
    translate([4.25,3.75,6])
    hull(){
        cube([4.2,8,9], center=true);
        translate([0,5.25,0])
        cylinder(d=4.2, h=9, center=true);
    }
 }

module topclip_cutouts() {
    translate([9.5,0,1])
        clip_cutout();

    translate([33.8,carriage_length,1])
    rotate([0,0,180])
        clip_cutout();
}

module clip_cutouts() {
    topclip_cutouts();
    translate([43.35,0,0])
        rotate([180,0,180])
        topclip_cutouts();
}

module four_screw_holes(offset, d, height) {
    for (i = [-1,1])
        for (j = [-1,1])
            translate([i*offset/2, j*offset/2, 0])
                cylinder(d=d, h=height, center=true);
}

module heatsink_fan() {
    // TODO: Add mounting holes for fan to blow on e3d
    // 30mm box fan placeholder
    translate([0,0,-3])
    difference(){
        cube([30,30,6], center=true);
        cylinder(d=29,h=11, center=true);
        #four_screw_holes(24, 3, 22);
    }
}

module cooling_fan() {
    // TODO: Add mounting holes for fan to blow on printed part
    // 40mm box fan placeholder
    difference(){
        cube([40,40,10], center=true);
        cylinder(d=39,h=11, center=true);
        #four_screw_holes(32, 4.5, 30);
    }
}

module bltouch_mount() {
    // TODO: Add mounting holes for BLTouch z-probe module
    // BLTouch mounting footprint
    height=2.3;
    difference() {
        hull() {
            cube([6, 11.53, height], center=true);
            for (y=[-9, 9])
                translate([y, 0, 0])
                    cylinder(r=4, h=height, center=true);
        }

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


module titanmount(){
    base_width = 25;

    rotate([-90,0,0])
    difference() {
        translate([21.6-13.5,-43.2/2-6.5-shell,21.5])
        rotate([-90,0,-90])
        {
            translate([plate_depth/2, -extruder_offset, -plate_depth/2])
            difference() {
                union() {
                    // Vertical plate
                    translate([0,0,-plate_depth/2])
                        cube([43, 43, plate_depth], center=true);
                    // Vertical shell strength
                    translate([-43/2 - 10/2,0,-plate_depth/2])
                        cube([10, 43, plate_depth], center=true);
                    // Bottom plate
                    translate([-43/2-plate_depth/2, 0, -base_width/2])
                        cube([plate_depth, 43, base_width], center=true);
                    // Top plate
                    translate([43/2+plate_depth/2, 0, -base_width/2])
                        cube([plate_depth, 43, base_width], center=true);
                }

                // Motor flange hole
                cylinder(d=23, h=plate_depth*2+0.2, center=true);

                // screw-holes
                translate([0, 0, -plate_depth/2])
                    four_screw_holes(31, 4.5, plate_depth+0.2);
            }
        }
    }
}

module cage_fan(){
    difference() {
        color("darkgrey") {
            cylinder(d=50, h=15,center=true);
            rotate([0,0,-45])
            hull() {
                translate([-29,0,0])
                cylinder(d=7,h=15,center=true);
                translate([29,0,0])
                cylinder(d=7,h=15,center=true);
            }
            translate([15.8,12.5,0])
            cube([17.6,35,15],center=true);
        }

        color("darkgrey") {
        rotate([0,0,-45]) {
            translate([-29,0,0])
            #cylinder(d=4,h=40,center=true);
            translate([29,0,0])
            #cylinder(d=4,h=40,center=true);
        }
        cylinder(d=48, h=13,center=true);
        translate([15.8,12.6,0])
        cube([15.6,35,13],center=true);
        }
    }
}

module place_heatsink_fan(){
    translate([60, 29, 15])
    rotate([-90,15,-90])
    %cage_fan();
}

module place_cooling_fan(){
    color("blue")
    translate([0, 65, 35])
    rotate([-90,-5,180])
    %cage_fan();

    color("orange")
    translate([0, -10, 35])
    rotate([-90,-5,180])
    %cage_fan();
}

module place_bltouch(){
    translate([-13, carriage_length-6, 10.5])
    rotate([0,0,45])
    %bltouch_mount();
}

//combine clips and carriage
module carriage(){
    difference() {
        union() {
            basecarriage();
            titanmount();

            place_heatsink_fan();
            place_cooling_fan();
            place_bltouch();
        }
        cutouts();
    }
    clips();
}

//Place e3d-titan for alignment comparison
module e3TitanPlacement(){
    translate([19,47/2 + extruder_offset, 32])
    rotate([0,-90,0])
        e3dtitan();

    translate([6.5-plate_depth,43/2 + extruder_offset,31])
    rotate([0,-90,0])
        titan_motor();
}

rotate([90,0,0]) {
    carriage();
    %e3TitanPlacement();
}
//beltclip2();