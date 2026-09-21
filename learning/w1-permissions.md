# W1 - 文件权限体系（rwx / chmod）

> 学习日期：2026-08-07 ｜ 配套：文件操作 → 权限
> 定位：实施岗"服务起不来"头号原因就是权限——这一课把它彻底看懂

## 一、场景：为什么实施岗必须懂权限

部署服务后配置文件权限不对，服务以另一个用户身份跑，一读就报 **Permission denied**，服务直接起不来。排查"权限对不对"靠 `ls -l`——今天学会看那串字符。

## 二、核心概念：三个角色 × 三种权限

**三个角色（谁）：**

| 角色 | 字母 | 含义 |
|---|---|---|
| user | **u** | 属主（文件的主人） |
| group | **g** | 属组（和属主同组的用户） |
| other | **o** | 其他人 |

**三种权限（能干什么）：**

| 权限 | 字母 | 对文件 | 对目录 |
|---|---|---|---|
| 读 | **r** | 看内容 | 列出目录内容 |
| 写 | **w** | 改内容 | 建/删文件 |
| 执行 | **x** | 运行它 | 进入目录（cd） |

## 三、看懂 `-rw-r--r--`：十字符四部分

```
-  rw-  r--  r--
│  │    │    │
│  │    │    └─ other 其他人的权限
│  │    └────── group 属组的权限
│  └────────── user 属主的权限
└──────────── 文件类型（- 普通文件 / d 目录）
```

`rw-` = 读 + 写、无执行（`-` 表示"没有"）。

例：`-rw-r--r--` = 属主 rw-、属组 r--、其他 r--（自己能读写，别人只能看）——最常见的配置文件权限。

## 四、chmod 数字法（最常用）

**数字对应：r=4，w=2，x=1**

每角色权限 = 三个数字相加：

| 组合 | 计算 | 数字 |
|---|---|---|
| rwx | 4+2+1 | **7** |
| rw- | 4+2 | **6** |
| r-x | 4+1 | **5** |
| r-- | 4 | **4** |
| --- | 0 | **0** |

三角色各一个数字拼成三位数：

```bash
chmod 755 文件   # 属主7 属组5 其他5   ← 最常用（程序/脚本）
chmod 644 文件   # 属主6 属组4 其他4   ← 配置文件最常见
chmod 600 文件   # 属主6 属组0 其他0   ← 密钥文件
chmod 777 文件   # 全都有              ← 危险，别乱用
```

**速记**：7=全权、6=读写、5=读+执行、4=只读。

## 五、今日实操实录

```bash
# 默认权限（这台 Ubuntu 是 664，不是 644！）
hengtao@hengtao:~/桌面$ touch ~/learn-w1/test.txt
hengtao@hengtao:~/桌面$ ls -l ~/learn-w1/test.txt
-rw-rw-r-- 1 hengtao hengtao 0 Aug 10 10:11 /home/hengtao/learn-w1/test.txt

# 改成 600：只有属主可读写
hengtao@hengtao:~/桌面$ chmod 600 ~/learn-w1/test.txt
hengtao@hengtao:~/桌面$ ls -l ~/learn-w1/test.txt
-rw------- 1 hengtao hengtao 0 Aug 10 10:11 /home/hengtao/learn-w1/test.txt

# 改成 755：属主全权，属组/其他 读+执行
hengtao@hengtao:~/桌面$ chmod 755 ~/learn-w1/test.txt
hengtao@hengtao:~/桌面$ ls -l ~/learn-w1/test.txt
-rwxr-xr-x 1 hengtao hengtao 0 Aug 10 10:11 /home/hengtao/learn-w1/test.txt
```

## 六、umask 概念（听个概念即可）

touch 出来的新文件默认权限**不是固定的**——由 umask（默认权限模板）决定。不同系统可能不同（这台 Ubuntu 默认 664）。**所以：改权限前先 `ls -l` 看一眼，别凭印象。**

## 七、一句话小结

**权限 = 三个角色（u/g/o）× 三个动作（r/w/x）；数字法 r=4 w=2 x=1；7=全权 6=读写 5=读+执行 4=只读。改前先 `ls -l` 看现状。**

关联：[[learning/w1-file-operations]]、[[learning/linux-directory-structure]]、[[learning/w1-error-notes]]
