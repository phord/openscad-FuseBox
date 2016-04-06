length = 148;
width = 15;
height = 17;

nut_flange_width=3.5;
nut_diameter=10.8;
nut_flange_diameter=22;

nut_mount_holes=4;
nut_mount_diameter=16;
nut_mount_hole_diameter=3.2;

m3_nut_diameter = 6 ;
m3_nut_depth = 3 ;
nut_window_width = m3_nut_diameter+1.5;
nut_window_height = m3_nut_depth;

$fn = 30;
//translate([400,450,-60]) import("/home/hordp/Downloads/fusebox/files/1-ZNutMount.stl");

module flanged_nut() {
    cylinder(r=nut_diameter/2, h=height+1, center=true);
    translate([0,0,height/2-nut_flange_width]) cylinder(h=nut_flange_width+0.1, r=nut_flange_diameter/2+1);

    //round nut flange mount holes
    for ( i = [0 : nut_mount_holes] ) {
        rotate([0,0,i*360/nut_mount_holes]) {
            // Bolt path
            translate([nut_mount_diameter/2,0,0]) cylinder(h=height+0.1, r=nut_mount_hole_diameter/2,center=true);
            // Captured nut recess
            #translate([nut_mount_diameter/2,0,nut_window_height/2-0.1])
                rotate([0,0,30]) // rotate flat edge toward center
                    cylinder(r=m3_nut_diameter/2,height=m3_nut_depth,$fn=6);
            // Captured nut access
            translate([nut_mount_diameter/2,0,0])
                cube([nut_mount_diameter,nut_window_width,nut_window_height],center=true);
        }
    }
}

difference() {
    union() {
        cube([length, width, height], center=true);
        cylinder(r=nut_flange_diameter/2+2, h=height,center=true);
    }
    translate([length/2, 0, 0]) rotate([0, 90, 0]) cylinder(r=1.6, h=10, center=true);
    translate([-length/2, 0, 0]) rotate([0, 90, 0]) cylinder(r=1.6, h=10, center=true);
    translate([length/4+nut_flange_diameter/2-5, 0, 0])    cube([length/2-nut_flange_diameter/2-7, height/2, height+1], center=true);
    translate([-(length/4+nut_flange_diameter/2-5), 0, 0]) cube([length/2-nut_flange_diameter/2-7, height/2, height+1], center=true);
    // dreieck schmarn
    for ( i = [0 : 4] ) {
        if( i % 2 == 0 ) {
            translate([-65+i*10, 0, -2]) rotate([90, 30, 0]) cylinder(r=8, h=25, $fn=3, center=true);
            translate([65-i*10, 0, -2]) rotate([90, 30, 0]) cylinder(r=8, h=25, $fn=3, center=true);

        } else {
            translate([-65+i*10, 0, 2]) rotate([90, 210, 0]) cylinder(r=8, h=25, $fn=3, center=true);
            translate([65-i*10, 0, 2]) rotate([90, 210, 0]) cylinder(r=8, h=25, $fn=3, center=true);
        }
    }
    flanged_nut();
}

// verbindungen oben
for ( i = [0 : 2] ) {
    translate([65-i*20, 0, height/2-2.5/2]) cube([5, width, 2.5], center=true);
    translate([-65+i*20, 0, height/2-2.5/2]) cube([5, width, 2.5], center=true);
}
// verbindungen unten
for ( i = [1 : 2] ) {
    translate([75-i*20, 0, -height/2+2.5/2]) cube([5, width, 2.5], center=true);
    translate([-75+i*20, 0, -height/2+2.5/2]) cube([5, width, 2.5], center=true);
}
