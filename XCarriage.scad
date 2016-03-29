// FuseBox X-Carriage design

rod_spacing = 43.25 ;
carriage_length = 47.5 ;

cowling_diameter = 23 ;
bearing_diameter = 16 ;

// Height of the hotend holder above the bottom of the carriage
hotend_tower_height = 35.25 ;
hotend_tower_width = 40 ;
hotend_tower_thickness = 4 ;
hotend_grip_height = 11 ;
hotend_grip_thickness = 9 ;
hotend_grip_width = 14 ;

groove_collar_offset = 2 ; // Distance from top of tower to groove-collar
groove_collar_height = 5.7;
groove_collar_diameter = 12 ;
groove_diameter = 16 ;
e3d_cooling_diameter = 23 ; // 22.3 actual
e3d_cooling_height = 30 ;

// Lateral carriage struts
strut_width = 3 ;
strut_height = 7 ;
strut_plate_height = 3.5 ;

// Hotend cooling fan mount
fan_mount_length = 40 ;
fan_mount_thickness = 3 ;
fan_mount_height = 4 ;
fan_mount_riser = 3 ;


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

hotend_tower_pos = [0,rod_spacing/2-bearing_diameter/2-hotend_tower_thickness, 0.001 ] ;
hotend_grip_pos = [
        carriage_length/2-hotend_grip_width/2,
        -hotend_tower_thickness-hotend_grip_thickness/2,
        hotend_tower_height - hotend_grip_height] ;


module hotend_tower() {
    // Hot-end mount platform
    rotate([0,-90,0])
        translate(hotend_tower_pos)
        cube([hotend_tower_width,hotend_tower_thickness,hotend_tower_height]);
}

module hotend_grip() {
    // Hot-end neck grip (e3d)
    rotate([0,-90,0])
        translate(hotend_tower_pos)
        translate(hotend_grip_pos)
        cube([hotend_grip_width,hotend_grip_thickness+0.1,hotend_grip_height]);
}

module hotend_mount() {
    union() {
        hotend_tower();
        hotend_grip();
    }
}

m3_radius=1.6 ;
m3_nut_radius=6.5/2 ;
m3_nut_depth = 1;
module hotend_mount_drill_one(x=3.4) {
    // e3d Mount piece screw holes
    tower_drill_distance = 3.4 + m3_radius ;
    rotate([0,-90,0]) {
        translate([x,hotend_tower_pos[1],hotend_tower_height - tower_drill_distance])
        rotate([90,0,0]) 
        union() {
            translate([0,0,-hotend_tower_thickness-0.5])
                cylinder(r=m3_radius, h=hotend_tower_thickness +1 , $fn=30) ;
            translate([0,0,-hotend_tower_thickness-0.5])
                cylinder(r=m3_nut_radius, h=m3_nut_depth+0.5 , $fn=6) ;
        }
    }
}

module hotend_mount_drill() {
    // e3d Mount piece screw holes
    union() {
        hotend_mount_drill_one(3.4 + m3_radius );
        hotend_mount_drill_one(hotend_tower_width - 2.4 - m3_radius ) ;
    }
}

module hotend_mount_gaps() {
    // Carve out space for the e3d hotend
    // Hot-end neck grip (e3d)
    rotate([0,-90,0]) {
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
}

module hotend_mount_overhang() {
    difference() {
        hotend_grip();
        hotend_mount_gaps();
    }
}

module hotend_mount_support() {
    translate([-hotend_grip_width/2,hotend_grip_height,0])
        rotate([0,-90,0])
        translate(hotend_tower_pos)
        translate(hotend_grip_pos)
        rotate([0,90,0])
        mirror([0,0,1])
            linear_extrude(height=hotend_grip_thickness, scale=0)
            translate([hotend_grip_width/2,-hotend_grip_height,0])
                projection()
                rotate([0,-90,0])
                translate(-hotend_tower_pos)
                translate(-hotend_grip_pos)
                    rotate([0,90,0])
                        hotend_mount_overhang();
}

strut_len = rod_spacing-bearing_diameter ;
module x_carriage_struts() {
    rotate([0,-90,0]) {
        translate([0,-strut_len/2, 0]) cube([strut_width, strut_len ,strut_height]);
        translate([carriage_length-strut_width,-strut_len/2, 0]) cube([strut_width, strut_len ,strut_height]);
        translate([0,-strut_len/2,0.5]) cube([carriage_length, strut_len , strut_plate_height]);
    }
}

module x_carriage_struts_gaps() {
    len = strut_len - hotend_tower_thickness - 0.7;
    rotate([0,-90,0])
        translate([(carriage_length-e3d_cooling_diameter)/2,-rod_spacing/2+bearing_diameter/2+0.7,-0.001])
        cube([e3d_cooling_diameter, len , strut_height]);
}

module x_carriage() {
difference() {
    union() {
        x_carriage_solid();
        x_carriage_struts();
        hotend_mount();
        cooling_fan_mount();
    }
    x_carriage_gaps();
    x_carriage_struts_gaps();
    hotend_mount_gaps();
    hotend_mount_drill();

}

hotend_mount_support();
}


module cooling_fan_mount() {
    r = fan_mount_length*1.5/2 ;
    support_length = fan_mount_height + fan_mount_riser ;

    translate([-cowling_diameter/2+1,-rod_spacing/2-5,0])
        rotate([0,-90,-40])
        translate([support_length,0,0])
        difference() {
            translate([-support_length, 0, 0])
                cube([fan_mount_length + support_length, 
                      fan_mount_thickness,
                      fan_mount_height + fan_mount_riser ]);

            // Support ramp
            translate([-support_length, -0.5, 0])
                rotate([0,-45,0])
                cube([ support_length*1.5, fan_mount_thickness+1, 
                       fan_mount_height + fan_mount_riser ]);

            // Fan breezeway
            translate([fan_mount_length/2,fan_mount_thickness+0.5, r+fan_mount_riser ])
                rotate([90,90,0])
                cylinder(r=r, h=fan_mount_thickness+1);

            // Mounting holes, 32mm apart for 40mm fan
            #translate([3,fan_mount_thickness+0.5, fan_mount_height/2 + fan_mount_riser ])
                rotate([90,90,0])
                cylinder(r=m3_radius, h=fan_mount_thickness+1, $fn=5);

            #translate([fan_mount_length - 3,fan_mount_thickness+0.5,
                        fan_mount_height/2 + fan_mount_riser ])
                rotate([90,90,0])
                cylinder(r=m3_radius, h=fan_mount_thickness+1, $fn=5);

            %translate([0,0, fan_mount_riser ])
                rotate([90,270,90])
                cube([fan_mount_length,10, fan_mount_length] ) ; 
        }
}

x_carriage();

