include <./node_modules/scad/duplicate_and_mirror.scad>
include <./node_modules/scad/round_bevel.scad>
include <./node_modules/scad/small_hinge.scad>

CUBE_WIDTH = 28; // 6mm scale bucolic cube
// CUBE_WIDTH = 55; // YS3M

$fn = 90;

module main_cube()
{
    translate([ 0, 0, CUBE_WIDTH / 2 ]) cube(CUBE_WIDTH, center = true);
};

DEFAULT_CLEARANCE = 0.1;

INNER_STAND_BASE_THICKNESS = 2;
INNER_STAND_LIP_THICKNESS = 1;
INNER_STAND_LIP_HEIGHT = 2;

difference()
{
    translate([ 0, 0, INNER_STAND_LIP_THICKNESS ]) difference()
    {
        minkowski()
        {
            main_cube();
            sphere(INNER_STAND_LIP_THICKNESS - DEFAULT_CLEARANCE);
        }

        translate([ 0, 0, INNER_STAND_BASE_THICKNESS - INNER_STAND_LIP_THICKNESS ]) main_cube();
        translate([ 0, 0, 50 + INNER_STAND_LIP_HEIGHT ]) cube(100, center = true);
    }

    duplicate_and_mirror()
        translate([ __SMALL_HINGE__THICKNESS / 2, -OUTER_SHELL_INNER_WIDTH / 2, -__SMALL_HINGE__THICKNESS / 2 ])
            rotate([ -90, 0, 0 ]) cylinder(h = 10 - __SMALL_HINGE__GEAR_OFFSET_HEIGHT, r = HINGE_GEAR_OUTER_RADIUS);
}

HINGE_GEAR_OUTER_RADIUS = 6.4 / 2;

OUTER_SHELL_INNER_WIDTH = CUBE_WIDTH + INNER_STAND_LIP_THICKNESS * 2;

// translate([ 0, -CUBE_WIDTH / 2 + 5 - INNER_STAND_LIP_THICKNESS, 0.5 ]) cube([ 10, 10, 1 ], center = true);

// round_bevel_complement(20, 10, center_z = true);

translate([ 0, 0, 0.5 ]) cube([ 8, 8, 1 ], center = true);

BASE_EXTRA_HEIGHT_FOR_GEARS = 0.7;
BASE_HEIGHT = __SMALL_HINGE__THICKNESS + BASE_EXTRA_HEIGHT_FOR_GEARS;

BASE_LATTICE_OFFSET = __SMALL_HINGE__THICKNESS;
BASE_LATTICE_COMPLEMENT_OFFSET = BASE_LATTICE_OFFSET - 0.5;

OUTER_SHELL_THICKNESS = 2;

module lat(i, mirror_scale)
{
    scale([ mirror_scale, 1, 1 ])
        translate([ BASE_LATTICE_COMPLEMENT_OFFSET - _EPSILON, i * 4 + 1 + mirror_scale, -BASE_HEIGHT - _EPSILON ])
            cube([
                OUTER_SHELL_INNER_WIDTH / 2 - BASE_LATTICE_COMPLEMENT_OFFSET + 2 * _EPSILON, 2.05,
                BASE_EXTRA_HEIGHT_FOR_GEARS * 2 + _EPSILON +
                DEFAULT_CLEARANCE
            ]);
}

difference()
{
    render() union()
    {
        duplicate_and_mirror() union()
        {
            translate([ __SMALL_HINGE__THICKNESS, -OUTER_SHELL_INNER_WIDTH / 2, -BASE_HEIGHT ])
                cube([ OUTER_SHELL_INNER_WIDTH / 2 - __SMALL_HINGE__THICKNESS, OUTER_SHELL_INNER_WIDTH, BASE_HEIGHT ]);
            translate([ BASE_LATTICE_OFFSET, -OUTER_SHELL_INNER_WIDTH / 2, -BASE_HEIGHT ]) cube([
                OUTER_SHELL_INNER_WIDTH / 2 - BASE_LATTICE_OFFSET, OUTER_SHELL_INNER_WIDTH, BASE_HEIGHT -
                __SMALL_HINGE__THICKNESS
            ]);
        }

        rotate([ 90, 0, 0 ]) translate([ 0, -__SMALL_HINGE__THICKNESS, -15 ]) small_hinge_30mm(round_far_side = true);
    }

    for (i = [-5:5])
    {
        lat(i, 1);
        lat(i, -1);
    }
}

// minkowski()
// {
//     cube(OUTER_SHELL_INNER_WIDTH + CLEARANCE);
//     sphere(INNER_STAND_LIP_THICKNESS);
// }

// translate([ 0, 0, 1 + INNER_STAND_THICKNESS ]) difference()
// {
//     minkowski()
//     {
//         cube([CUBE_WIDTH + ]);
//         cylinder(h = 1, r = r);
//         (INNER_STAND_THICKNESS);
//     }

//     main_cube();
//     translate([ 0, 0, 50 + INNER_STAND_LIP_HEIGHT ]) cube(100, center = true);
// }
