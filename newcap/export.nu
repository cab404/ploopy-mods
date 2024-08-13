use ../util.nu

mkdir export
util product {
    magnet_size: [4.5, 4.8]
    open: ["yes", "no"]
    h: [1.6, 1.7, 1.8, 1.9]
    layer_height: [0.2, 0.1]
}
| par-each { |cfg|

    let name = ($cfg | util kvs | each { $"($in.k)=($in.v | util pad 5)" } | str join '+' )
    let params =  ($cfg
        | update open {|p| ($p.open == "yes")}
        | rename -c {magnet_size: magnet_h, h: unadj_magnet_elevation}
        | to toml | lines | each {['-D' $in]} | flatten )

    (^openscad
    --enable 'fast-csg'
    --enable 'fast-csg-safer'
    --enable 'manifold'
    --enable 'predictible-output'
    --export-format binstl

    ...$params

    -o export/newcap+($name).stl
    ./newcap.scad
    )
    $"export/newcap+($name).stl"

}
