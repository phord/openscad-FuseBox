// Compact direct drive bowden extruder for 3mm or 1.75mm filament
// Licence: CC BY-SA 3.0, http://creativecommons.org/licenses/by-sa/3.0/
// Author: Dominik Scholz <schlotzz@schlotzz.com> and contributors
// Using MK8 style hobbed pulley 13x8mm from: https://www.reprapsource.com/en/show/6889
// visit: http://www.schlotzz.com
// changed: 2014-04-04, added idler slot and funnel on bowden side for easier filament insertion
// changed: 2014-04-27, placed base and idler "printer ready"
// changed: 2014-09-22, fixed non-manifold vertexes between base and filament tunnel
// changed: 2014-11-13, added bowden inlet
// changed: 2015-03-17, updated idler for better MK7 drive gear support
// changed: 2015-10-13, designed alternative idler to solve breaking of bearing support


/*
	design goals:
	- use 13x8mm hobbed pulley (mk8) or 13x12mm (mk7)
	- filament diameter parametric (1.75mm or 3mm)
	- use 608zz bearing
	- use M5 push fit connector
*/

/* Drive gear options
        0 - Filament diameter
        1 - Drive gear diameter
        2 - Drive gear height
        3 - Drive gear hobbed diameter
        4 - Drive gear hobbed offset
        5 - Drive gear teeth depth
        6 - Drive gear hobbed width
*/
//                         dFil , dGear, hGear dHob  oHob , dTth, hHob
MK8_175                = [ 1.75 , 8.00 , 13 ,  6.35 , 3.2 , 0.2 , 1.75 ] ; // MK8 1.75mm
MK8_300                = [ 3.00 , 8.00 , 13 ,  6.35 , 3.2 , 0.2 , 3.0  ] ; // MK8 3.00mm
MK8_175_ROBOTDIGG      = [ 1.75 , 9.00 , 11 ,  6.91 , 4.0 , 0.2 , 3.2  ] ; // MK8 1.75mm from RobotDigg.com
MK8_300_ROBOTDIGG      = [ 3.00 , 9.00 , 11 ,  6.91 , 4.0 , 0.2 , 4.5  ] ; // MK8 3.00mm from RobotDigg.com

/* Push-fit connector options
        0 - Diameter
        1 - Depth
*/
M5                 = [ 5 , 5 ] ;
M10                = [ 9.5 , 10.5 ];

//_________________________________________________________________________
// Choose an option set for drive from the drive gear list above
drive = MK8_300_ROBOTDIGG ;
//drive = MK8_175;

// Choose an option for pushfit connector from the pushfit connector list above
pushfit = M10 ;

// inlet type
inlet_type = 0; // 0:normal, 1:push-fit

//_________________________________________________________________________

// avoid openscad artefacts in preview
epsilon = 0.01;

// increase this if your slicer or printer make holes too tight
extra_radius = 0.1;

// major diameter of metric 3mm thread
m3_major = 2.85;
m3_radius = m3_major / 2 + extra_radius;
m3_wide_radius = m3_major / 2 + extra_radius + 0.2;

// diameter of metric 3mm hexnut screw head
m3_head_radius = 3 + extra_radius;

// drive gear
drive_gear_outer_radius = drive[1] / 2;
drive_gear_hobbed_radius = drive[3] / 2;
drive_gear_hobbed_offset = drive[4] ;
drive_gear_hobbed_width = drive[6];
drive_gear_length = drive[2];
drive_gear_tooth_depth = drive[5];

// outlet size
bowden_pushfit_diameter = pushfit[0] ;
bowden_pushfit_length   = pushfit[1] ;

// base width for frame plate
base_width = 15;
base_length = 60;
base_height = 5;

// nema 17 dimensions
nema17_width = 42.3;
nema17_hole_offsets = [
	[-15.5, -15.5, 1.5],
	[-15.5,  15.5, 1.5],
	[ 15.5, -15.5, 1.5],
	[ 15.5,  15.5, 1.5 + base_height]
];

// filament
filament_diameter = drive[0];
filament_offset = [
	drive_gear_hobbed_radius + filament_diameter / 2 - drive_gear_tooth_depth,
	0,
	base_height/2 + drive_gear_length - drive_gear_hobbed_offset
];





// helper function to render a rounded slot
module rounded_slot(r = 1, h = 1, l = 0, center = false)
{
	hull()
	{
		translate([0, -l / 2, 0])
			cylinder(r = r, h = h, center = center);
		translate([0, l / 2, 0])
			cylinder(r = r, h = h, center = center);
	}
}


// mounting plate for nema 17
module nema17_mount()
{
	// settings
	width = nema17_width;
	height = base_height;
	edge_radius = 27;
	axle_radius = drive_gear_outer_radius + 1 + extra_radius;

	difference()
	{
		// base plate
		translate([0, 0, height / 2])
			intersection()
			{
				cube([width, width, height], center = true);
				cylinder(r = edge_radius, h = height + 2 * epsilon, $fn = 128, center = true);
			}

		// center hole
		translate([0, 0, -epsilon]	)
			cylinder(r = 11.25 + extra_radius, h = base_height + 2 * epsilon, $fn = 32);

		// axle hole
		translate([0, 0, -epsilon])
			cylinder(r = axle_radius, h = height + 2 * epsilon, $fn = 32);

		// mounting holes
		for (a = nema17_hole_offsets)
			translate(a)
			{
				cylinder(r = m3_radius, h = height * 4, center = true, $fn = 16);
				cylinder(r = m3_head_radius, h = height + epsilon, $fn = 16);
			}
	}
}


// plate for mounting extruder on frame
module frame_mount()
{
	// settings
	width = base_width;
	length = base_length;
	height = base_height;
	hole_offsets = [
		[0,  length / 2 - 6, 2.5],
		[0, -length / 2 + 6, 2.5]
	];
	corner_radius = 3;

    rotate([0,-90,0])
	difference()
	{
		// base plate
		intersection()
		{
			union()
			{
				translate([0, 0, height / 2])
					cube([width, length, height], center = true);
				translate([base_width / 2 - base_height / 2 - corner_radius / 2, 0, height + corner_radius / 2])
					cube([base_height + corner_radius, nema17_width, corner_radius], center = true);
				translate([base_width / 2 - base_height / 2, 0, 6])
					cube([base_height, nema17_width, 12], center = true);
			}

			cylinder(r = base_length / 2, h = 100, $fn = 32);
		}

		// rounded corner
		translate([base_width / 2 - base_height - corner_radius, 0, height + corner_radius])
			rotate([90, 0, 0])
				cylinder(r = corner_radius, h = nema17_width + 2 * epsilon, center = true, $fn = 32);

		// mounting holes
		for (a = hole_offsets)
			translate(a)
			{
				cylinder(r = m3_wide_radius, h = height * 2 + 2 * epsilon, center = true, $fn = 16);
				cylinder(r = m3_head_radius, h = height + epsilon, $fn = 16);
			}

		// nema17 mounting holes
		translate([base_width / 2, 0, nema17_width / 2 + base_height])
			rotate([0, -90, 0])
			for (a = nema17_hole_offsets)
				translate(a)
				{
					cylinder(r = m3_radius, h = height * 4, center = true, $fn = 16);
					cylinder(r = m3_head_radius, h = height + epsilon, $fn = 16);
				}
	}
}

// simpler plate for mounting extruder on frame
module flat_frame_mount()
{
	// settings
	width = base_width;
	length = base_length/2;
	height = base_height*3/4;
	hole_offsets = [
		[0,  length / 2 - 6, height/4],
		[0, -length / 2 + 6, height/4]
	];

    translate([-width/2,0,height/2])
	difference()
	{
		// base plate
		intersection()
		{
            cube([width, length, height], center = true);
			cylinder(r = length / 2, h = 100, $fn = 32, center = true);
		}

		// mounting holes
		for (a = hole_offsets)
			translate(a)
			{
				cylinder(r = m3_wide_radius, h = height * 2 + 2 * epsilon, center = true, $fn = 16);
				cylinder(r = m3_head_radius, h = height/2 + epsilon, $fn = 16, center = true);
			}

	}
}


// inlet for filament
module filament_tunnel()
{
	// settings
    inlet_radius = 3.5;
    outlet_radius = bowden_pushfit_diameter/2 + 1.25 ;

	width = inlet_radius * 2  ;
	length = nema17_width;
	//height = filament_offset[2] ;
	height = filament_offset[2] - base_height + outlet_radius;
    filament_height = -height / 2 + filament_offset[2] - base_height ;

	translate([0, 0, height / 2])
	{
		difference()
		{
			union()
			{
				// base
				translate([0, 0, -height / 2 + filament_offset[2]/4])
                    cube([width , length, filament_offset[2]/2], center = true);

				// inlet
				translate([0, 0, filament_height])
					rotate([90, 0, 0])
						cylinder(r = inlet_radius, h = length + 2 * epsilon, center = true, $fn = 32);
				translate([0, length/8 + epsilon, filament_height])
					rotate([90, 0, 0])
						cylinder(r2 = inlet_radius, r1=outlet_radius, h = length/4 + 2 * epsilon, center = true, $fn = 32);

                // outlet pushfit cowling
				translate([0, length *3/ 8 , filament_height ])
					rotate([90, 0, 0])
						cylinder(r = outlet_radius, h = length/4, center = true, $fn = 32);

				// idler tensioner
				intersection()
				{
					translate([5, -length / 2 + 8, -height / 2 + filament_offset[2]/4+inlet_radius/2])
						cube([width, 16, filament_offset[2]/2 +inlet_radius], center = true);
					translate([-17.8, -20 ,0])
						cylinder(r = 27, h = height + 2 * epsilon, center = true, $fn = 32);
				}

			}

			// middle cutout for drive gear
			translate([-filament_offset[0], 0, 0])
				cylinder(r = drive_gear_outer_radius + 2*extra_radius,
                         h = height + 2 * epsilon, center = true, $fn = 32);
			translate([-filament_offset[0], 0, -height/2 - epsilon])
                scale([1,1,(filament_height-inlet_radius+base_height) / (height/2)])
                    sphere(r=11.5 , center=true , $fn = 32);

			// middle cutout for idler
			translate([11 + filament_diameter/4 , 0, 0])
				cylinder(r = 11.5 + extra_radius, h = height + 2 * epsilon, center = true, $fn = 32);

			// idler mounting hexnut
			translate([filament_diameter + 1, -nema17_width / 2 + 4, .25])
				rotate([0, 90, 0])
					cylinder(r = m3_radius, h = 50, center = false, $fn = 32);
			translate([filament_diameter + 3, -nema17_width / 2 + 4, 5])
				cube([2.5 + 3 * extra_radius, 5.5 + 2.5 * extra_radius, 10], center = true);
			translate([filament_diameter + 3, -nema17_width / 2 + 4, 0])
				rotate([0, 90, 0])
					cylinder(r = 3.15 + 2.5 * extra_radius, h = 2.5 + 3 * extra_radius, center = true, $fn = 6);

//			// rounded corner
//			translate([-height - width / 2, 0, height / 2])
//				rotate([90, 0, 0])
//					cylinder(r = height, h = length + 2 * epsilon, center = true, $fn = 32);

			// funnel inlet
			if (inlet_type == 0)
			{
				// normal type
				translate([0, -length / 2 + 1 - epsilon, filament_height])
					rotate([90, 0, 0])
						cylinder(r1 = filament_diameter / 2, r2 = filament_diameter / 2 + 1 + epsilon / 1.554,
							h = 3 + epsilon, center = true, $fn = 16);
			}
			else
			{
				// inlet push fit connector m5 hole
				translate([0, -length / 2 - 1 + 2.5 + epsilon, filament_height])
					rotate([90, 0, 0])
						cylinder(r = 2.25, h = 5 + 2 * epsilon, center = true, $fn = 16);

				// funnel inlet outside
				translate([0, -length / 2 + 4, filament_height])
					rotate([90, 0, 0])
						cylinder(r1 = filament_diameter / 2, r2 = filament_diameter / 2 + 1,
							h = 2, center = true, $fn = 16);

			}

			// funnnel outlet inside
			translate([0, drive_gear_outer_radius, filament_height])
				rotate([90, 0, 0])
					cylinder(r1 = filament_diameter / 2, r2 = filament_diameter / 2 + 1.25,
						h = 8, center = true, $fn = 16);

			// outlet push fit connector hole
			translate([0, length / 2 - bowden_pushfit_length/2 + epsilon, filament_height])
				rotate([90, 0, 0])
					cylinder(r = bowden_pushfit_diameter/2, h = bowden_pushfit_length + 2 * epsilon, center = true, $fn = 16);

			// funnel outlet outside
			translate([0, drive_gear_outer_radius + 6, filament_height])
				rotate([90, 0, 0])
					cylinder(r1 = filament_diameter / 2 + 1 + extra_radius, r2 = filament_diameter / 2 + extra_radius,
						h = 2, center = true, $fn = 16);

			// filament path
			translate([0, 0, filament_height])
				rotate([90, 0, 0])
					cylinder(r = filament_diameter / 2 + 2 * extra_radius,
						h = length + 2 * epsilon, center = true, $fn = 16);

			// screw head inlet
			translate(nema17_hole_offsets[2] - [filament_offset[0], 0, height / 2 + 1.5])
				sphere(r = m3_head_radius, $fn = 16);
		}
	}
}


// render drive gear
module drive_gear()
{
	r = drive_gear_outer_radius - drive_gear_hobbed_radius;
	rotate_extrude(convexity = 10)
	{
		difference()
		{
			square([drive_gear_outer_radius, drive_gear_length]);
			translate([drive_gear_hobbed_radius + 2*r, drive_gear_length - drive_gear_hobbed_offset])
				circle(r = 2*r, $fn = 16);
		}
	}
}


// render 608zz
module bearing_608zz()
{
	difference()
	{
		cylinder(r = 11, h = 7, center = true, $fn = 32);
		cylinder(r = 4, h = 7 + 2 * epsilon, center = true, $fn = 16);
	}
}


// idler with 608 bearing, simple version
module idler_608_v1()
{
	// settings
	width = nema17_width;
	height = filament_offset[2] - base_height + 4;
	edge_radius = 27;
	hole_offsets = [-width / 2 + 4, width / 2 - 4];
	bearing_bottom = filament_offset[2] / 2 - base_height / 2 - 6;
	offset = drive_gear_hobbed_radius - drive_gear_tooth_depth + filament_diameter;
	pre_tension = 0.25;
	gap = 1;

	// base plate
	translate([0, 0, height / 2])
	difference()
	{
		union()
		{
			// base
			intersection()
			{
				cube([width, width, height], center = true);
				translate([0, 0, 0])
					cylinder(r = edge_radius, h = height + 2 * epsilon, $fn = 128, center = true);
				translate([offset + 12 + gap, 0, 0])
					cube([15, nema17_width + epsilon, height], center = true);
			}

			// bearing foot enforcement
			translate([offset + 11 - pre_tension, 0, -height / 2])
				cylinder(r = 4 - extra_radius + 1, h = height - .5, $fn = 32);

			// spring base enforcement
			translate([17.15, -nema17_width / 2 + 4, .25])
				rotate([0, 90, 0])
					cylinder(r = 3.75, h = 4, $fn = 32);
		}

		translate([offset + 11 - pre_tension, 0, bearing_bottom])
			difference()
			{
				// bearing spare out
				cylinder(r = 11.5, h = 60, $fn = 32);

				// bearing mount
				cylinder(r = 4 - extra_radius, h = 7.5, $fn = 32);

				// bearing mount base
				cylinder(r = 4 - extra_radius + 1, h = 0.5, $fn = 32);
			}

		// bearing mount hole
		translate([offset + 11 - pre_tension, 0, 0])
			cylinder(r = 2.5, h = 50, center = true, $fn = 32);

		// tensioner bolt slot
		translate([17.15, -nema17_width / 2 + 4, .25])
			rotate([0, 90, 0])
				rounded_slot(r = m3_wide_radius, h = 50, l = 1.5, center = true, $fn = 32);

		// fastener cutout
		translate([offset - 18.85 + gap, -20 ,0])
			cylinder(r = 27, h = height + 2 * epsilon, center = true, $fn = 32);

		// mounting hole
		translate([15.5, 15.5, 0])
		{
			cylinder(r = m3_wide_radius, h = height * 4, center = true, $fn = 16);
			cylinder(r = m3_head_radius, h = height + epsilon, $fn = 16);
		}

	}

	translate([offset + 11 - pre_tension, 0, filament_offset[2] - base_height])
		%bearing_608zz();
}


// new idler with 608 bearing
module idler_608_v2()
{
	// settings
	width = nema17_width;
	height = filament_offset[2] - base_height + 4;
	edge_radius = 27;
	hole_offsets = [-width / 2 + 4, width / 2 - 4];
	bearing_bottom = filament_offset[2] / 2 - base_height / 2 - 6;
	offset = drive_gear_hobbed_radius - drive_gear_tooth_depth + filament_diameter;
	pre_tension = 0.25;
	gap = 1;
	top = 2;

	// base plate
	translate([0, 0, height / 2])
	difference()
	{
		union()
		{
			// base
			translate([0, 0, top / 2])
			intersection()
			{
				cube([width, width, height + top], center = true);
				translate([0, 0, 0])
					cylinder(r = edge_radius, h = height + top + 2 * epsilon, $fn = 128, center = true);
				translate([offset + 12 + gap, 0, 0])
					cube([15, nema17_width + epsilon, height + top], center = true);
			}

			// bearing foot enforcement
			translate([offset + 11 - pre_tension, 0, -height / 2])
				cylinder(r = 4 - extra_radius + 1, h = height - .5, $fn = 32);

			// spring base enforcement
			translate([17.15, -nema17_width / 2 + 4, .25])
				rotate([0, 90, 0])
					cylinder(r = 3.75, h = 4, $fn = 32);
		}

		translate([offset + 11 - pre_tension, 0, bearing_bottom])
			difference()
			{
				// bearing spare out
				cylinder(r = 11.5, h = 8, $fn = 32);

				// bearing mount
				cylinder(r = 4 - extra_radius, h = 8, $fn = 32);

				// bearing mount base
				cylinder(r = 4 - extra_radius + 1, h = 0.5, $fn = 32);

				// bearing mount top
				translate([0, 0, 7.5])
					cylinder(r = 4 - extra_radius + 1, h = 0.5, $fn = 32);
			}

		// bearing mount hole
		translate([offset + 11 - pre_tension, 0, 0])
			cylinder(r = 2.5, h = 50, center = true, $fn = 32);

		// tensioner bolt slot
		translate([17.15, -nema17_width / 2 + 4, .25])
			rotate([0, 90, 0])
				rounded_slot(r = m3_wide_radius, h = 50, l = 1.5, center = true, $fn = 32);

		// fastener cutout
		translate([offset - 18.85 + gap, -20, top / 2])
			cylinder(r = 27, h = height + top + 2 * epsilon, center = true, $fn = 32);

		// mounting hole
		translate([15.5, 15.5, 0])
		{
			cylinder(r = m3_wide_radius, h = height * 4, center = true, $fn = 16);
			translate([0, 0, height / 2 + top - 4])
				cylinder(r = m3_head_radius, h = height + epsilolength/8 + epsilonn, $fn = 16);
		}

	}

	translate([offset + 11 - pre_tension, 0, filament_offset[2] - base_height])
		%bearing_608zz();
}


// new idler splitted in printable parts
module idler_608_v2_splitted()
{

	intersection()
	{
		idler_608_v2();
		cube([nema17_width, nema17_width, 17.25 - base_height], center = true);
	}

	translate([nema17_width + 8, 0, filament_offset[2] - base_height + 4 + 2])
		rotate([0, 180, 0])
			difference()
			{
				idler_608_v2();
				cube([nema17_width + 2, nema17_width + 2, 17.25 - base_height], center = true);
			}

}


// compose all parts
module compact_extruder()
{
	// motor plate
	nema17_mount();

	// mounting plate
	translate([-nema17_width / 2 + 1, 0, 0])
        flat_frame_mount();

	// filament inlet/outlet
	translate([filament_offset[0], 0, base_height - epsilon])
		filament_tunnel();

	// drive gear
	color("grey")
		%translate([0, 0, base_height/2 ])
			drive_gear();

	// filament
	color("red",0.3)
		%translate(filament_offset - [0, 0, epsilon])
			rotate([90, 0, 0])
				cylinder(r = filament_diameter / 2, h = 100, $fn = 16, center = true);

    // idler (installed)
	color("orange", 0.3)
        translate([0, 0, base_height+0.2])
            %idler_608_v1();

}


compact_extruder();

translate([20, 0, 0])
	idler_608_v1();

//translate([20, 0, 0])
//	idler_608_v2_splitted();