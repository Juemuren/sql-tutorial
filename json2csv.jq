[ .items[] | select(.name | contains("芯片")) | {
    prof: (.name | sub("芯片组$"; "") | sub("双芯片$"; "") | sub("芯片$"; "")),
    typ: (
        if .name | endswith("芯片组") then "大"
        elif .name | endswith("双芯片") then "双"
        elif .name | endswith("芯片") then "小"
        else "" end
    ),
    count: .have
} ] as $chips |

reduce $chips[] as $c ({}; .[$c.prof + "|" + $c.typ] = $c.count) as $chip_map |
["先锋","辅助","狙击","术师","近卫","特种","重装","医疗"] as $prof_order |
["小","大","双"] as $type_order |
["职业","芯片类型","数量"], (
    $prof_order[] as $p |
    $type_order[] as $t |
    [ $p, $t, ($chip_map[$p + "|" + $t] // 0) ]
) |
@csv