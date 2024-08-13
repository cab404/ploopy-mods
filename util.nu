export def kvs [] {
    let f = $in
    $f | columns | each {|a| { k: $a, v: ($f | get $a) }}
}

export def product [vars: any] {
    let cols = $vars | columns
    if ($cols | length) == 0 { [{}] } else {
        let cur = ($cols | first)
        let other = product ($vars | reject $cur)
        ($vars
            | get $cur
            | each { |cvar|
                $other
                | each { |opt| {$cur: $cvar} | merge $opt }
            }
            | flatten
        )
    }
}

export def pad [n: int] {
    fill -a right -c '.' --width $n
}