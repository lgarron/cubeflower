include <./node_modules/scad/duplicate_and_mirror.scad>
include <./node_modules/scad/minkowski_shell.scad>
include <./node_modules/scad/round_bevel.scad>
include <./node_modules/scad/small_hinge.scad>

/*

## (v0.2.0 TODO)

- Decompose into multiple parts that can be swapped out for differently sized cubes / when there is wear

## (v0.1.4 TODO)

- Set the hinge to 7.5mm scale, include two mid-bars and three gear sections.
- Add rails to help keep the inner stand level.
- Add plugs and ports compatible with Moyu box stacking (and also match the height and width?)
- Snug/soft top corner cube holders (similar to Sebestény cube box corners)?
- Interlocking or clasping top
  - Support a spring-loaded release?

## v0.1.3

- Scale the cube edge length from 28mm to 56mm
- Scale clearances (including in hinge).
- Add a little extra clearance inside.

## v0.1.2

- Add lids

## v0.1.1

- Adjust clearances for vertical printing.

*/

CUBE_EDGE_LENGTH = 28; // 6mm scale bucolic cube frame
// CUBE_EDGE_LENGTH = 56; // YS3M

$fn = 90;

DEFAULT_CLEARANCE = 0.1;

LARGE_VALUE = 200;

INNER_STAND_BASE_THICKNESS = 2;
INNER_STAND_LIP_THICKNESS = 1;
INNER_STAND_LIP_HEIGHT = 3.5;
INNER_STAND_FLOOR_ELEVATION = INNER_STAND_BASE_THICKNESS - INNER_STAND_LIP_THICKNESS;

module main_cube()
{
    translate([ 0, 0, CUBE_EDGE_LENGTH / 2 ]) cube(CUBE_EDGE_LENGTH, center = true);
};
module main_cube_on_stand()
{
    translate([ 0, 0, INNER_STAND_FLOOR_ELEVATION ]) main_cube();
};

HINGE_GEAR_OUTER_RADIUS = 6.4 / 2;

OUTER_SHELL_INNER_WIDTH = CUBE_EDGE_LENGTH + INNER_STAND_LIP_THICKNESS * 2;

// translate([ 0, -CUBE_EDGE_LENGTH / 2 + 5 - INNER_STAND_LIP_THICKNESS, 0.5 ]) cube([ 10, 10, 1 ], center = true);

// round_bevel_complement(20, 10, center_z = true);

BASE_EXTRA_HEIGHT_FOR_GEARS = 0.7;
BASE_HEIGHT = __SMALL_HINGE__THICKNESS + BASE_EXTRA_HEIGHT_FOR_GEARS;

BASE_LATTICE_OFFSET = __SMALL_HINGE__THICKNESS + DEFAULT_CLEARANCE * 2;
BASE_LATTICE_COMPLEMENT_OFFSET = __SMALL_HINGE__THICKNESS - DEFAULT_CLEARANCE * 2;

OUTER_SHELL_THICKNESS = 1;

OPENING_ANGLE_EACH_SIDE = 45;

module rotate_opening_angle()
{
    translate([ __SMALL_HINGE__THICKNESS / 2, 0, -__SMALL_HINGE__THICKNESS / 2 ])
        rotate([ 0, OPENING_ANGLE_EACH_SIDE, 0 ])
            translate([ -__SMALL_HINGE__THICKNESS / 2, 0, __SMALL_HINGE__THICKNESS / 2 ]) children();
}

module rotate_opening_angle_left()
{
    translate([ -__SMALL_HINGE__THICKNESS / 2, 0, -__SMALL_HINGE__THICKNESS / 2 ])
        rotate([ 0, -OPENING_ANGLE_EACH_SIDE, 0 ])
            translate([ __SMALL_HINGE__THICKNESS / 2, 0, __SMALL_HINGE__THICKNESS / 2 ]) children();
}

module lat(i, mirror_scale)
{
    scale([ mirror_scale, 1, 1 ]) translate([
        BASE_LATTICE_COMPLEMENT_OFFSET - _EPSILON, i * 4 + 1 + mirror_scale - DEFAULT_CLEARANCE, -BASE_HEIGHT - _EPSILON
    ])
        cube([
            OUTER_SHELL_INNER_WIDTH / 2 + OUTER_SHELL_THICKNESS + _EPSILON - BASE_LATTICE_COMPLEMENT_OFFSET +
                2 * _EPSILON,
            2 + DEFAULT_CLEARANCE * 2, BASE_EXTRA_HEIGHT_FOR_GEARS * 2 + _EPSILON +
            DEFAULT_CLEARANCE
        ]);
}

module lats()
{

    for (i = [-5:5])
    {
        rotate_opening_angle() lat(i, 1);
        rotate_opening_angle_left() lat(i, -1);
    }
}

// % minkowski()
// {
// % union()
// {
//     translate([ 0, -OUTER_SHELL_INNER_WIDTH / 2, -BASE_HEIGHT ])
//         cube([ OUTER_SHELL_INNER_WIDTH / 2, OUTER_SHELL_INNER_WIDTH, OUTER_SHELL_INNER_WIDTH + BASE_HEIGHT ]);
// }
//     sphere(INNER_STAND_LIP_THICKNESS);
// }

HALF_LID_EXTRA_HEIGHT = 1;

HALF_LID_R_W = CUBE_EDGE_LENGTH / 2 - __SMALL_HINGE__THICKNESS / 2;
HALF_LID_R_H = HALF_LID_EXTRA_HEIGHT + CUBE_EDGE_LENGTH + INNER_STAND_FLOOR_ELEVATION + __SMALL_HINGE__THICKNESS / 2;
HALF_LID_R = sqrt(pow(HALF_LID_R_W, 2) + pow(HALF_LID_R_H, 2));

LIP_R_W = OUTER_SHELL_INNER_WIDTH / 2 - __SMALL_HINGE__THICKNESS / 2;
LIP_R_H = INNER_STAND_LIP_HEIGHT + INNER_STAND_FLOOR_ELEVATION + __SMALL_HINGE__THICKNESS / 2;
LIP_R = sqrt(pow(LIP_R_W, 2) + pow(LIP_R_H, 2));

scale(2) union()
{
    difference()
    {
        translate([ 0, 0, INNER_STAND_LIP_THICKNESS ]) difference()
        {
            minkowski()
            {
                main_cube();
                sphere(INNER_STAND_LIP_THICKNESS - DEFAULT_CLEARANCE);
            }

            main_cube_on_stand();
            translate([ 0, 0, LARGE_VALUE / 2 + INNER_STAND_LIP_HEIGHT ]) cube(LARGE_VALUE, center = true);
        }

        duplicate_and_mirror() duplicate_and_mirror([ 0, 1, 0 ])
            translate([ __SMALL_HINGE__THICKNESS / 2, -OUTER_SHELL_INNER_WIDTH / 2, -__SMALL_HINGE__THICKNESS / 2 ])
                rotate([ -90, 0, 0 ]) cylinder(h = 10 - __SMALL_HINGE__GEAR_OFFSET_HEIGHT, r = HINGE_GEAR_OUTER_RADIUS);
    }

    translate([ 0, 0, 0.5 ]) cube([ 8, 8, 1 ], center = true);

    difference()
    {
        render() union()
        {
            duplicate_and_mirror() rotate_opening_angle() union()
            {
                translate([ BASE_LATTICE_OFFSET, -OUTER_SHELL_INNER_WIDTH / 2, -BASE_HEIGHT ])
                    cube([ OUTER_SHELL_INNER_WIDTH / 2 - BASE_LATTICE_OFFSET, OUTER_SHELL_INNER_WIDTH, BASE_HEIGHT ]);

                duplicate_and_mirror([ 0, 1, 0 ]) translate([ __SMALL_HINGE__THICKNESS, 5, -BASE_HEIGHT ]) cube([
                    OUTER_SHELL_INNER_WIDTH / 2 - __SMALL_HINGE__THICKNESS, OUTER_SHELL_INNER_WIDTH / 2 - 5,
                    BASE_HEIGHT
                ]);
            }

            rotate([ 90, 0, 0 ]) translate([ 0, -__SMALL_HINGE__THICKNESS, -15 ])
                small_hinge_30mm(rotate_angle_each_side = OPENING_ANGLE_EACH_SIDE, main_clearance_scale = 0.5,
                                 plug_clearance_scale = 1, round_far_side = true, shave_middle = false);
        }
        lats();
    }

    difference()
    {
        duplicate_and_mirror() rotate_opening_angle() difference()
        {
            minkowski_shell()
            {
                union()
                {
                    difference()
                    {
                        translate([ __SMALL_HINGE__THICKNESS / 2, 0, -__SMALL_HINGE__THICKNESS / 2 ])
                            rotate([ 90, 0, 0 ]) cylinder(h = CUBE_EDGE_LENGTH, r = HALF_LID_R, center = true);

                        translate([ LARGE_VALUE / 2 + CUBE_EDGE_LENGTH / 2, 0, 0 ])
                            cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], center = true);
                        translate([ -LARGE_VALUE / 2 + __SMALL_HINGE__THICKNESS / 2, 0, 0 ])
                            cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], center = true);
                        translate([ 0, 0, -LARGE_VALUE / 2 + INNER_STAND_FLOOR_ELEVATION ])
                            cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], center = true);
                    }

                    translate([ 0, -CUBE_EDGE_LENGTH / 2, INNER_STAND_FLOOR_ELEVATION ]) cube([
                        __SMALL_HINGE__THICKNESS / 2, CUBE_EDGE_LENGTH,
                        HALF_LID_R - INNER_STAND_FLOOR_ELEVATION - __SMALL_HINGE__THICKNESS / 2
                    ]);

                    translate([ 0, -OUTER_SHELL_INNER_WIDTH / 2, OUTER_SHELL_THICKNESS - BASE_HEIGHT ]) cube([
                        OUTER_SHELL_INNER_WIDTH / 2, OUTER_SHELL_INNER_WIDTH,
                        LIP_R - __SMALL_HINGE__THICKNESS / 2 + BASE_HEIGHT -
                        OUTER_SHELL_THICKNESS
                    ]);
                }
                sphere(OUTER_SHELL_THICKNESS);
            }
            translate([ -LARGE_VALUE / 2, 0, 0 ]) cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], center = true);

            translate([
                -BASE_LATTICE_OFFSET, -(OUTER_SHELL_INNER_WIDTH + 2 * OUTER_SHELL_THICKNESS) / 2, -BASE_HEIGHT -
                _EPSILON
            ])
                cube([
                    BASE_LATTICE_OFFSET * 2, OUTER_SHELL_INNER_WIDTH + 2 * OUTER_SHELL_THICKNESS,
                    BASE_EXTRA_HEIGHT_FOR_GEARS +
                    _EPSILON
                ]);
            translate([ -BASE_LATTICE_OFFSET, -(OUTER_SHELL_INNER_WIDTH) / 2, -BASE_HEIGHT - _EPSILON ])
                cube([ BASE_LATTICE_OFFSET * 2, OUTER_SHELL_INNER_WIDTH, BASE_HEIGHT + _EPSILON ]);

            translate([ 0, 0, -__SMALL_HINGE__THICKNESS ]) rotate([ 90, 0, 0 ])
                round_bevel_complement(height = OUTER_SHELL_INNER_WIDTH + 2 * OUTER_SHELL_THICKNESS + 2 * _EPSILON,
                                       radius = __SMALL_HINGE__THICKNESS / 2, center_z = true);
        }

        lats();
    }
}

// translate([ __SMALL_HINGE__THICKNESS / 2, 0, -__SMALL_HINGE__THICKNESS / 2 ]) rotate([ 90, 0, 0 ])
//     cylinder(h = OUTER_SHELL_INNER_WIDTH + 2 * OUTER_SHELL_THICKNESS + 2 * _EPSILON, r = __SMALL_HINGE__THICKNESS /
//     2,
//  center = true);

// main_cube_on_stand();

// translate([ 0, 0, 1 + INNER_STAND_THICKNESS ]) difference()
// {
//     minkowski()
//     {
//         cube([CUBE_EDGE_LENGTH + ]);
//         cylinder(h = 1, r = r);
//         (INNER_STAND_THICKNESS); t
//     }

//     main_cube();
//     translate([ 0, 0, LARGE_VALUE/2 + INNER_STAND_LIP_HEIGHT ]) cube(LARGE_VALUE, center = true);
// }
