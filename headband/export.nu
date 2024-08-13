use ../util.nu

mkdir export
util product {
    r: [30, 40, 50, 70, 90]
    th: [2, 4]
    coils: [0, 1, 5, 9, 15]
} | par-each { |cfg|
    let name = ($cfg | util kvs | each { $"($in.k)=($in.v | util pad 5)" } | str join '+' )
    let params =  ($cfg | to toml | lines | each {['-D' $in]} | flatten )

    (^openscad
    --enable 'fast-csg'
    --enable 'fast-csg-safer'
    --enable 'manifold'
    --enable 'predictible-output'
    --export-format binstl

    ...$params

    -o export/band+($name).stl
    ./band.scad
    )

    $"export/newcap+($name).stl"
}