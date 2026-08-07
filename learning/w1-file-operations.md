# W1 - 文件操作五兄弟（mkdir / touch / rm / cp / mv）

> 学习日期：2026-08-07 ｜ 配套：终端基础 → 文件操作
> 定位：实施日常的浓缩版工作流——建目录、备份、改名、移动、清理

## 一、五兄弟全景

```
mkdir 建家 → touch 放东西 → cp 备份 → mv 整理 → rm 清理
```

| 命令 | 作用 | 全称 | 关键变体 |
|---|---|---|---|
| `mkdir` | 建目录 | make directory | `-p` 一次建多层 |
| `touch` | 建空文件 | - | 也能更新文件时间 |
| `cp` | 复制 | copy | `-r` 复制目录（递归） |
| `mv` | 移动/改名 | move | 无需 -r |
| `rm` | 删除 | remove | `-r` 删目录、`-f` 强制 |

## 二、每个命令的用法

```bash
# mkdir：建目录
mkdir project          # 建一个目录
mkdir -p a/b/c         # 一次建多层（-p = 父目录不存在会自动建）

# touch：建空文件
touch app.log          # 建一个空文件

# cp：复制（先写源，后写目标）
cp nginx.conf nginx.conf.bak   # 备份配置 ← 实施铁律：改配置前先备份
cp -r app app_backup           # 复制目录必须加 -r（递归）

# mv：移动 / 改名（先写源，后写目标）
mv data.txt /tmp/      # 移动文件
mv old.txt new.txt     # 改名

# rm：删除
rm app.log             # 删文件
rm -r app_backup       # 删目录必须加 -r
rm -f xxx             # -f 强制删（不提示）
```

## 三、两个核心规律

### 1. cp / mv 都是「先源后目标」

```bash
cp 源 目标    # 从哪来 → 到哪去
mv 源 目标    # 从哪来 → 到哪去
```

### 2. 目录要加 -r 的原因（递归）

- 文件 = 一张纸，复制一次就行
- 目录 = 装满文件的抽屉，要"一层层走进去"把里面的东西全复制出来
- 这个"一层层往里走"叫**递归（recursive）**，缩写 `-r`
- 不加 `-r` 复制/删除目录会报错（omitting directory）

**一句话记忆**：凡是对"目录整体"操作（复制、删除），就要加 `-r`。

## 四、今日练习实录

```bash
hengtao@hengtao:~/桌面$ mkdir -p ~/learn-w1/config
hengtao@hengtao:~/桌面$ touch ~/learn-w1/server.conf ~/learn-w1/app.log ~/learn-w1/data.txt
hengtao@hengtao:~/桌面$ cp ~/learn-w1/server.conf ~/learn-w1/server.conf.bak
hengtao@hengtao:~/桌面$ mv ~/learn-w1/data.txt ~/learn-w1/data_20260807.txt
hengtao@hengtao:~/桌面$ mv ~/learn-w1/server.conf ~/learn-w1/config/
hengtao@hengtao:~/桌面$ rm ~/learn-w1/server.conf.bak
hengtao@hengtao:~/桌面$ ls -lR ~/learn-w1
/home/hengtao/learn-w1:
total 4
-rw-rw-r-- 1 hengtao hengtao    0 Aug  7 14:22 app.log
drwxrwxr-x 2 hengtao hengtao 4096 Aug  7 14:26 config
-rw-rw-r-- 1 hengtao hengtao    0 Aug  7 14:22 data_20260807.txt

/home/hengtao/learn-w1/config:
total 0
-rw-rw-r-- 1 hengtao hengtao 0 Aug  7 14:22 server.conf
```

最终结构：`app.log`（空文件）、`data_20260807.txt`（改过名）、`config/server.conf`（被移动进来）。

## 五、实施岗保命提醒

> **`rm -rf` 敲错目录 = 删库跑路级事故。** 执行 `rm` 前先 `ls` 看一眼路径再回车——这是 W1 就要养成的肌肉记忆。

## 六、一句话小结

**建目录 `mkdir -p`、备份 `cp 源 目标`、整理 `mv 源 目标`、目录操作加 `-r`、删前先 `ls`。** 这就是实施日常的五个动作。

关联：[[learning/w1-linux-terminal-basics]]、[[learning/linux-directory-structure]]、[[learning/w1-error-notes]]
