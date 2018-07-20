

module heat_sink_duct(shell) {
    fan_sleeve();
    translate([0,9.8,0])
    rotate([0,-90,0])
    #rect_duct_fan(8.5, shell);
    // translate([0,8,0])
    // heat_sink_duct_2();
}

module heat_sink_duct_2() {
    translate([0,10,0])
        rotate([0,-90,0]){
            rect_ducting_bent();
            translate([-10-1.5,12,0])
            rotate([0,0,90])
                rect_duct_fan(25);
        }
}

module duct_2d() {
    difference() {
        circle(d=19+shell*2);
        circle(d=19);
    }
}

module circle_squash(squash, r) {
    displace=r*2*squash;
    hull() {
        translate([r*2*squash,displace,0])
            circle(r=r*(1-squash));
        translate([-r*2*squash,displace,0])
            circle(r=r*(1-squash));
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

module rect_ducting(length) {
    translate([0,length/2,0])
    difference() {
        // TODO: Use shell; fix size; is this size for the sleeve?
        cube([24,length,19],center=true);
        cube([17,length+0.2,13],center=true);
    }
}

module rect_ducting_bent_solid(d, offset, extra) {
    translate([-offset,0,-offset])
    intersection() {
        rotate_extrude()
            translate([offset,offset,0])
                square([d,d], center=true);
        translate([-extra, -extra, -extra])
            cube([d*2.5, d*2.5, d*2.5]);
    }
}

module rect_duct_fan_solid(length, w, l, s) {
    hull() {
        cube([w+s*2,1,l+s*2], center=true);
        translate([-w/4,length-0.5,0])
            cube([w/2+s*2,1,l*2+s*2], center=true);
    }
}

module rect_duct_fan(length, shell) {
    difference() {
        rect_duct_fan_solid(length, 17, 19, shell);
        translate([0,-0.01,0])
        rect_duct_fan_solid(length+0.1, 17, 19, 0);
    }
}

module duct_fan_solid(length, d, shell) {
    difference() {
        minkowski() {
            hull() {
                duct_fan_3d(0, d);
                translate([0,length-1,0])
                    duct_fan_3d(0.5, d);
            }
            sphere(d=shell, center=true);
        }
        translate([0,-shell-0.01,0])
            cube([50,2*shell+0.02,50], center=true);
        translate([0,length-0.01,0])
            cube([50,2*shell+0.02,50], center=true);
    }
}

module duct_fan(length) {
    d=19;
    difference() {
        duct_fan_solid(length, d, shell*2);
        translate([0,-0.005,0])
        duct_fan_solid(length+0.01, d, 0);
    }
}

module ducting_bent_solid(d, offset, extra) {
    translate([-offset,0,-offset])
    intersection() {
        rotate_extrude()
            translate([offset,offset,0])
                circle(d=d);
        translate([-extra, -extra, -extra])
            cube([d*2.5, d*2.5, d*2.5]);
    }
}

module ducting_bent() {
    difference() {
        ducting_bent_solid(19+2*shell, 12, 0);
        ducting_bent_solid(19, 12, 0.01);
    }
}

module rect_ducting_bent() {
    difference() {
        rect_ducting_bent_solid(19+2*shell, 11, 0);
        rect_ducting_bent_solid(19, 11, 0.01);
    }
}


module fan_sleeve() {
    translate([0,-15,0])
    difference() {
        union() {
            hull() {
                translate([0,0,0])  cube([24,30,19],center=true);
                translate([0,15,0])
                rect_ducting(10);
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
