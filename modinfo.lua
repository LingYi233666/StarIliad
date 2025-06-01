name = "星辰史诗" ---mod名字
description = "星际游侠迷失在饥荒的永恒领域之中！" --mod描述
author = "灵衣女王的鬼铠" --作者
version = "0.0.1" -- mod版本 上传mod需要两次的版本不一样

forumthread = ""

api_version = 10                   --api版本

dst_compatible = true              --兼容联机

dont_starve_compatible = false     --不兼容原版
reign_of_giants_compatible = false --不兼容巨人DLC

all_clients_require_mod = true     --所有人mod

icon_atlas = "modicon.xml"         --mod图标
icon = "modicon.tex"

server_filter_tags = { --服务器标签
    "character",
}

--configuration_options = {} --mod设置

function stringidsorter()
    return 0
end
