// FuseBox X-Carriage design

// Include ghost objects for comprehension/alignment checks
include_ghosts = true ;

rod_spacing = 43.25 ;
carriage_length = 47.5 ;

cowling_diameter = 22 ;
zip_tie_outer_diameter = 22.1 ;
bearing_diameter = 16 ;
flange_diameter = 12 ;
flange_thickness = 0.5 ;

// Height of the hotend holder above the bottom of the carriage
hotend_tower_height = 29.17 ;
hotend_tower_width = 40 ;
hotend_tower_thickness = 4.17 ;
hotend_grip_height = 11 ;
hotend_grip_thickness = 8.2 ;
hotend_grip_width = 14 ;

groove_collar_offset = 2 ; // Distance from top of tower to groove-collar
groove_collar_height = 5.8; // 6mm actual
groove_collar_diameter = 12 ;
groove_diameter = 16 ;

e3d_groove_mount_height=12.7 ;
e3d_groove_mount_offset=3.7 ;
e3d_heatsink_diameter = 23.5 ;  // 22.3 at base for v6lite
e3d_heatsink_height   = 30 ;
e3d_hotend_interface_height = 3 ;
e3d_hotend_height     = 11.5 ;
e3d_hotend_offset_x   = -4.5 ;
e3d_hotend_offset_y   = -8 ;
e3d_hotend_width_x    = 17.5 ;
e3d_hotend_width_y    = 16 ;
e3d_hotend_nozzle_height = 5.5 ;
e3d_hotend_nozzle_diameter = 7 ;


// Lateral carriage struts
strut_width = 3 ;
strut_height = 7.3 ;
strut_plate_height = 3.5 ;
carriage_plate_offset = 0.95 ;

// e3d hotend cooling fan mount
e3d_fan_mount_length = 40 ;
e3d_fan_mount_thickness = 3 ;
e3d_fan_mount_height = 6 ;
e3d_fan_mount_riser = 4 ;

belt_clamp_rib_spacing = 2 ;
belt_clamp_rib_count = 4 ;
belt_clamp_rib_size = 1 ;
belt_clamp_height = 7 ;
belt_clamp_gap = 1.15 ;
belt_clamp_thickness = 2.25 ;

// M3 drill holes and nut captures
m3_radius=1.6 ;
m3_nut_radius=6.5/2 ;
m3_nut_depth = 1;

// Cooling fan
cooling_fan_height = 18.9 ;
cooling_fan_width = 40 ;
cooling_fan_base_height = 4 ;
cooling_fan_thickness = 2 ;
cooling_fan_riser_width = 7 ;

// Calculated
belt_clamp_length = belt_clamp_rib_count * belt_clamp_rib_spacing ;
belt_clamp_support = belt_clamp_height*0.5 ;
cooling_fan_mount_offset = cooling_fan_width / 10 ;  // 40mm = 4, 30mm = 3
e3d_fan_mount_offset  = e3d_fan_mount_length / 10 ;  // 40mm = 4, 30mm = 3

hotend_tower_pos = [0,rod_spacing/2-bearing_diameter/2-hotend_tower_thickness, 0.001 ] ;
hotend_grip_pos = [
        carriage_length/2-hotend_grip_width/2+0.27,
        -hotend_tower_thickness-hotend_grip_thickness/2,
        hotend_tower_height - hotend_grip_height] ;


// Modules
module x_carriage() {
    difference() {
        union() {
            difference() {
                union() {
                    x_carriage_solid();
                    x_carriage_struts();
                    hotend_mount();
                    cooling_e3d_fan_mount();
                    cooling_fan_mount();
                    ghost_e3d_hotend();
                }
                x_carriage_gaps();
                x_carriage_struts_gaps();
                hotend_mount_gaps();
                hotend_mount_drill();
                four_belt_clamps_carve();
            }

            hotend_mount_support();
            four_belt_clamps();
        }
        x_carriage_gaps();
    }
}

//       orientation ,  Position
bc_offset = hotend_tower_pos[1];
bc_width  = belt_clamp_gap + belt_clamp_thickness ;
bc_right  = bc_offset - bc_width ;
bc_left   = -bc_offset -1.6;
bc_top    = carriage_length ;
bc_bottom = 0 ;

belt_clamps = [ 
    [  [0,0,0] , bc_left, bc_bottom ],
    [  [0,0,1] , bc_right, bc_top ],
    [  [1,0,1] , bc_left, bc_top ],
    [  [1,0,0] , bc_right, bc_bottom ]
 ] ;

module four_belt_clamps() {
    for ( pos = belt_clamps ) {
        orientation = pos[0] ;
        x = orientation[0] ? -(carriage_plate_offset + strut_plate_height -0.9) : -2;
        y = pos[1] ;
        z = pos[2] ;
        translate([ x, y, z ]) belt_clamp(orientation);
    }
}

module four_belt_clamps_carve() {
    for ( pos = belt_clamps ) {
        orientation = pos[0] ;
        x = orientation[0] ? -(carriage_plate_offset + strut_plate_height +0.9) : -2;
        y = pos[1] ;
        z = pos[2] ;
        translate([ x, y, z ]) belt_clamp_carve(pos[0]);
    }
}

module bearing_holder(l=carriage_length, id=bearing_diameter, od=cowling_diameter, fd=-1) {
    rfd = (fd<0) ? id-2 : fd ;
    cylinder(l,r=od/2);
}

module bearing_holder_gaps(l=carriage_length, id=bearing_diameter, od=cowling_diameter, fd=flange_diameter) {
    // Bearing
    translate([0,0,flange_thickness]) cylinder(l-flange_thickness*2,r=id/2);
    // Flange
    translate([0,0,-1]) cylinder(l+2,r=fd/2);
    // Half-cylinder
    translate([0,-od/2,-1]) cube([od/2,od,l+2]);
}

module zip_tie_ring(l=4, id=-1, od=zip_tie_outer_diameter) {
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
        translate([0,-rod_spacing/2,0]) bearing_holder_gaps() ;
        translate([0,rod_spacing/2,0]) bearing_holder_gaps() ;
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

// Hotend tower
module hotend_tower() {
    // Hot-end mount platform
    rotate([0,-90,0])
        translate(hotend_tower_pos)
        cube([hotend_tower_width,hotend_tower_thickness,hotend_tower_height]);
    translate([0,cowling_diameter/2+rod_spacing/2,hotend_tower_width/2])
        rotate([90,0,0])
        rotate([0,-90,0])
        overhang_support([cowling_diameter,hotend_tower_thickness,hotend_tower_height]);
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

module e3d_hotend() {
    translate([0,0,
            -e3d_hotend_nozzle_height
            -e3d_hotend_height
            -e3d_hotend_interface_height
            -e3d_heatsink_height
            -e3d_groove_mount_height
            +e3d_groove_mount_offset])
    {
        //-- PRINT ZONE
        //translate([0,0,-1]) cube([carriage_length*2, carriage_length*2, 1],center=true);
        //-- NOZZLE
        cylinder(h=e3d_hotend_nozzle_height, r=e3d_hotend_nozzle_diameter/2 , $fn=6);
        translate([0,0,e3d_hotend_nozzle_height]) {
            translate([e3d_hotend_offset_x , e3d_hotend_offset_y, 0] )
        
        //-- HEATER BLOCK
                cube([ e3d_hotend_width_x , e3d_hotend_width_y , e3d_hotend_height ]) ;

        //-- INTERFACE
                cylinder(h=e3d_hotend_interface_height + e3d_hotend_height + 1, r=3, $fn=30) ;
                translate([0,0,e3d_hotend_height + e3d_hotend_interface_height ]) {

        //-- HEATSINK
                    cylinder(h=e3d_heatsink_height, r=e3d_heatsink_diameter/2);
                    translate([0,0,e3d_heatsink_height-0.1]) {
                        
        //-- GROOVEMOUNT
                        cylinder(h=e3d_groove_mount_height+0.1 - e3d_groove_mount_offset - groove_collar_height, r=groove_diameter/2);
                        cylinder(h=e3d_groove_mount_height, r=groove_collar_diameter/2);
                        
                    translate([0,0,e3d_groove_mount_height - e3d_groove_mount_offset ]) {
        //-- GROOVE HEAD
                        cylinder(h=e3d_groove_mount_offset, r=groove_diameter/2);
                    }
                }
            }
        }
    }
}

module ghost_e3d_hotend() {
    if ( include_ghosts )
        %hotend_mount_gaps() ;
}
module hotend_mount_gaps() {
    // Carve out space for the e3d hotend
    rotate([0,-90,0]) {
        translate(hotend_tower_pos)
            translate(hotend_grip_pos)
            translate([hotend_grip_width/2,0,0 ])
            translate([0,0,hotend_grip_height - groove_collar_offset])
                e3d_hotend();
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
    translate([0.1,0,0])
    rotate([0,-90,0]) {
        translate([0,-strut_len/2, 0]) cube([strut_width, strut_len ,strut_height]);
        translate([carriage_length-strut_width,-strut_len/2, 0]) cube([strut_width, strut_len ,strut_height]);
        translate([0,-strut_len/2,carriage_plate_offset]) cube([carriage_length, strut_len , strut_plate_height]);
    }
}

module x_carriage_struts_gaps() {
    len = strut_len - hotend_tower_thickness - 0.7;
    rotate([0,-90,0])
        translate([(carriage_length-e3d_heatsink_diameter)/2,-rod_spacing/2+bearing_diameter/2+0.7,-0.001])
        cube([e3d_heatsink_diameter+0.5, len , strut_height]);
}

module ghost_fan( length=40, ofs=4, depth=10 ) {
    if ( include_ghosts ) {
        // Draw a "ghost" fan for alignment verification
        near = ofs ;
        far = length - ofs ;
        //color("limegreen") 
        %difference() {
            cube([length,depth,length] ) ; 
            translate([near, -.1, near]) rotate([-90,0,0]) cylinder(r=2, h=depth+.2, $fn=30);
            translate([near, -.1,  far]) rotate([-90,0,0]) cylinder(r=2, h=depth+.2, $fn=30);
            translate([ far, -.1, near]) rotate([-90,0,0]) cylinder(r=2, h=depth+.2, $fn=30);
            translate([ far, -.1,  far]) rotate([-90,0,0]) cylinder(r=2, h=depth+.2, $fn=30);
            translate([length/2, -.1, length/2]) rotate([-90,0,0]) cylinder(r=length/2-0.5, h=depth+.2, $fn=30);
        }
    }
}

module cooling_e3d_fan_mount() {
    r = e3d_fan_mount_length/2 ;
    support_length = carriage_length/2 - e3d_fan_mount_length/2 ;

    translate([-cowling_diameter/2+1,-rod_spacing/2-5,0])
        rotate([0,-90,-40])
        translate([support_length,0,0]) {
        difference() {
            union() {
                cube([e3d_fan_mount_length , 
                      e3d_fan_mount_thickness,
                      e3d_fan_mount_height + e3d_fan_mount_riser ]);

                // Support ramp
                translate([-support_length+0.01, 0, 0])
                    overhang_support([ support_length,
                        e3d_fan_mount_thickness,
                        e3d_fan_mount_height + e3d_fan_mount_riser ]);
            }
            // Fan breezeway
            translate([e3d_fan_mount_length/2,e3d_fan_mount_thickness+0.5, r+e3d_fan_mount_riser ])
                rotate([90,90,0])
                cylinder(r=r, h=e3d_fan_mount_thickness+1);

            // Mounting holes, 32mm apart for 40mm fan
            translate([e3d_fan_mount_offset, e3d_fan_mount_thickness+0.5, e3d_fan_mount_height/2 + e3d_fan_mount_riser ])
                rotate([90,90,0])
                cylinder(r=m3_radius, h=e3d_fan_mount_thickness+1, $fn=30);

            translate([e3d_fan_mount_length - e3d_fan_mount_offset,e3d_fan_mount_thickness+0.5,
                        e3d_fan_mount_height/2 + e3d_fan_mount_riser ])
                rotate([90,90,0])
                cylinder(r=m3_radius, h=e3d_fan_mount_thickness+1, $fn=5);

        }

        // Draw a "ghost" fan for alignment verification
        near = e3d_fan_mount_offset ;
        far = e3d_fan_mount_length - e3d_fan_mount_offset ;
        fan_depth = 10 ;
        translate([0,0, e3d_fan_mount_riser + e3d_fan_mount_height/2 - e3d_fan_mount_offset])
            rotate([90,270,90])
            ghost_fan( e3d_fan_mount_length , e3d_fan_mount_offset , 10 );
        }
                
}
//______________________________
//                   BELT CLAMPS

module overhang_support(size = [1,1,1]) {
    // Create a triangular ramp to support an overhang of a given size
    length = size[0];
    width = size[1] ;
    height = size[2] ;
    points = [ [0,0,0], [0,width,0], [length,width,0], [length,0,0], [length,0,height], [length,width,height] ] ;
    faces = [ [3,2,1,0], [2,3,4,5], [0,1,5,4], [0,4,3], [5,1,2]];
    polyhedron( points, faces ) ;
}

module belt_clamp_wall() {
    length = belt_clamp_length ;
    support_length = belt_clamp_support ;

    union() {
        translate([support_length-0.01,0,0])
            cube([length, belt_clamp_thickness, belt_clamp_height]) ;
        overhang_support([support_length, belt_clamp_thickness, belt_clamp_height]);
    }
}

module belt_clamp_ribbed() {
    union() {
        belt_clamp_wall();
        rad = belt_clamp_rib_size/2 ;
        for(x = [0 : belt_clamp_rib_spacing : belt_clamp_length-rad]) {
            translate([belt_clamp_support + rad + x,0,0])
                cylinder( r=rad, h=belt_clamp_height , $fn=30) ;
        }
    }
}

module belt_clamp(orientation) {
    wall_ofs = belt_clamp_gap + belt_clamp_thickness ;
    mirror([0,0,orientation[2]])
    mirror([orientation[0],0,0])
        translate([0,0,belt_clamp_length + belt_clamp_support])
        rotate([0,90,0])
        union() {
            translate([0, wall_ofs, 0])
                belt_clamp_ribbed();
            belt_clamp_wall();
        }
}
// Carve a channel before mergeing a belt-clamp
module belt_clamp_carve(orientation) {
    mirror([0,0,orientation[2]])
    mirror([orientation[0],0,0])
        translate([-0.1, belt_clamp_thickness, belt_clamp_length + belt_clamp_support+1])
        rotate([0,90,0])
        cube([belt_clamp_length+ belt_clamp_support + 2, belt_clamp_gap, belt_clamp_height+0.1]);
}

//_____________________________________
//                    COOLING FAN MOUNT
module cooling_fan_mount_screw() {
    difference() {
        union() {
            cube([cooling_fan_riser_width , cooling_fan_thickness , cooling_fan_height - cooling_fan_riser_width/2] ) ;
            hull() {
                translate([cooling_fan_riser_width/2,cooling_fan_thickness ,cooling_fan_height-cooling_fan_riser_width/2])
                    rotate([90,0,0])
                    cylinder(r=cooling_fan_riser_width/2 , h=cooling_fan_thickness , $fn=30 ) ;
                cube([cooling_fan_height*3/4, cooling_fan_thickness , cooling_fan_base_height] ) ;
            }
        }
        translate([cooling_fan_riser_width/2,cooling_fan_thickness-0.1,cooling_fan_height-cooling_fan_riser_width/2])
            rotate([90,0,0])
            cylinder(r=m3_radius , h=cooling_fan_thickness+0.2 , $fn=30 ) ;
        translate([cooling_fan_riser_width/2,cooling_fan_thickness+0.1,cooling_fan_height-cooling_fan_riser_width/2])
            rotate([90,0,0])
            cylinder(r=m3_nut_radius , h=cooling_fan_thickness/2 , $fn=6 ) ;

        // Arbitrary hole
        translate([cooling_fan_riser_width*.79,cooling_fan_thickness+0.1,cooling_fan_height - cooling_fan_riser_width*1.58])
            rotate([90,0,0])
            cylinder(r=cooling_fan_riser_width/2-0.5, h=cooling_fan_thickness+0.5 , $fn=30 ) ;
    }
}

module cooling_fan_mount() {
    translate([0,rod_spacing/2+cowling_diameter/2+cooling_fan_thickness/2,(cooling_fan_width+carriage_length)/2-0.25])
    rotate([180,0,0])
    rotate([0,-90,0])
    union() {
        difference() {
            union() {
                cooling_fan_mount_screw() ;
                translate([ cooling_fan_width - cooling_fan_mount_offset*2, 0, 0])
                    cooling_fan_mount_screw() ;
    //            cube([cooling_fan_width, cooling_fan_thickness , cooling_fan_base_height] ) ;
            }
            translate([ cooling_fan_width+3, -0.1, -0.10])
                cube([cooling_fan_width, cooling_fan_thickness +0.2, cooling_fan_height] ) ;
        }
        translate([cooling_fan_riser_width/2 - cooling_fan_mount_offset,-10,cooling_fan_height-cooling_fan_riser_width/2 + cooling_fan_mount_offset -cooling_fan_width])
        ghost_fan(cooling_fan_width, cooling_fan_mount_offset) ;
    }
}

x_carriage();
