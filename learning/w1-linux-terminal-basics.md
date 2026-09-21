# W1 - 终端基础：pwd / ls / cd

> 学习日期：2026-08-07 ｜ 学习人：hengtao
> 配套计划：AI转业学习计划_28周逐日版_v4（第一阶段 W1）

## 一、核心概念：目录树

Linux 里所有东西都是文件，所有文件都挂在一棵"目录树"上：

- 树根是 `/`（根目录）
- `/etc` 放配置、`/var/log` 放日志、`/home` 放用户文件
- 终端里的一切操作 = 在树上"走"，当前位置叫**工作目录**

> 排障第一原则：先定位（我在哪），再动手。SSH 上服务器第一件事先 `pwd`。

## 二、三个命令

| 命令 | 作用 | 说明 |
|---|---|---|
| `pwd` | 打印当前目录 | print working directory |
| `ls` | 列出目录内容 | 配 `-l` 看权限/属主/大小/时间 |
| `cd 路径` | 切换目录 | change directory |

常用变体和符号：

```bash
ls -l          # 长格式：权限、属主、大小、修改时间
cd /etc        # 绝对路径进入
cd ..          # 回上一级（.. = 上一级目录）
cd ~           # 回家目录（~ = 家目录）
.              # 当前目录
&&             # 前一个命令成功，才执行后一个（串联命令）
```

## 三、今日练习实录（我的实际操作）

```bash
# ① 看我在哪
hengtao@hengtao:~/桌面$ pwd
/home/hengtao/桌面

# ② 看当前目录（长格式）
hengtao@hengtao:~/桌面$ ls -l
total 12
-rw-r--r-- 1 hengtao hengtao 6169 Aug  7 10:21 W1-W6微调执行清单_防烂尾版.md
-rw-r--r-- 1 root    root     348 Aug  6 15:09 reasonix.toml

# ③ 进日志目录并确认
hengtao@hengtao:~/桌面$ cd /var/log && pwd
/var/log

# ④ 找出最大的文件（是 syslog，约 4MB）
hengtao@hengtao:/var/log$ ls -l
...
-rw-r----- 1 syslog adm 4101518 Aug  7 10:46 syslog

# ⑤ 回家（第一次失败，见下方报错笔记）
hengtao@hengtao:/var/log$ cd ~ && pwd
/home/hengtao
```

## 四、报错笔记（踩坑记录）

> 规划硬规则：报错笔记当天写完。每次报错记「报错信息 + 原因 + 解法」。

**报错信息：**
```bash
hengtao@hengtao:/var/log$ cd ～&&pwd
bash: cd: ～: 没有那个文件或目录
```

**原因：** 波浪号打成了**全角** `～`（中文输入法输出，占两个字符宽），而命令只认**半角** `~`（英文键盘，占一个字符宽）。bash 把它当成一个叫"～"的文件去找，当然找不到。

**解法：** 终端里的所有符号（波浪号、引号、括号、逗号、连字符）必须用**英文（半角）输入法**敲。中文输入法敲出的全角字符命令一概不认。切换输入法（Linux 一般是 Shift 或 Ctrl+Space）后再敲 `cd ~` 就成功了。

**以后怎么防：** 看到 `bash: cd: xxx: 没有那个文件或目录` 这类报错，先检查是不是全角符号；敲命令前确认输入法是英文。

## 五、一句话小结

`pwd` 告诉我在哪，`ls` 告诉我这有什么，`cd` 带我去别处。三者配合，在目录树里就不会迷路。

## 关联

- 学习总结规范：[[learning/README]]
- 实施部署相关：[[entities/deploy-setup]]
