$fn=64;

// Belt clips
belt_gap=1.5;
belt_post=4.5;
belt_height=8.5;

module beltclip_shell(shell, extra) {
    // Belt clip dimensions
    dx = belt_post + belt_gap*2 + extra*2 ;
    dy = 11 + belt_gap;
    dz = belt_height + extra;
    translate([0,extra/2,(shell-extra)/2])
    hull(){
        translate([0,-dy/2,0])
        cube([dx,0.1,dz], center=true);
        translate([dx/2-1,dy/2-1,0])
        cylinder(d=2.01, h=dz, center=true);
        translate([-dx/2+1,dy/2-1,0])
        cylinder(d=2.01, h=dz, center=true);
    }
}

module beltclip_cutout(shell) {
    extra = 0;
    dx = belt_post + belt_gap*2;
    dy = 11 + belt_gap;
    dz = belt_height;
    translate([dx/2+shell, dy/2-0.1, -dz/2 - shell/2 + 0.1])
    beltclip_shell(shell, 0.1);
}

// belt clip module
// p=1:  outside teeth
// p=-1: inside teeth
module beltclip_(shell, p){
    // Center of the belt gap
    x1 = belt_post/2 + belt_gap/2;
    // Center of the belt gap teeth
    x2 = x1 + p * belt_gap/2;

    // Belt clip dimensions
    dx = belt_post + belt_gap*4 ;
    dy = 11 + belt_gap;
    dz = belt_height + shell;

    translate([dx/2, dy/2, -dz/2]) {
        difference(){
            beltclip_shell(shell, shell);

            // cut the left path
            translate([-x1,-0.1,shell])
                cube([belt_gap, dy+0.1, dz+0.1], center=true);

            // cut the right path
            translate([x1,-0.1,shell])
                cube([belt_gap, dy+0.1, dz+0.1], center=true);

            // Cut an angle in the interface for printing
            translate([0, dy/2, 0])
                rotate([20,0,0])
                cube([dx+0.1, 5, dz*1.4], center=true); // tbd: center
        }

        difference() {
            beltclip_shell(shell, shell);
            translate([0,-0.1,0.1])
                beltclip_shell(shell, 0.1);
        }

        // Insert the belt teeth, 2mm apart
        for (y=[1,3,5,7]) {
            translate([-x2, y-dy/2+0.5, 0])
                cylinder(d=1, h=dz, center=true);
            translate([x2, y-dy/2+0.5, 0])
                cylinder(d=1, h=dz, center=true);
        }
    }
}

module beltclip(shell){
    beltclip_(shell, 1);
    // beltclip_(shell, 3.4, 5.1);
}

//belt clip module
module beltclip2(shell){
    beltclip_(shell, -1);
}

module clip_test() {
    shell=1.5;
    translate([20, 0, 0]) {
        difference() {
            translate([-5,0,-12])
            cube([20,17,12]);
            beltclip_cutout(shell);
        }
        beltclip(shell);
    }

    translate([-20, 0, 0]) {
        difference() {
            translate([-5,0,-12])
            cube([20,17,12]);
            beltclip_cutout(shell);
        }
        beltclip2(shell);
    }
}
shell=1.5;
// mirror([0,0,1])
beltclip2(shell);
clip_test();