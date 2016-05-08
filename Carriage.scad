/*

Name: FB2020 Left Carrier
Author: Ax Smith-Laffin - AxMod Box Mods Limited (https://www.axmod.co.uk) /Sledz UK (https://www.sledz-uk.co.uk)

License: GNU GPL
License URL: http://www.gnu.org/licenses/gpl-2.0.html

*/

//smooth cylinders
$fn=64;

//add extra diameter to holes - use if your printer prints on the tight side
extradiameter=1;

//add extra width to the slot in the belt clips - use if you find the belt is very difficult to fit
extrawidth=0.1;

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

e3d_cooling_fan_width = 30 ;
e3d_cooling_fan_height = 30 ;

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
        //-- COOLING FAN
                    translate([-e3d_cooling_fan_width/2, -e3d_heatsink_diameter/2-10,0]) 
                    #cube([e3d_cooling_fan_width, e3d_heatsink_diameter+10-2, e3d_cooling_fan_height]);
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

//E3D Collar
module e3dv6(){
translate([22,26.5,-14.8]){
cylinder(d=16+extradiameter,h=3);
translate([0,0,3-0.01]) cylinder(d=12+extradiameter,h=5.91);
translate([0,0,8.4]) cylinder(d=16+extradiameter,h=4);
translate([0,0,e3d_groove_mount_height-e3d_groove_mount_offset-0.5])
    %e3d_hotend();

    }
}

//nut trap modules
module m3nut(){
cylinder(r = 5.5 / 2 / cos(180 / 6) + 0.05, h=3, $fn=6);
}
module m3nut2(){
cylinder(r = 5.5 / 2 / cos(180 / 6) + 0.05, h=6, $fn=6);
}
//holes for the bolts.. duh.. 
module boltholes(){
translate([13.5,39.5,-9])
rotate([90,0,0])
cylinder(d=3+extradiameter, h=30);
translate([30.5,39.5,-9])
rotate([90,0,0])
cylinder(d=3+extradiameter, h=30);
}

//belt clip module
module bcinner(){
#difference(){

translate([-1.85,0,0])    
cube([7+extrawidth,11,8.5]);

translate([2.2,-1,1])
cube([1.1+extrawidth,12,11]);
translate([-5,11,0])
rotate([20.6,0,0])
cube([12,5,9]);
}

translate([2.1,1.5,0])
cylinder(d=1, h=8.5);

translate([2.1,3.5,0])
cylinder(d=1, h=8.5);

translate([2.1,5.5,0])
cylinder(d=1, h=8.5);

translate([2.1,7.5,0])
cylinder(d=1, h=8.5);
}

//left bearing cut
module bearingcut(){
translate([0,0,-1])
  cylinder(d=15.1, h=55);
#translate([0,0,-1])
  cylinder(d=8.1, h=55);
translate([-3,-5.5,4])
	cube([18.5,20,45]);
translate([9,38,7.5])
cube([20,12,7]);
}

//left bearing tube
module bearing(){
difference(){
cylinder(d=18.8, h=53);
bearingcut();
}
}

//right bearing tube
module bearingcuts(){
bearingcut();
translate([43.25,0,0])
mirror([1,0,0])
	bearingcut();
}

//right bearing tube
module bearingtube(){
bearing();
translate([43.25,0,0])
mirror([1,0,0])
	bearing();
}

//hotend hole in carriage
module hotendcut(){
hull(){
translate([22,31.5,-10])
cylinder(d=30+extradiameter,h=22);
translate([22,17.5,-10])
cylinder(d=30+extradiameter,h=22);
}
}


//main carriage
module basecarriage(){
rotate([-90,0,0])
bearingtube();

//central join
difference(){
    union() {
        translate([0,0,7])
            cube([43,53,2.5]);
//        translate([0,0,-8.9])
//            cube([43,53,2.5]);
    }
//re-drill bearing paths
rotate([-90,0,0])
bearingcuts();

//endstop screw holes
translate([18,48.5,-3])
cylinder(d=2+extradiameter,h=15);
translate([24.5,48.5,-3])
cylinder(d=2+extradiameter,h=15);

//hole for hot end
hotendcut();
}

/*
//hot end clamp on carriage

translate([45,2.5,50])
rotate([0,0,90])
difference(){
translate([6.78,26.5,-8.5]){
    translate([-9.3,3.5,-33])
        cube([8,6,33]);
    translate([30,3.5,-33])
        cube([8,6,33]);
minkowski(){
cube([30,8.5,1]);
rotate([-90,0,0])
cylinder(d=10, h=1);
}
}

//hot end cut out
e3dv6();

//bolt holes through clamp on carriage
boltholes();

//nut trap/bolt head hole
translate([30.5,39,-9])
rotate([90,0,0])
cylinder(d=6+extradiameter, h=7.5);

translate([13.5,39,-9])
rotate([90,0,0])
m3nut2();
}
*/

//reinforce top of carriage
translate([7.5,0,6.5])
rotate([-90,0,0])
cylinder(d=3, h=53);

translate([36,0,6.5])
rotate([-90,0,0])
cylinder(d=3, h=53);

}

//top belt clips - change bcinner to bcouter to reverse where clamp notches are.
module topclip(){

translate([9.5,0,1])
bcinner();

translate([33.8,53,1])
rotate([0,0,180])
	bcinner();
}

//lower belt clip
module clips(){
topclip();
translate([43.35,0,0])
rotate([180,0,180])
topclip();
}

//combine clips and carriage
module carriage(){
difference() { union() {
//clips();
basecarriage();
}

hotendcut();
}
}

//hot end clamp
module clamp(){
difference(){
translate([10,16.45,-13.5])
cube([24,10,10]);

//hot end cut out
e3dv6();
//bolt holes through clamp
boltholes();
//nut trap/bolt head hole
translate([30.5,19,-9])
rotate([90,0,0])
m3nut();

translate([13.5,19,-9])
rotate([90,0,0])
cylinder(d=6+extradiameter, h=3);
}
}

rotate([90,0,0]) {
//clamp();
carriage();
}