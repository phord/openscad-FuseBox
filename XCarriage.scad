// FuseBox X-Carriage design

rod_spacing = 43.25 ;
carriage_length = 47.5 ;

cowling_diameter = 23 ;
bearing_diameter = 16 ;

// Height of the hotend holder above the bottom of the carriage
hotend_tower_height = 29.25 ; 
hotend_tower_width = 40 ; 
hotend_tower_thickness = 4 ;
hotend_grip_height = 11 ;
hotend_grip_thickness = 9 ;
hotend_grip_width = 14 ;

groove_collar_offset = 2 ; // Distance from top of tower to groove-collar
groove_collar_height = 5.7;
groove_collar_diameter = 12 ;
groove_diameter = 16 ;
e3d_cooling_diameter = 24 ;
e3d_cooling_height = 30 ;

// Lateral carriage struts
strut_width = 3 ;
strut_height = 7 ;
strut_plate_height = 3.5 ;

// Modules
module bearing_holder(l=carriage_length, id=bearing_diameter, od=cowling_diameter, fd=-1) {
    rfd = (fd<0) ? id-2 : fd ;
    difference() {
        // Outer body
        cylinder(l,r=od/2);
        // Bearing
        translate([0,0,1]) cylinder(l-2,r=id/2);
        // Flange
        translate([0,0,-1]) cylinder(l+2,r=rfd/2);
        
        // Half-cylinder
        translate([0,-od/2,-1]) cube([od/2,od,l+2]);
    }
}

module zip_tie_ring(l=4, id=-1, od=21) {
    rid = (id<0) ? od-3 : id ;
    difference() {
        // Ring channel
        cylinder(l,r=od/2);
        // Inner limit
        translate([0,0,-1]) cylinder(l+2,r=rid/2);
    }
}

module lm8zz_long_2() {
    difference() {
        bearing_holder();
        translate([0,0,5]) zip_tie_ring();
        translate([0,0,38.5]) zip_tie_ring();
    }
}

module x_carriage_solid() {
    union() {
        translate([0,-rod_spacing/2,0]) bearing_holder() ;
        translate([0,rod_spacing/2,0]) bearing_holder() ;
    }
}
module x_carriage_gaps() {
    union() {
        translate([0,-rod_spacing/2,0]) {
            translate([0,0,5]) zip_tie_ring();
            translate([0,0,38.5]) zip_tie_ring();
        }
        translate([0,rod_spacing/2,0]) {
            translate([0,0,5]) zip_tie_ring();
            translate([0,0,38.5]) zip_tie_ring();
        }
    }
}

module hotend_grip() {
}

hotend_tower_pos = [0,rod_spacing/2-bearing_diameter/2-hotend_tower_thickness, 0.001 ] ;
hotend_grip_pos = [
        carriage_length/2-hotend_grip_width/2,
        -hotend_tower_thickness-hotend_grip_thickness/2,
        hotend_tower_height - hotend_grip_height] ;


module hotend_mount() {
    // Hot-end mount platform
    translate(hotend_tower_pos) {
        cube([hotend_tower_width,hotend_tower_thickness,hotend_tower_height]);
    
    // Hot-end neck grip (e3d)
        translate(hotend_grip_pos)
            cube([hotend_grip_width,hotend_grip_thickness+0.1,hotend_grip_height]);
    }
}

module hotend_mount_gaps() {
    // Carve out space for the e3d hotend
    // Hot-end neck grip (e3d)
        translate(hotend_tower_pos)
            translate(hotend_grip_pos) {
                translate([hotend_grip_width/2,0,-0.5])
                    cylinder(h=hotend_grip_height+1, r=groove_collar_diameter/2);
                translate([hotend_grip_width/2,0,hotend_grip_height-groove_collar_offset])
                    cylinder(h=groove_collar_offset+0.1, r=groove_diameter/2);
                translate([hotend_grip_width/2,0,-0.5])
                    cylinder(h=hotend_grip_height-groove_collar_offset-groove_collar_height+0.5, r=groove_diameter/2);
            }
        translate([carriage_length/2,0,hotend_tower_height-hotend_grip_height-e3d_cooling_height-0.001])
            cylinder(h=e3d_cooling_height, r=e3d_cooling_diameter/2);
}

strut_len = rod_spacing-bearing_diameter ;
module x_carriage_struts() {
    translate([0,-strut_len/2, 0]) cube([strut_width, strut_len ,strut_height]);
    translate([carriage_length-strut_width,-strut_len/2, 0]) cube([strut_width, strut_len ,strut_height]);
    translate([0,-strut_len/2,0.5]) cube([carriage_length, strut_len , strut_plate_height]);
}

module x_carriage_struts_gaps() {
    len = strut_len - hotend_tower_thickness ;
    translate([(carriage_length-e3d_cooling_diameter)/2,-len/2,-0.001]) 
        cube([e3d_cooling_diameter, len , strut_height]);
}

difference() {
    union() {
        rotate([0,90,0])
            x_carriage_solid();
        x_carriage_struts();
        hotend_mount();
    }
    rotate([0,90,0])
        x_carriage_gaps();
    x_carriage_struts_gaps();
    hotend_mount_gaps();
}