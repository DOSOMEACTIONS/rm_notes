# git 四阶段地图（含反悔操作）

> 记住这张图，git 就不再神秘。
> 每条正向箭头都有对应的反向箭头 —— **git 几乎什么都能反悔**，只要还没 push。

---

## 一、全景图

```
  ① 工作区              ② 暂存区            ③ 本地仓库          ④ 远程仓库
  （你改的文件）        （挑进这次提交）    （永久历史）        （GitHub）

  ~/rm_notes           .git/index         .git/objects        origin/main
  ├─ README.md          ┌──────────┐       ┌──────────┐        ┌──────────┐
  ├─ gimbal.yaml        │ A 文件1  │       │ commit   │        │ commit   │
  └─ serial.cpp         │ M 文件2  │       │ f46d26a  │        │ ce2ea85  │
                        └──────────┘       │ ce2ea85  │        └──────────┘
       │                    │                 │                    │
       │                    │                 │                    │
       │──── git add ──────▶│                 │                    │
       │◀─── git restore ───│                 │                    │
       │                    │                 │                    │
       │                    │── git commit ──▶│                    │
       │                    │◀─ git reset ────│                    │
       │                    │                 │                    │
       │                    │                 │──── git push ─────▶│
       │                    │                 │◀─── git fetch ─────│

                    git stash ↕（临时抽屉，工作区 ↔ 抽屉）
```

**一句话理解每一层**：

| 层 | 存什么 | 丢了会怎样 |
|---|---|---|
| ① 工作区 | 你正在编辑的文件 | 文件还在，但改动没了 |
| ② 暂存区 | 下次提交要包含的快照 | 改动还在工作区，只是不在提交里 |
| ③ 本地仓库 | 所有历史提交 | 只要没 push，就是全部的家当 |
| ④ 远程仓库 | 团队共享的备份 | 只在这里才叫"真的存住了" |

---

## 二、正向操作（每一步做什么）

| 从 | 到 | 命令 | 什么时候用 |
|---|---|---|---|
| ① | ② | `git add 文件` | 决定"这个改动要进这次提交" |
| ① | ② | `git add .` | 全部改动都进 |
| ① | ② | `git add -p` | **按块挑**（一次提交只做一件事的关键） |
| ② | ③ | `git commit -m "信息"` | 存成一个历史节点 |
| ③ | ④ | `git push` | 传到 GitHub |
| ④ | ③ | `git pull` / `git fetch` | 把队友的更新拉下来 |

---

## 三、反向操作（反悔表）—— 左右对照看

| 你在哪一层想反悔 | 命令 | 可恢复？ | 说明 |
|---|---|---|---|
| ① 改了但不想要了 | `git restore 文件` | ❌ 不可恢复 | 直接覆盖成上次提交的样子 |
| ① 改了但想先存着 | `git stash push -m "说明"` | ✅ 可恢复 | 存进抽屉，`git stash pop` 拿回 |
| ② 加错了文件 | `git restore --staged 文件` | ✅ 完全可恢复 | 只是从暂存区退回工作区 |
| ③ 提交信息写错 | `git commit --amend -m "新信息"` | ✅ | **只在没 push 时安全** |
| ③ 漏了文件 | `git add 漏的文件` → `git commit --amend --no-edit` | ✅ | 追加进上一个提交 |
| ③ 整个提交都不想要 | `git reset --soft HEAD~1` | ✅ 改动留在暂存区 | 最安全 |
| ③ 提交和改动都不要 | `git reset --hard HEAD~1` | ❌ **危险** | 改动直接没了 |
| ④ 已经 push 了要改 | 别改 | ⚠️ | 改历史需要强推，**团队里基本等于事故** |

**⭐ 核心结论：`git` 的所有反悔都是安全的，只要还没 `git push`。**
**一旦 push，历史就属于团队了。**

---

## 四、四种状态对照表（做题时用这张）

| 你的状态 | `git status` 显示 | `git diff` | `git diff --cached` | 下一步 |
|---|---|---|---|---|
| 刚改完 | 红色 "Changes not staged" | ✅ 有 | ❌ 空 | `git add` |
| 已暂存 | 绿色 "Changes to be committed" | ❌ 空 | ✅ 有 | `git commit` |
| 已提交未推送 | "领先 origin/main 共 N 个提交" | ❌ 空 | ❌ 空 | `git push` |
| 已推送 | "与上游分支一致" | ❌ 空 | ❌ 空 | 没事了 |

**`git status -s` 的字母**：

```
??   未跟踪
A    已暂存的新文件
M    已修改（左列=暂存区，右列=工作区）
D    已删除
R    重命名
```

---

## 五、"想改"的四种情况（最常问的问题）

### 情况 1：刚改完，还没 add
```bash
git diff                  # 看看改成什么样
git restore 文件           # 不要了
# 或者
git add 文件               # 要了，进暂存区
```

### 情况 2：add 了，还没 commit
```bash
git review                # 看暂存区摘要
git what                  # 看具体改动
git restore --staged 文件  # 加错了，退回去
git commit -m "..."       # 没问题，提交
```

### 情况 3：commit 了，还没 push ← 你现在可能在这
```bash
# 改提交信息
git commit --amend -m "新的提交信息"

# 忘了加文件
git add 漏掉的文件
git commit --amend --no-edit

# 整个提交撤掉（改动保留）
git undo                  # = reset --soft HEAD~1
```

**⚠️ `amend` 只在没 push 的时候用。已经 push 过再 amend，会要求强推。**

### 情况 4：已经 push 了
```bash
# ❌ 不要 git push -f
# ✅ 用新的提交去修正
git commit -m "fix: 修正上次提交里的错误"
git push
```

**规则：已推送的历史，用新提交去修，不要改历史。**

---

## 六、一次完整循环（背下来）

```bash
cd ~/rm_notes

git status -sb            # ① 我在什么状态
git diff                  # ② 改了什么（未 add 部分）
git add .                 # ③ 挑进暂存区
git review                # ④ 确认文件列表对
git what                  # ⑤ 确认改动内容对
git commit -m "feat: xxx" # ⑥ 存进本地历史
git push                  # ⑦ 传到 GitHub
git status -sb            # ⑧ 确认完全同步
```

**这 8 步就是日常全部。** 其余的（分支、冲突、回滚）都是特殊情况才用。

---

## 七、三张保命命令

```bash
git stash push -m "说明"     # 换分支前先存着（比 checkout -- 安全）
git restore --staged 文件     # 取消暂存
git undo                     # 撤销上次提交，改动保留
```

**永远不用**：
```bash
git push -f                  # 会覆盖队友提交
git reset --hard             # 会丢改动（除非你确定）
git checkout -- 文件          # 不可恢复（用 restore/stash 代替）
```

---
---

# 十、我的仓库地图（2026-10-18 实测）

> 这一节是**你这台机器上的真实状态**，不是通用示例。

---

## 10.1 先搞清三个名字

**GitHub 地址的格式永远是：`github.com/<用户名>/<仓库名>`**

```
git@github.com:DOSOMEACTIONS/missing-semester.git
         └──────┘  └────────────┘  └─────────────┘
         域名       ①用户名           ②仓库名
```

| # | 名字 | 是什么 | 地址 |
|---|---|---|---|
| ① | **OceanCing** | **老师的 GitHub 用户名**（团队仓库所有者） | github.com/OceanCing |
| ② | **DOSOMEACTIONS** | **你的 GitHub 用户名**（你的账号） | github.com/DOSOMEACTIONS |
| ③ | **missing-semester** | **仓库名**（老师和你的都叫这个，同名是 Fork 的默认行为） | — |

**⚠️ 最容易搞混的：`missing-semester` 是「仓库名」，不是「用户名」。**

```
❌ OceanCing/missing-semester  →  "missing-semester 是老师名"  错
✅ OceanCing/missing-semester  →  "OceanCing 是老师，missing-semester 是仓库"  对

✅ DOSOMEACTIONS/missing-semester → "DOSOMEACTIONS 是我，missing-semester 是仓库"
```

---

## 10.2 三个仓库的位置关系

```
┌─────────────────────────────────────────────────────────────┐
│  ① 团队仓库（老师有写权限，你只能读）                        │
│     github.com/OceanCing/missing-semester                   │
└─────────────────────────────────────────────────────────────┘
                            │
                            │  Fork（网页点一下）✅ 已做
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  ② 你的 fork（你有完全权限，随便改）                         │
│     github.com/DOSOMEACTIONS/missing-semester               │
└─────────────────────────────────────────────────────────────┘
                            │
                            │  Clone（git clone）✅ 已做
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  ③ 你的电脑                                                 │
│     ~/missing-semester                                      │
│     当前分支: master                                        │
│     当前 remote: origin（upstream 还没加 ⚠️）                │
└─────────────────────────────────────────────────────────────┘
```

---

## 10.3 你现在的真实状态（命令输出）

```bash
$ cd ~/missing-semester
$ git remote -v
origin  git@github.com:DOSOMEACTIONS/missing-semester.git (fetch)
origin  git@github.com:DOSOMEACTIONS/missing-semester.git (push)

$ git branch --show-current
master
```

**解读：**

| 项目 | 状态 | 说明 |
|---|---|---|
| 本地目录 | `~/missing-semester` | ✅ 已 clone |
| remote `origin` | ✅ 指向你的 fork | clone 时自动加的 |
| remote `upstream` | ❌ **还没加** | 第 4a 步没做 |
| 当前分支 | `master` | ⚠️ **还没建自己的分支**（第 4b 步没做） |
| 能不能 push | ✅ 能（推到你的 fork） | |
| 能不能 pull 团队更新 | ❌ 不能（没 upstream） | |

---

## 10.4 四个方向 + 对应命令（你的场景版）

```
①团队仓库 OceanCing/missing-semester
        │
        │  Fork                       网页点一下（一次）
        ▼
②你的fork DOSOMEACTIONS/missing-semester
        │
        │  Clone                      git clone git@github.com:DOSOMEACTIONS/missing-semester.git
        ▼
③本地 ~/missing-semester (master)
        │
        │  Branch                     git switch -c feat/DOSOMEACTIONS-lesson1
        ▼
④本地分支 feat/DOSOMEACTIONS-lesson1
        │
        │  Commit                     git add / git commit
        │  Push                       git push -u origin feat/DOSOMEACTIONS-lesson1
        ▼
⑤你的fork上的分支 → 发 PR 请求合并回 ①团队仓库
```

**反向（更新）方向：**

```
①团队仓库 ──git pull --rebase upstream master──▶ ③本地 master
③本地 master ──git push origin master──▶ ②你的fork master
```

---

## 10.5 origin vs upstream（两个遥控器）

| 名字 | 指向 | 权限 | 用途 |
|---|---|---|---|
| **origin** | 你的 fork | ✅ 读写 | push 你的提交、pull 你自己的 |
| **upstream** | 团队仓库 | ❌ 只读 | pull 团队最新更新（含 TASK.md 更新） |

**为什么要两个：**

```
你的 fork 不会自动跟着团队仓库变。
老师更新了 TASK.md → 你的 fork 里还是旧版
→ 必须 git pull --rebase upstream master 手动拉
```

---

## 10.6 你现在缺的两步（接下来做）

```bash
cd ~/missing-semester

# 4a. 加 upstream（让能拉团队更新）
git remote add upstream git@github.com:OceanCing/missing-semester.git
git remote -v          # 应该看到 4 行：origin 两条 + upstream 两条

# 4b. 建你自己的开发分支（TASK.md 第 1 条要求）
git switch -c feat/DOSOMEACTIONS-lesson1
git branch --show-current    # 应该显示 feat/DOSOMEACTIONS-lesson1
```

**做完之后你的状态应该变成：**

```bash
$ git remote -v
origin    git@github.com:DOSOMEACTIONS/missing-semester.git (fetch)
origin    git@github.com:DOSOMEACTIONS/missing-semester.git (push)
upstream  git@github.com:OceanCing/missing-semester.git (fetch)
upstream  git@github.com:OceanCing/missing-semester.git (push)

$ git branch --show-current
feat/DOSOMEACTIONS-lesson1
```

**注意 upstream 也有两条（fetch + push）** —— git 会给每个 remote 都生成一对，
但你 push 到 upstream 会失败（没权限），这是正常的。

---

## 10.7 作业要建的目标结构

```
missing-semester/                    ← 仓库根（你自己电脑上的 ~/missing-semester）
└── 2027/                            ← 任务文件夹
    └── DOSOMEACTIONS/               ← ⭐ 用你的 GitHub 用户名命名
        ├── notes/                   ← 笔记
        │   └── lesson1-linux-vim-shell-git.md     ← 英文命名
        └── homework/                ← 作业
            ├── lesson1.sh           ← 可执行脚本
            └── output.txt           ← 脚本跑出来的结果（也要提交）
```

**对应的命令：**

```bash
cd ~/missing-semester
mkdir -p 2027/DOSOMEACTIONS/notes 2027/DOSOMEACTIONS/homework
cd 2027/DOSOMEACTIONS
touch notes/lesson1-linux-vim-shell-git.md
vim notes/lesson1-linux-vim-shell-git.md
```

---

## 10.8 提交与 PR（作业要求版）

```bash
cd ~/missing-semester

# 确认在正确分支
git branch --show-current      # feat/DOSOMEACTIONS-lesson1

# 确认改了哪些文件
git status -sb

# 暂存 + 复查
git add 2027/DOSOMEACTIONS
git review                     # 摘要
git what                       # 完整 diff

# ⚠️ 提交信息：英文、大写开头、带句号
git commit -m "Add lesson1 notes and homework script."

# push 到你的 fork（不是团队仓库）
git push -u origin feat/DOSOMEACTIONS-lesson1
```

**PR 标题格式**（英文、大写开头）：

```
Add lesson1 homework - DOSOMEACTIONS
```

**PR 描述**（可以中文，要说清提交了什么）：

```
新增第一课作业：
- 2027/DOSOMEACTIONS/notes/lesson1-linux-vim-shell-git.md —— Linux/vim/shell/git 笔记
- 2027/DOSOMEACTIONS/homework/lesson1.sh —— 输出系统时间、最近10条命令、笔记字数
- 2027/DOSOMEACTIONS/homework/output.txt —— 脚本运行结果
```

---

## 10.9 三条纪律（TASK.md 明确写了）

| # | 纪律 | 犯错后果 |
|---|---|---|
| 1 | commit 消息**英文、大写开头、带句号** | 格式不规范 |
| 2 | **不要 Close PR 重开** | **扣分**（TASK.md 第 9 条） |
| 3 | 出现 Conflict 要**正确处理**，不是逃避 | 扣分 |

**正确改 PR 的方式（不用关掉）：**

```
PR 开了之后想改内容 → 直接 push 新提交到同一个分支
                   → PR 会自动更新（TASK.md 第 9 条说的）
```

---

## 10.10 出现冲突怎么办（TASK.md 第 8 条预告了）

```bash
# ① 拉团队最新，可能会冲突
git switch master
git pull --rebase upstream master

# ② 如果冲突了，看哪些文件
git conflicts

# ③ 用三栏对比解决（你已配好 meld）
git mergetool

# ④ 解决完继续
git add 冲突文件
git rebase --continue

# ⑤ 推到自己 fork
git push origin master

# ⑥ 回到你的分支，把 master 的更新合并进来
git switch feat/DOSOMEACTIONS-lesson1
git rebase master
git push -u origin feat/DOSOMEACTIONS-lesson1
```

**⚠️ 绝对不要用 `git push -f` 到 upstream，也不要用"Close PR 重开"来绕过冲突。**
