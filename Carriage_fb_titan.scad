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

// Determined empirically; TODO: Move this to a global and use it
base_height = bearing_diameter/2 + plate_depth - 1.1;
module bltouch_cutout() {
    // cutout
    translate([-14,-7,base_height - plate_depth/2])
    rotate([0,0,15]) {
    translate([0,0,-34/2])
        cylinder(d=13.5, h=34+plate_depth+1, center=true);

        for (y=[-9, 9]) {
            translate([y, 0, 0])
                cylinder(d=3, h=plate_depth*3, center=true);
            translate([y, 0, -plate_depth])
                rotate([0,0,30])
                cylinder(d=5.3, h=plate_depth*2, center=true, $fn=6);
        }
    }
}

module bltouch_mount() {
    width = carriage_length - extruder_offset -  45;

    hull() {
        translate([-14,-7,base_height-plate_depth/2])
        rotate([0,0,15]) {
            color("white")
            hull() {
                for (y=[-9, 9])
                    translate([y, 0, 0])
                        cylinder(r=4, h=plate_depth, center=true);
            }
        }
        translate([-12, -width/2-10, base_height - plate_depth/2])
            cube([base_width-12, width, 0.5], center=true);
        translate([-12, -width/2-10, base_height - plate_depth/2])
            #cube([base_width-12, 2, plate_depth], center=true);
    }
}

module bltouch() {
    // TODO: Add mounting holes for BLTouch z-probe module
    // BLTouch mounting footprint
    height=2.3;
    translate([-14,-7,10.7])
    rotate([0,0,15]) {
    difference() {
        color("white")
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

            color("purple")
            translate([13.5,28.5,0])
                heat_sink_duct();
        }

        color("darkgrey") {
        rotate([0,0,-45]) {
            translate([-28,0,0])
            #cylinder(d=4,h=40,center=true);
            translate([28,0,0])
            #cylinder(d=4,h=40,center=true);
        }
        cylinder(d=46, h=13,center=true);
        translate([13.5,12.6,0])
            cube([17,35,13],center=true);
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
    translate([50, 75, 35])
    rotate([-90,-5,0])
    %cage_fan();

    color("orange")
    translate([-10, -5, 35])
    rotate([-90,5,180])
    %cage_fan();
}

module heat_sink_duct() {
    fan_sleeve();
    heat_sink_duct_2();
}

module heat_sink_duct_2() {
    translate([0,10,0])
        rotate([0,-45,0]){
            ducting_bent();
            translate([-10,12,0])
            rotate([0,0,90])
                duct_fan(35);
        }
}

module duct_2d() {
    difference() {
        circle(d=19+shell*2);
        circle(d=19);
    }
}

module circle_squash(squash, r) {
    hull() {
        translate([r*2*squash,0,0])
            circle(r=r*(1-squash));
        translate([-r*2*squash,0,0])
            circle(r=r*(1-squash));
    }
}

module duct_fan_2d(squash) {
    difference() {
        circle_squash(squash, 19+shell*2);
        circle_squash(squash, 19);
    }
}

module duct_fan_3d(squash, d) {
    rotate([0,90,90])
    linear_extrude(height=1, center=true)
        circle_squash(squash, d/2);
}

module ducting(length) {
    translate([0,length/2,0])
    rotate([0,90,90])
    linear_extrude(height=length, center=true)
        duct_2d();
}

module duct_fan_solid(length, d) {
    hull() {
        duct_fan_3d(0, d);
        translate([0,length-1,0])
            duct_fan_3d(0.5, d);
    }
}

module duct_fan(length) {
    difference() {
        duct_fan_solid(length, 19+shell*2);
        translate([0,-0.005,0])
        duct_fan_solid(length+0.01, 19);
    }
}

module ducting_bent() {
    translate([-12,0,-12])
    intersection() {
        rotate_extrude()
            translate([12,12,0]) duct_2d();
        cube([40,40,40]);
    }
}


module fan_sleeve() {
    translate([0,-15,0])
    difference() {
        union() {
            hull() {
                translate([0,0,0])  cube([24,30,19],center=true);
                translate([0,5,0])
                rotate([0,90,90])
                cylinder(d=19+shell*2, h=40,center=true);
            }
        }
        translate([0,0,0])  cube([17,30,13],center=true);
        translate([0,25,0])
        rotate([0,90,90])
        hull() {
            cylinder(d=19, h=6,center=true);
            cylinder(d=13, h=26,center=true);
        }
        translate([0,0,0])  cube([20.2,30,15.5],center=true);
        #translate([10,8.749,0]) cube([6,12.5,3],center=true);

        translate([10-24,-12,0])
        cylinder(d=48, h=22, center=true);
    }
}

module place_bltouch_cutout(){
    translate([0, carriage_length,0])
        bltouch_cutout();
}

module place_bltouch(){
    translate([0, carriage_length,0]) {
        bltouch_mount();
        %bltouch();
    }
}

//combine clips and carriage
module carriage(){
    difference() {
        union() {
            basecarriage();
            titanmount();

            // place_heatsink_fan();
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

rotate([-45,0,0])
    rotate([0,-90,90])
    heat_sink_duct_2();

// rotate([90,0,0]) {
//     carriage();
//     %e3TitanPlacement();
// }
