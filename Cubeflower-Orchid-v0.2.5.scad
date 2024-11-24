DESIGN_VARIANT_TEXT = "ORCHID";
VERSION_TEXT = "v0.2.5";
OPENING_ANGLE_EACH_SIDE = 75; // Avoid setting to 0 for printing unless you want overly shaved lids
DEBUG = false;
INCLUDE_INNER_STAND_ENGRAVING = false;
PRINT_IN_PLACE = true;

INCLUDE_SOLID_INFILL_SHAPE = true;
INCLUDE_SUPPORT_BLOCKER_SHAPE = true;

MAIN_SCALE = 1;
CUBE_EDGE_LENGTH = 57; // mm

INNER_STAND_ENGRAVING_FILE = "./archived/engraving/engraving.svg";

SET_ON_SIDE_FOR_PRINTING = !DEBUG && PRINT_IN_PLACE;

$fn = DEBUG ? 64 : 90;
LID_TOP_FN = DEBUG ? 64 : 360;

include <./node_modules/scad/duplicate.scad>
include <./node_modules/scad/minkowski_shell.scad>
include <./node_modules/scad/round_bevel.scad>
include <./node_modules/scad/small_hinge.scad>

/*

## v0.2.5

- Include solid infill shape.

## v0.2.4

- Add design variant engraving.
- Allow the inner stand to be printed separately.
- Adjust `difference(…)` calculations to work at 90 degrees.

## v0.2.3

- Move the inner stand clearance to the inside and increase to 0.25mm.
- Decrease engraving depth.
- Increase lat clearance for lower-friction end motion.
- Add a rounded bottom side to test push-down closing.
- Add thumb divots to the lid tops.

## v0.2.2

- Restore clearance for the inner stand.

## v0.2.1

- Fix 180° rotational symmetry for the hinge gears.

## v0.2.0

- Slim the gears to 5mm scale to decrease the box height.

## v0.1.6

- Make the hinge gears rotationally symmetrical to allow box bottoms to be stacked in either orientation.
- Shave hinge blocks and lids.
- Add version engraving.
- Add `SET_ON_SIDE_FOR_PRINTING` parameter.
- Add an optional inner stand engraving.

## v0.1.5

- Lower the shell for the stand.

## v0.1.4

(Abandoned.)

## v0.1.3

- Scale the cube edge length from 28mm to 56mm
- Scale clearances (including in hinge).
- Add a little extra clearance inside.

## v0.1.2

- Add lids

## v0.1.1

- Adjust clearances for vertical printing.

*/

INTERNAL_MAIN_SCALE = MAIN_SCALE;
INTERNAL_CUBE_EDGE_LENGTH = CUBE_EDGE_LENGTH; // YS3M

HINGE_THICKNESS = 5;

DEFAULT_CLEARANCE = 0.1;
MAIN_CLEARANCE_SCALE = 0.5;
SLIDING_CLEARANCE = 0.2;

INNER_STAND_CLEARANCE = 0.25;

LARGE_VALUE = 200;

INNER_STAND_BASE_THICKNESS = 1.5;
INNER_STAND_LIP_THICKNESS = 1.5;
INNER_STAND_LIP_HEIGHT = 8;
INNER_STAND_FLOOR_ELEVATION = INNER_STAND_BASE_THICKNESS;

ENGRAVING_LEVEL_DEPTH = 0.15;

LAT_WIDTH = 4;

OUTER_SHELL_THICKNESS = 1.5;

module main_cube()
{
    translate([ 0, 0, INTERNAL_CUBE_EDGE_LENGTH / 2 ]) cube(INTERNAL_CUBE_EDGE_LENGTH, center = true);
};
module main_cube_on_stand()
{
    translate([ 0, 0, INNER_STAND_FLOOR_ELEVATION ]) main_cube();
};

HINGE_GEAR_OUTER_RADIUS = 6.4 / 5 * HINGE_THICKNESS / 2;

OUTER_SHELL_INNER_WIDTH = INTERNAL_CUBE_EDGE_LENGTH + INNER_STAND_LIP_THICKNESS * 2;
OUTER_SHELL_OUTER_WIDTH = OUTER_SHELL_INNER_WIDTH + 2 * OUTER_SHELL_THICKNESS;

BASE_EXTRA_HEIGHT_FOR_GEARS =
    1.4 / 5 * HINGE_THICKNESS / 2; // This is slightly less than the gears stick out, but the impact is negligible.
BASE_HEIGHT = HINGE_THICKNESS + BASE_EXTRA_HEIGHT_FOR_GEARS;

BASE_LATTICE_OFFSET = HINGE_THICKNESS + DEFAULT_CLEARANCE * 2;
BASE_LATTICE_COMPLEMENT_OFFSET = HINGE_THICKNESS - DEFAULT_CLEARANCE;

module rotate_opening_angle()
{
    translate([ HINGE_THICKNESS / 2, 0, -HINGE_THICKNESS / 2 ]) rotate([ 0, OPENING_ANGLE_EACH_SIDE, 0 ])
        translate([ -HINGE_THICKNESS / 2, 0, HINGE_THICKNESS / 2 ]) children();
}

module rotate_opening_angle_left()
{
    translate([ -HINGE_THICKNESS / 2, 0, -HINGE_THICKNESS / 2 ]) rotate([ 0, -OPENING_ANGLE_EACH_SIDE, 0 ])
        translate([ HINGE_THICKNESS / 2, 0, HINGE_THICKNESS / 2 ]) children();
}

module lat(i, mirror_scale)
{
    scale([ mirror_scale, 1, 1 ]) translate([
        BASE_LATTICE_COMPLEMENT_OFFSET - _EPSILON,
        i * LAT_WIDTH * 2 + LAT_WIDTH / 2 + mirror_scale * LAT_WIDTH / 2 - SLIDING_CLEARANCE, -BASE_HEIGHT -
        _EPSILON
    ])
        cube([
            OUTER_SHELL_INNER_WIDTH / 2 + OUTER_SHELL_THICKNESS + _EPSILON - BASE_LATTICE_COMPLEMENT_OFFSET +
                2 * _EPSILON,
            LAT_WIDTH + SLIDING_CLEARANCE * 2, BASE_EXTRA_HEIGHT_FOR_GEARS * 2 + _EPSILON +
            DEFAULT_CLEARANCE
        ]);
}

module right_lats()
{
    render() union()
    {
        for (i = [-5:5])
        {
            lat(i, 1);
        }
    }
}
module left_lats()
{
    render() union()
    {
        for (i = [-5:5])
        {
            lat(i, -1);
        }
    }
}

module debug_quarter_negative()
{
    if (DEBUG)
    {

        translate([ -LARGE_VALUE / 2, 0, 0 ]) cube(LARGE_VALUE, center = true); // TODO
        translate([ 0, -LARGE_VALUE / 2, 0 ]) cube(LARGE_VALUE, center = true); // TODO
    }
}

module lid_part(w, d, h)
{

    lid_radius_w = w - HINGE_THICKNESS / 2;
    lid_radius_h = h + INNER_STAND_FLOOR_ELEVATION + HINGE_THICKNESS / 2;
    lid_radius = sqrt(pow(lid_radius_w, 2) + pow(lid_radius_h, 2));

    difference()
    {
        translate([ HINGE_THICKNESS / 2, 0, -HINGE_THICKNESS / 2 ]) rotate([ 90, 0, 0 ])
            cylinder(h = d, r = lid_radius, center = true, $fn = LID_TOP_FN);

        translate([ LARGE_VALUE / 2 + w, 0, 0 ]) cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], center = true);
        translate([ -LARGE_VALUE / 2 + HINGE_THICKNESS / 2, 0, 0 ])
            cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], center = true);
        translate([ 0, 0, -LARGE_VALUE / 2 + INNER_STAND_FLOOR_ELEVATION ])
            cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], center = true);
    }

    translate([ 0, -d / 2, INNER_STAND_FLOOR_ELEVATION ])
        cube([ HINGE_THICKNESS / 2, d, lid_radius - lid_radius_h + h ]);
}

VERSTION_TEXT_ENGRAVING_DEPTH = 0.25;

module engraving_text(text_string, _epsilon, halign = "center")
{
    translate([ 0, 0, -VERSTION_TEXT_ENGRAVING_DEPTH ]) linear_extrude(VERSTION_TEXT_ENGRAVING_DEPTH + _epsilon)
        text(text_string, size = 2, font = "Ubuntu:style=bold", valign = "center", halign = halign);
}

BOTTOM_ROUNDING_RADIUS = 10;

module bottom_rounding_negative()
{
    // TODO: make this work
    render() difference()
    {
        translate([
            OUTER_SHELL_INNER_WIDTH / 2 + OUTER_SHELL_THICKNESS - BOTTOM_ROUNDING_RADIUS,
            -(OUTER_SHELL_INNER_WIDTH + 2 * OUTER_SHELL_THICKNESS + 2 * _EPSILON) / 2, -BASE_HEIGHT -
            _EPSILON
        ])
            cube([
                BOTTOM_ROUNDING_RADIUS + _EPSILON, OUTER_SHELL_INNER_WIDTH + 2 * OUTER_SHELL_THICKNESS + 2 * _EPSILON,
                BOTTOM_ROUNDING_RADIUS +
                _EPSILON
            ]);

        minkowski()
        {
            translate(
                [ OUTER_SHELL_INNER_WIDTH / 2, OUTER_SHELL_INNER_WIDTH / 2, -BASE_HEIGHT + OUTER_SHELL_THICKNESS ])
                rotate([ 90, -90, 0 ])
                    round_bevel_cylinder(OUTER_SHELL_INNER_WIDTH, BOTTOM_ROUNDING_RADIUS - OUTER_SHELL_THICKNESS);
            sphere(OUTER_SHELL_THICKNESS);
        }
    }
}

THUMB_DIVOT_RADIUS = 20;
THUMB_DIVOT_DEPTH = 0.75;
THUMB_DIVOT_X = CUBE_EDGE_LENGTH * 0.35;
THUMB_DIVOT_Y = INNER_STAND_FLOOR_ELEVATION + CUBE_EDGE_LENGTH * 0.92;

HINGE_CONNECTOR_ALIGNMENT_EXTRA_HEIGHT = 0.4;
HINGE_CONNECTOR_ALIGNMENT_STUB_WIDTH = 5;

module hinge_connector(horizontal_clearance = 0, vertical_clearance = 0)
{
    difference()
    {
        duplicate_and_mirror([ 0, 1, 0 ]) translate([
            -HINGE_THICKNESS - horizontal_clearance, 10 + __SMALL_HINGE__PLUG_VERTICAL_CLEARANCE - horizontal_clearance,
            -HINGE_THICKNESS / 2
        ])
            cube([
                HINGE_THICKNESS * 2 + 2 * horizontal_clearance,
                10 - 2 * __SMALL_HINGE__PLUG_VERTICAL_CLEARANCE + 2 * horizontal_clearance,
                HINGE_THICKNESS / 2 + INNER_STAND_CLEARANCE + HINGE_CONNECTOR_ALIGNMENT_EXTRA_HEIGHT +
                vertical_clearance
            ]);
        duplicate_and_mirror([ 0, 1, 0 ]) translate([
            -HINGE_CONNECTOR_ALIGNMENT_STUB_WIDTH / 2 + horizontal_clearance,
            15 + -HINGE_CONNECTOR_ALIGNMENT_STUB_WIDTH / 2 + horizontal_clearance,
            INNER_STAND_CLEARANCE
        ])
            cube([
                HINGE_CONNECTOR_ALIGNMENT_STUB_WIDTH - horizontal_clearance * 2,
                HINGE_CONNECTOR_ALIGNMENT_STUB_WIDTH - horizontal_clearance * 2,
                HINGE_CONNECTOR_ALIGNMENT_EXTRA_HEIGHT + vertical_clearance +
                _EPSILON
            ]);
    }
}

module inner_stand()
{

    render() difference()
    {
        render() difference()
        {
            minkowski()
            {
                main_cube();
                translate([ 0, 0, INNER_STAND_LIP_THICKNESS ])
                    sphere(INNER_STAND_LIP_THICKNESS - INNER_STAND_CLEARANCE);
            }

            main_cube_on_stand();
            translate([ 0, 0, LARGE_VALUE / 2 + INNER_STAND_FLOOR_ELEVATION + INNER_STAND_LIP_HEIGHT ])
                cube(LARGE_VALUE, center = true);

            if (!PRINT_IN_PLACE)
            {
                hinge_connector(horizontal_clearance = 0.05, vertical_clearance = 0.05);
            }
        }

        duplicate_and_mirror() duplicate_and_mirror([ 0, 1, 0 ])
            duplicate_and_translate([ 0, -OUTER_SHELL_INNER_WIDTH / 2, 0 ])
                translate([ HINGE_THICKNESS / 2, 0, -HINGE_THICKNESS / 2 ]) rotate([ -90, 0, 0 ]) difference()
        {
            cylinder(h = 10 - __SMALL_HINGE__GEAR_OFFSET_HEIGHT, r = HINGE_GEAR_OUTER_RADIUS);
            translate([ LARGE_VALUE / 2 + DEFAULT_CLEARANCE, 0, 0 ]) cube(LARGE_VALUE, center = true);
        }

        if (INCLUDE_INNER_STAND_ENGRAVING)
        {
            render() union()
            {
                render() translate([ 0, 0, INNER_STAND_FLOOR_ELEVATION + _EPSILON - ENGRAVING_LEVEL_DEPTH * 2 ])
                    linear_extrude(ENGRAVING_LEVEL_DEPTH * 2 + _EPSILON) scale(MAIN_SCALE / INTERNAL_MAIN_SCALE)
                        import(INNER_STAND_ENGRAVING_FILE, dpi = 25.4, center = true);
            }
        }

        debug_quarter_negative();
    }
}

module duplicate_and_mirror_with_corresponding_lats_and_bottom_rounding_difference()
{
    rotate_opening_angle() difference()
    {
        children();
        right_lats();
        bottom_rounding_negative();
    }
    rotate_opening_angle_left() difference()
    {
        mirror([ 1, 0, 0 ]) children();
        left_lats();
        mirror([ 1, 0, 0 ]) bottom_rounding_negative();
    }
}

module hinge_core()
{

    rotate([ 90, 0, 0 ]) translate([ 0, -HINGE_THICKNESS, 0 ]) small_hinge_30mm(
        main_thickness = HINGE_THICKNESS, rotate_angle_each_side = OPENING_ANGLE_EACH_SIDE, main_clearance_scale = 0.5,
        plug_clearance_scale = 1, round_far_side = true, common_gear_offset = 0);

    rotate([ 90, 0, 0 ]) translate([ 0, -HINGE_THICKNESS, -30 ]) small_hinge_30mm(
        main_thickness = HINGE_THICKNESS, rotate_angle_each_side = OPENING_ANGLE_EACH_SIDE, main_clearance_scale = 0.5,
        plug_clearance_scale = 1, round_far_side = true, common_gear_offset = 0);
}

module hinge()
{

    difference()
    {
        render() union()
        {
            duplicate_and_mirror_with_corresponding_lats_and_bottom_rounding_difference()
            {
                union()
                {
                    translate([ BASE_LATTICE_OFFSET, -OUTER_SHELL_INNER_WIDTH / 2, -BASE_HEIGHT ]) cube(
                        [ OUTER_SHELL_INNER_WIDTH / 2 - BASE_LATTICE_OFFSET, OUTER_SHELL_INNER_WIDTH, BASE_HEIGHT ]);

                    duplicate_and_mirror([ 0, 1, 0 ]) translate([ HINGE_THICKNESS - _EPSILON, 5 + 15, -BASE_HEIGHT ])
                        cube([
                            BASE_LATTICE_OFFSET - HINGE_THICKNESS + _EPSILON, OUTER_SHELL_INNER_WIDTH / 2 - 5 - 15,
                            BASE_HEIGHT
                        ]);
                    duplicate_and_mirror([ 0, 1, 0 ]) translate([ HINGE_THICKNESS, 0, -BASE_HEIGHT ])
                        cube([ BASE_LATTICE_OFFSET - HINGE_THICKNESS + _EPSILON, 10, BASE_HEIGHT ]);
                }
            }

            hinge_core();
        };
        translate([ 0, -15, -HINGE_THICKNESS - _EPSILON ]) rotate([ 180, 0, 0 ]) rotate([ 0, 0, 90 ])
            resize([ 10 - 2, 0, VERSTION_TEXT_ENGRAVING_DEPTH ], auto = true) engraving_text(VERSION_TEXT, 0);
        translate([ 0, 15, -HINGE_THICKNESS - _EPSILON ]) rotate([ 180, 0, 0 ]) rotate([ 0, 0, 90 ])
            resize([ 10 - 2, 0, VERSTION_TEXT_ENGRAVING_DEPTH ], auto = true) engraving_text(DESIGN_VARIANT_TEXT, 0);

        debug_quarter_negative();
    }
}

// TODO: this value is exact, but there's probably a neater way to make this calculation come from arithmetic with
// places.
DEFAULT_CLEARANCE_FACTOR_FOR_LID_SHAVE_TO_MATCH_LATS_AT_90_DEGREES = 3;

module lids()
{

    difference()
    {

        render() duplicate_and_mirror_with_corresponding_lats_and_bottom_rounding_difference() difference()
        {
            union()
            {
                render() minkowski_shell()
                {
                    union()
                    {
                        lid_part(INTERNAL_CUBE_EDGE_LENGTH / 2, INTERNAL_CUBE_EDGE_LENGTH, INTERNAL_CUBE_EDGE_LENGTH);
                        lid_part(INTERNAL_CUBE_EDGE_LENGTH / 2 + INNER_STAND_LIP_THICKNESS,
                                 INTERNAL_CUBE_EDGE_LENGTH + INNER_STAND_LIP_THICKNESS * 2, INNER_STAND_LIP_HEIGHT);

                        translate([ 0, -OUTER_SHELL_INNER_WIDTH / 2, OUTER_SHELL_THICKNESS - BASE_HEIGHT ]) cube([
                            OUTER_SHELL_INNER_WIDTH / 2, OUTER_SHELL_INNER_WIDTH, BASE_HEIGHT +
                            INNER_STAND_FLOOR_ELEVATION
                        ]);
                    }

                    sphere(OUTER_SHELL_THICKNESS);
                }

                translate([ OUTER_SHELL_INNER_WIDTH / 2, OUTER_SHELL_INNER_WIDTH / 2, 0 ]) rotate([ 90, -90, 0 ])
                    round_bevel_complement(OUTER_SHELL_INNER_WIDTH, INNER_STAND_LIP_THICKNESS);
            }

            translate([ -LARGE_VALUE / 2, 0, 0 ]) cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], center = true);

            translate([
                -BASE_LATTICE_OFFSET, -(OUTER_SHELL_INNER_WIDTH + 2 * OUTER_SHELL_THICKNESS) / 2, -BASE_HEIGHT -
                _EPSILON
            ]) cube([ BASE_LATTICE_OFFSET * 2, OUTER_SHELL_OUTER_WIDTH, BASE_EXTRA_HEIGHT_FOR_GEARS + _EPSILON ]);
            translate([ -BASE_LATTICE_OFFSET, -(OUTER_SHELL_INNER_WIDTH) / 2, -BASE_HEIGHT - _EPSILON ])
                cube([ BASE_LATTICE_OFFSET * 2, OUTER_SHELL_INNER_WIDTH, BASE_HEIGHT + _EPSILON ]);

            translate([ 0, 0, -HINGE_THICKNESS ]) rotate([ 90, 0, 0 ])
                round_bevel_complement(height = OUTER_SHELL_INNER_WIDTH + 2 * OUTER_SHELL_THICKNESS + 2 * _EPSILON,
                                       radius = HINGE_THICKNESS / 2, center_z = true);

            duplicate_and_mirror([ 0, 1, 0 ]) translate([
                THUMB_DIVOT_X, -CUBE_EDGE_LENGTH / 2 - OUTER_SHELL_THICKNESS - THUMB_DIVOT_RADIUS + THUMB_DIVOT_DEPTH,
                THUMB_DIVOT_Y
            ]) sphere(THUMB_DIVOT_RADIUS);
        }

        translate([
            0, 0,
            LARGE_VALUE / 2 - BASE_LATTICE_COMPLEMENT_OFFSET -
                DEFAULT_CLEARANCE_FACTOR_FOR_LID_SHAVE_TO_MATCH_LATS_AT_90_DEGREES *
            DEFAULT_CLEARANCE
        ]) cube([ 2 * DEFAULT_CLEARANCE, LARGE_VALUE, LARGE_VALUE ], center = true);

        debug_quarter_negative();
    }
}

if (!PRINT_IN_PLACE)
{
    rotate([ SET_ON_SIDE_FOR_PRINTING ? -90 : 0, 0, 0 ]) scale(INTERNAL_MAIN_SCALE) union()
    {
        inner_stand();
    }
}

rotate([ SET_ON_SIDE_FOR_PRINTING ? -90 : 0, 0, 0 ]) scale(INTERNAL_MAIN_SCALE) union()
{
    if (DEBUG)
    {
        % main_cube_on_stand();
    }
    if (PRINT_IN_PLACE)
    {

        inner_stand();
    }
    hinge_connector();
    hinge();
    lids();
}

GEAR_SUPPORT_BLOCKER_EXTRA = 0.5;

if (INCLUDE_SOLID_INFILL_SHAPE && !DEBUG)
{
    rotate([ SET_ON_SIDE_FOR_PRINTING ? -90 : 0, 0, 0 ]) scale(INTERNAL_MAIN_SCALE) color("blue") union()
    {
        hinge_core();
        translate([ 0, 10, CUBE_EDGE_LENGTH * 1.25 ]) rotate([ 90, 0, 0 ]) linear_extrude(1)
            text("SOLID INFILL", size = 5, font = "Ubuntu:style=bold", valign = "center", halign = "center");
    }
}

if (INCLUDE_SUPPORT_BLOCKER_SHAPE && !DEBUG)
{
    rotate([ SET_ON_SIDE_FOR_PRINTING ? -90 : 0, 0, 0 ]) scale(INTERNAL_MAIN_SCALE) color("red") union()
    {
        // Gears
        translate([ 0, 0, -HINGE_THICKNESS / 2 - GEAR_SUPPORT_BLOCKER_EXTRA ]) cube(
            [
                HINGE_THICKNESS * 2 + 2 * GEAR_SUPPORT_BLOCKER_EXTRA, OUTER_SHELL_OUTER_WIDTH - _EPSILON * 2,
                HINGE_THICKNESS + 2 *
                GEAR_SUPPORT_BLOCKER_EXTRA
            ],
            center = true);
        // Engraving
        translate([ 0, 0, INNER_STAND_FLOOR_ELEVATION / 2 ])
            cube([ OUTER_SHELL_INNER_WIDTH, OUTER_SHELL_INNER_WIDTH, INNER_STAND_FLOOR_ELEVATION + _EPSILON ],
                 center = true);

        translate([ 0, 0, CUBE_EDGE_LENGTH * 1.25 ]) rotate([ 90, 0, 0 ]) linear_extrude(1)
            text("SUPPORT BLOCKER", size = 5, font = "Ubuntu:style=bold", valign = "center", halign = "center");
    }
}
