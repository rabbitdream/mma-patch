#!/bin/bash
# function: 删除指定目录下创建时间超过指定时间的空文件夹
# $1： 第一个命令行参数表示指定的目录
# $2:  第二个命令行参数表示目录的深度
# $3:  第三个命令行参数表示期望删除时间超过多少min的空文件夹
# 使用示例：
#     ./DeleteEmptyDir ./dir1 2 0
# 这是删除之前的目录结构：
# .
# ├── DeleteEmptyDir.sh
# ├── dir1
# │   ├── dir11
# │   │   ├── dir111
# │   │   ├── dir112
# │   │   └── dir113
# │   │       └── test.txt
# │   ├── dir12
# │   ├── dir13
# │   └── test.txt
# ├── dir2
# └── dir3
# 当我执行完这个命令之后，目录结构变为：
# .
# ├── DeleteEmptyDir.sh
# ├── dir1
# │   ├── dir11
# │   │   └── dir113
# │   │       └── test.txt
# │   ├── dir12
# │   ├── dir13
# │   └── test.txt
# ├── dir2
# └── dir3
# 可以看到，空文件夹 dir111 dir112已经被删掉
# 如果程序输出：
#     rmdir: 删除 "./dir1/dir11/dir113" 失败: 目录非空
#     find: ‘./dir1/dir11/dir111’: 没有那个文件或目录
#     find: ‘./dir1/dir11/dir112’: 没有那个文件或目录
# 是正常输出，能力有限，目前没找到解决办法

find $1 -mindepth $2 -type "d" -cmin +$3 -exec rmdir --ignore-fail-on-non-empty {} \; 
