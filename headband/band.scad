l = 160; // default: 160 from standard ploopy bands
r = 50; // default: 90 from standard ploopy bands
coils = 16; // 0 to disable coiling
ampl = 4; // amplitude for coils
th = 2; // thickness of the band
h = 8;
sharpest_point=0.25;
points_per_degree = 5;

// These are weird-ish.
// You can get non-flat springs with this.

// extrude_scale = 0.9;
// xoff=5;

extrude_scale = 1;
xoff=0;

$fn=30;


module pin() {
    translate(v = [xoff,-0.16,0])
    import("./pin.stl");
}

function sinarc(r, ang, ampl, points) = [ for (i=[0:points-1]) each let (
    a=i/points*ang,
    p=i/points,
    off = cos(p*360*coils+180)*ampl
    )[
    [ (r+off) * cos(a), (r+off) * sin(a) ]
] ];

module wavyarc(arc, ampl, r, points) {
    offset(r = -sharpest_point)
    offset(r = sharpest_point)
    offset(r = th/2)
    let (r=r+ampl+th/2)
    polygon(
        points = concat(
            sinarc(r-0.00001, arc, ampl, points),
            sinarc(r+0.00001, arc, ampl, points)
        ),
        paths=[
            concat(
                [for (i=[0:(points-1)]) each i],
                [for (i=[(points*2-1):-1:(points+1)]) each i]
            )
        ]
    );
}

// for (r = [50,60,70,80,90])
translate(v = [-r,0])
union() {

    ang = l / (PI * r) * 180;
    rotate(a = ang, v = [0,0,1])
    translate(v = [r,0,0])
    pin();

    translate(v = [r,0,0])
    scale(v = [-1,1,1])
    rotate(a = 180, v = [0,0,1])
    pin();

    linear_extrude(height = h,scale=extrude_scale)
    {
        wavyarc(ang, ampl, r, ceil(points_per_degree * ang));
        if (coils > 0) {
            wavyarc(ang/coils/2, 0, r+ampl*2, ceil(points_per_degree * (ang/coils/2)));
            rotate(a = ang-ang/coils/2)
            wavyarc(ang/coils/2, 0, r+ampl*2, ceil(points_per_degree * (ang/coils/2)));
        }
    }

}
