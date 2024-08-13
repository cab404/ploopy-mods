// decoupled width and height to accomodate sog and expansion better
// [4.6, 4.65, 4.7]


// used for generating top magnet retaining layer
layer_height = 0.2;


_old_offsets = [ -16, -9.5, -3.5, 3.5, 9.5, 16 ];
_new_offsets = [ -16.5, -9.5, -3.5, 3.5, 9.5, 16.5 ];
// Stock offsets are not correctly aligned to the coils. As I don't know the intention behind that, I leave an option to disable that.
use_fixed_offsets = true;
magnet_offsets = use_fixed_offsets ? _new_offsets : _old_offsets;

// How high are the magnets above the baseplate. Value you will experiment the most with. Adjusted later to 4.5 mm magnet height.
unadj_magnet_elevation = 1.6;
// How deep the magnet goes into the base
magnet_mount_lip = 0.4;
// Controls how much is cut from the top to get the mounts. Positive values yield full magnet enclosure.
magnet_mount_top = -0.1;

// Whether to generate a giant hole in the middle
open = false;

// How high is the base layer. Full height of the base is base_height + chamfer_height
base_height = 2;
chamfer_height = 1;
chamfer_angle = 20;

magnet_h = 4.5;  //4.5, 4.8
magnet_w = magnet_h + 0.15; //4.65, 4.95
magnet_length=28;
magnet_bevel = 0.6;

bottom_holder_scale = 0.9;
top_holder_scale = 0.8;

module endofparams() {} // so customizer doesn't see what's below


magnet_elevation = unadj_magnet_elevation + (4.5 - magnet_h);

outer_radius = 30;
mounting_hole_dst = 48;
mounting_hole_diam = 3.5;

module mounting_hole() {
    $fn=40;
    h = 30;
    render() // for better thrown-together view
    translate(v = [0,0,- h - (mounting_hole_diam/2)])
    union() {
        translate(v = [0,0,h + (mounting_hole_diam/2)])
        cylinder(h = h, r = mounting_hole_diam);
        translate(v = [0,0,h])
        linear_extrude(height = (mounting_hole_diam/2), scale=2)
        circle(r = mounting_hole_diam / 2);
        cylinder(h = h, r = mounting_hole_diam / 2);
    }
}

module base_outline() {
        let($fn=300)
        difference() {
            circle(r = outer_radius);
            for (i=[1,-1], j=[1,-1]) {
                translate(v = [33*i,33*j])
                circle(r = 20);
            }
        }
}

module base() {
    translate(v = [0,0,-(chamfer_height + base_height)])
    let($fn=300)
    union() {
        let(scl=tan(chamfer_angle))
        linear_extrude(height = chamfer_height, scale=outer_radius/(outer_radius - (chamfer_height*scl)))
        scale(v = (outer_radius - (chamfer_height*scl))/outer_radius)
        base_outline();
        translate(v = [0,0,chamfer_height])
        linear_extrude(height = base_height)
        base_outline();
    }
}

module magnet() {
    $fn=42;
    off = -(magnet_bevel*2);
    render()
    minkowski() {
        cube(center=true, size = [magnet_w+off, 28+off, magnet_h+off, ]);
        sphere(r = magnet_bevel);
    }
}

module raise(h) {
    translate(v = [0,0,h]) children();
}

module square_base() {
    minkowski() {
        $fn=20;

        circle(r = 1);
        square(center=true, size = [41.6-2,28]);
    };
}

module magnet_holder() {
    difference() {
        let(h=magnet_elevation + magnet_mount_lip)
        union() {
            translate(v = [0,0,-0.1])
            linear_extrude(height = magnet_elevation + magnet_mount_lip + 0.1)
            square_base();
            raise(h)
            linear_extrude(height = magnet_h - magnet_mount_lip + magnet_mount_top, scale=[1,top_holder_scale])
            scale(v = [1,bottom_holder_scale])
            square_base();
        }


        for (off=magnet_offsets)
        translate(v = [off, 0, magnet_elevation + magnet_h / 2]) {

            // a little pocket under magnets so surface imperfections won't affect fit
            let(pocket_depth = 0.9)
            translate(v = [0,0,-pocket_depth])
            cube(center=true, size = [
                magnet_w - magnet_bevel*2,
                magnet_length - magnet_bevel*2,
                magnet_h
            ]);
            magnet();
        }
    }
}

module mount() {
    difference()  {

        // base
        base();

        // mounting holes
        for (ang=[0:90:360]) {
            union() {
                rotate(a = ang, v = [0,0,1])
                translate(v = -[0,mounting_hole_dst/2,chamfer_height+base_height+0.2])
                rotate(a = 180,v=[1,0,0])
                mounting_hole();

                // small chamfer for tapped out material to sit in
                rotate(a = ang, v = [0,0,1])
                translate(v = -[0,mounting_hole_dst/2,-1.2])
                mounting_hole();
            }
        }
    }
}

module assemble() {
    magnet_holder();
    mount();

    // A lip on top
    let(source_h=magnet_elevation + magnet_h + magnet_mount_top - 0.0001)
    raise(source_h)
    linear_extrude(height = layer_height)
    projection(cut=true)
    raise(-source_h)
    magnet_holder();
}

module render_magnets() {
        color(c = "#333333")
        for (off=magnet_offsets)
        translate(v = [off, 0, magnet_elevation + magnet_h / 2])
        magnet();
}

// that weird hole shape
module seethru() {
    offset(r=1)
    offset(r=-2)
    offset(r=1) {
        square(size = [34.45,14], center=true);
        for (off=magnet_offsets) {
            square(size = [32.45,12], center=true);
            translate(v = [off, 0]) {
                // a little pocket under magnets so surface imperfections won't affect fit
                let(pocket_depth = 1.9)
                translate(v = [0,0,-pocket_depth])
                square(center=true, size = [
                    magnet_w - magnet_bevel*2,
                    magnet_length - magnet_bevel*2
                ]);
            }
        }
    }
}

difference() {
    translate(v = [0 ,0,base_height + chamfer_height])
    assemble();

    // info text
    let($fn=100, cut=1, depth=0.15)
    difference(){
        translate(v = -[0, outer_radius-cut/2, 0])
        cube(size = [100,cut + 0.01,100], center=true);

        color(c = "#ff0000")
        #translate(v = -[0, outer_radius-cut-0.01, 0])
        translate(v = [0, 0, (chamfer_height + base_height) / 2])
        rotate(a = 90, v = [1,0,0])
        linear_extrude(height = depth+0.01)
        text(text = str(unadj_magnet_elevation, " ", layer_height, " ", magnet_w), valign="center", halign="center", size=2, font="Fira Sans Condensed:style=Bold");
    }
    render(convexity=4)
    if (open) {
        let($fn=40)
        linear_extrude(height = 30,center=true,convexity=3)
        seethru();

        let($fn=40, hole=[38,28])
        linear_extrude(height = 1, scale=[(hole[0]-2)/hole[0], (hole[1]-2)/hole[1]])
        // offset(r=1)
        offset(r=1)
        offset(r=-1)
        square(size=hole, center=true);

        let($fn=40, hole=[36,28])
        linear_extrude(height = 10, scale=[1, (hole[1]-20)/hole[1]])
        // offset(r=1)
        offset(r=1)
        offset(r=-1)
        square(size=hole, center=true);
    }
    // let($fn=20)

    // linear_extrude(height = 1,center=true,convexity=3, scale=34.45/(34.45+2))
    // seethru();

    // rotate(a = 45, v = [1,0,0])
    // cube(size = [34.5,19,19], center=true);

}
