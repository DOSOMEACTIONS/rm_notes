# git 全流程地图

> 从「别人的仓库」到「我的 PR」，一张图走完。
>
> **核心：git 有两件完全不同的事，别混**
> - **一次性准备**：Fork / Clone / upstream / 分支 —— 一个仓库只做一次
> - **日常循环**：改 / add / commit / push —— 每写一次代码都做

---

## 第一层：一眼看全

```
┌─────────────────────────────────────────────────────────────┐
│ 第 0 层 · 一次性准备（这个仓库只做一次）                     │
│                                                             │
│   ① 找仓库 ─▶ ② Fork ─▶ ③ Clone ─▶ ④a upstream ─▶ ④b 分支  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ 第 1 层 · 日常循环（每次改代码都重复）                       │
│                                                             │
│   ⑤ 改文件 ─▶ ⑥ add ─▶ ⑦ commit ─▶ ⑧ push                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ 第 2 层 · 交付（做完一个任务）                               │
│                                                             │
│   ⑨ 开 PR ─▶ ⑩ 看评论 ─▶ 有意见就改 ─▶ 再 push（PR 自动更新）│
└─────────────────────────────────────────────────────────────┘
```

**新手最常见的错误：以为每天都要 Fork 和 Clone。答案是不用 —— 只有第 1 层是天天做的。**

---

## 第二层：第 0 层详解（一次性准备）

### 全线路图

```
【① 团队仓库】老师的，你只能读
  github.com/OceanCing/missing-semester
        │
        │  Fork      ← 网页点一下，2 秒
        │  效果：在你自己账号下复制一份
        ▼
【② 你的 fork】你的账号下，你有完全权限
  github.com/DOSOMEACTIONS/missing-semester
        │
        │  Clone     ← 终端一条命令，一次性
        │  命令：git clone git@github.com:DOSOMEACTIONS/missing-semester.git
        │  效果：下载到电脑 + 自动记下 origin
        ▼
【③ 你的电脑】
  ~/missing-semester
  remote: origin（自动加的）
        │
        │  ④a 加 upstream
        │  命令：git remote add upstream git@github.com:OceanCing/missing-semester.git
        │  效果：现在能拉团队最新了
        ▼
  ~/missing-semester
  remote: origin   → ② 你的 fork（可 push）
  remote: upstream → ① 团队仓库（只 pull）
        │
        │  ④b 建分支
        │  命令：git switch -c feat/DOSOMEACTIONS-lesson1
        │  效果：从 master 分一条自己的开发线
        ▼
【④ 准备完成】
  分支：feat/DOSOMEACTIONS-lesson1
  可以开始写代码了 ✅
```

### 每一步的「为什么」

| 步骤 | 命令 / 操作 | 为什么必须做 | 不做会怎样 |
|---|---|---|---|
| **① 找仓库** | 浏览器打开老师给的链接 | 得知道从哪来 | — |
| **② Fork** | 网页点 Fork 按钮 | 团队仓库你没写权限，得有自己的副本 | push 会被拒绝 |
| **③ Clone** | `git clone <你的fork地址>` | 把仓库下载到本地才能改 | 改不了 |
| **④a upstream** | `git remote add upstream ...` | 你的 fork 不会自动跟着团队更新 | 拉不到 TASK.md 更新，将来要重 clone |
| **④b 分支** | `git switch -c feat/xxx` | 作业要求；PR 才干净 | 违反 TASK.md 第 1 条 |

### 名字搞清：URL 结构

```
git@github.com:DOSOMEACTIONS/missing-semester.git
         │      │              │
         │      │              └─ 【仓库名】missing-semester
         │      └──────────────── 【用户名】← 你的账号
         └─────────────────────── 域名
```

| 名字 | 是什么 | 谁 |
|---|---|---|
| `OceanCing` | 用户名 | 老师 / 团队 |
| `DOSOMEACTIONS` | 用户名 | **你** |
| `missing-semester` | 仓库名 | 两边都叫这个 |

**格式永远是 `github.com/<用户名>/<仓库名>`** —— 斜杠左边是人，右边是项目。

---

## 第三层：第 1 层详解（日常循环）

### 四阶段全景（这张是最重要的）

```
  ① 工作区              ② 暂存区            ③ 本地仓库        ④ 远程仓库
  （你改的文件）        （挑进这次提交）    （永久历史）      （你的 fork）

  ~/missing-semester   .git/index         .git/objects      origin
  ├─ README.md          ┌──────────┐       ┌──────────┐      ┌──────────┐
  ├─ gimbal.yaml        │ A 文件1  │       │ commit   │      │ commit   │
  └─ serial.cpp         │ M 文件2  │       │ f46d26a  │      │ ce2ea85  │
                        └──────────┘       │ ce2ea85  │      └──────────┘
       │                    │                 │                  │
       │                    │                 │                  │
       │──── git add ──────▶│                 │                  │
       │◀─── git restore ───│                 │                  │
       │                    │                 │                  │
       │                    │── git commit ──▶│                  │
       │                    │◀─ git reset ────│                  │
       │                    │                 │                  │
       │                    │                 │──── git push ───▶│
       │                    │                 │◀─── git pull ────│

                    git stash ↕（临时抽屉，工作区 ↔ 抽屉）
```

### 每层存什么

| 层 | 存什么 | 丢了会怎样 | 谁能看到 |
|---|---|---|---|
| ① 工作区 | 你正在编辑的文件 | 文件还在，改动没了 | 只有你 |
| ② 暂存区 | 下次提交的快照 | 改动还在工作区 | 只有你 |
| ③ 本地仓库 | 所有历史提交 | 没 push 前就是全部家当 | 只有你 |
| ④ 远程仓库 | 团队可见的备份 | **到这才叫"真的存住了"** | **所有人** |

### 反悔表

| 你在哪层想反悔 | 命令 | 可恢复？ |
|---|---|---|
| ① 改了不想要 | `git restore 文件` | ❌ 不可恢复 |
| ① 改了想先存着 | `git stash push -m "说明"` | ✅ 可恢复 |
| ② 加错文件 | `git restore --staged 文件` | ✅ 完全可恢复 |
| ③ 信息写错 | `git commit --amend -m "新"` | ✅（未 push 时） |
| ③ 漏了文件 | `git add 漏的` + `git commit --amend --no-edit` | ✅（未 push 时） |
| ③ 提交不要了 | `git undo` | ✅ 改动留在暂存区 |
| ③ 提交和改动都不要 | `git reset --hard HEAD~1` | ❌ 危险 |
| ④ 已 push | **别改历史** | ⚠️ 强推会覆盖队友提交 |

**⭐ 一句话：只要还没 `git push`，git 里什么都能反悔。一旦 push，历史就属于团队了。**

### 四种状态对照（做题时用）

| 你的状态 | `git status` 显示 | `git diff` | `git diff --cached` | 下一步 |
|---|---|---|---|---|
| 刚改完 | 红色 "Changes not staged" | ✅ 有 | ❌ 空 | `git add` |
| 已暂存 | 绿色 "Changes to be committed" | ❌ 空 | ✅ 有 | `git commit` |
| 已提交未推送 | "领先 origin/main 共 N 个提交" | ❌ 空 | ❌ 空 | `git push` |
| 已推送 | "与上游分支一致" | ❌ 空 | ❌ 空 | 完事 |

---

## 第四层：第 2 层详解（PR 与协作）

### PR 的完整生命周期

```
③ 本地分支 feat/xxx
        │
        │  git push -u origin feat/xxx
        ▼
② 你的 fork 上的分支
        │
        │  网页点 "Compare & pull request"
        │  标题：英文、大写开头
        │  描述：中文可以，写清你提交了什么
        ▼
① 团队仓库的 PR 页面
        │
        ├──▶ 老师评论（comments）
        │         │
        │         │  你改了 + 再 push（同一分支）
        │         │  → PR 自动更新，不用重开
        │         ▼
        └──▶ 老师合并（Merge）✅
```

### PR 期间的三条纪律（TASK.md 明确要求）

| # | 纪律 | 犯错后果 |
|---|---|---|
| 1 | commit 消息**英文、大写开头、带句号** | 格式不规范 |
| 2 | **不要 Close PR 重开** | **扣分** |
| 3 | 有 Conflict 要正确处理，不能逃避 | 扣分 |

**正确改 PR 的方式：**

```bash
# PR 开着，你想改内容
vim 某个文件
git add .
git commit -m "Fix formatting in notes."
git push
# → PR 自动更新，不需要关掉重开
```

### 两个遥控器（origin 和 upstream）

```
                    你的电脑 ~/missing-semester
                    ┌────────────────────────┐
                    │  remote: origin ───────┼──▶ ② 你的 fork（读写）
                    │  remote: upstream ─────┼──▶ ① 团队仓库（只读）
                    └────────────────────────┘
```

| 场景 | 用哪个 | 命令 |
|---|---|---|
| 推你的作业 | **origin** | `git push -u origin feat/xxx` |
| 拉团队更新 | **upstream** | `git pull --rebase upstream master` |
| 看有哪些远程 | — | `git remote -v` |

### 冲突处理（TASK.md 第 8 条预告了）

```bash
# ① 拉团队最新（可能冲突）
git switch master
git pull --rebase upstream master

# ② 冲突了，看哪些文件
git conflicts

# ③ 三栏对比解决（已配好 meld）
git mergetool

# ④ 解决完继续
git add 冲突文件
git rebase --continue

# ⑤ 推到自己 fork
git push origin master

# ⑥ 回你的分支，把 master 更新带进来
git switch feat/DOSOMEACTIONS-lesson1
git rebase master
git push -u origin feat/DOSOMEACTIONS-lesson1
```

**⚠️ 绝对不要**：
- `git push -f` 到团队仓库
- 用「Close PR 重开」绕过冲突（会扣分）

---

## 第五层：命令速查（按层分组）

### 第 0 层 · 一次性准备

```bash
# ② Fork：网页操作，没有命令

# ③ Clone
git clone git@github.com:DOSOMEACTIONS/missing-semester.git
cd missing-semester

# ④a 加 upstream
git remote add upstream git@github.com:OceanCing/missing-semester.git
git remote -v

# ④b 建分支
git switch -c feat/DOSOMEACTIONS-lesson1
git branch --show-current
```

### 第 1 层 · 日常循环

```bash
git status -sb            # 我在什么状态
git diff                  # 改了什么
git add .                 # 挑进暂存区
git review                # 提交前确认文件列表
git commit -m "说明"      # 存进本地历史
git push                  # 传到 GitHub
git status -sb            # 确认同步
```

### 第 2 层 · 交付与协作

```bash
gh pr create                          # 开 PR（或网页点）
git pull --rebase upstream master     # 拉团队更新
git mergetool                         # 解决冲突
git log --oneline --graph --all       # 看全景历史
```

### 保命命令

```bash
git stash push -m "说明"    # 换分支前先存着
git restore --staged 文件    # 取消暂存
git undo                     # 撤销上次提交（改动保留）
git conflicts                # 列出没解决的冲突
```

### 永远不用

```bash
git push -f                  # 会覆盖队友提交
git reset --hard             # 会丢改动（除非确定）
git checkout -- 文件          # 不可恢复（用 restore/stash）
```

---

## 附录：你的当前进度（2026-10-18 更新）

```
第 0 层 · 一次性准备
  ① 找仓库     ✅ github.com/OceanCing/missing-semester
  ② Fork       ✅ DOSOMEACTIONS/missing-semester
  ③ Clone      ✅ ~/missing-semester
  ④a upstream  ✅ 已加（能拉团队更新）
  ④b 分支      ✅ feat/DOSOMEACTIONS-lesson1

第 1 层 · 日常循环
  ⑤ 改文件     ✅ notes/lesson1-*.md + homework/lesson1.sh
  ⑥ add        ✅ git add 2027/DOSOMEACTIONS
  ⑦ commit     ✅ 9755655 "Add lesson1 notes and homework script."
  ⑧ push       ✅ 推到 origin/feat/DOSOMEACTIONS-lesson1

第 2 层 · 交付
  ⑨ 开 PR      ✅ #12 Open，可自动合并，无冲突
  ⑩ 看评论     ⏳ 等老师 review
```

**DDL: 10月20日 23:59 —— 已完成，提前 2 天 ✅**

**下一步（等老师评论）：**
```bash
# 老师留评论要改的话
vim 2027/DOSOMEACTIONS/notes/xxx.md
git add 2027/DOSOMEACTIONS
git commit -m "Fix formatting in notes."
git push        # PR 自动更新，不用重开
```

**还没有内容的地方（可选补）：**
笔记里 1.1 / 1.3 / 3.2 / 4.4 四节还空着，可以以后补 —— 补完 push 会自动更新 PR。

---

## 附录 B：为什么 push 会被拒 —— 火车比喻

> 这一节专治「看懂了但明天就忘」。
> 以后忘了，只看一张表和三张图就够。

### B.1 对应关系（背这张表）

| git 里的东西 | 火车比喻 | 关键特性 |
|---|---|---|
| **commit（提交）** | 一节**车厢** | 装着你这次的改动 |
| **parent（父提交）** | 车钩：这节挂在谁后面 | **每节车厢只有一个车钩** |
| **commit hash**（如 `366fe56`） | **车厢编号** | 由「装的货 + 前一节的编号」算出来 |
| **branch（main）** | **车头** | 车头挂在哪，整列车就延伸到哪 |
| **仓库**（本地 / 远程） | 一个**车辆段** | 各自有车头，各自造车厢 |
| **push** | 请求终点车辆段：**把你的车头改挂到我这节上** | 有严格条件（见 B.3） |
| **clone** | 把整列车**复制**一份到你的车辆段 | 一次性 |
| **pull** | 去对方车辆段**取回**新造的车厢，接到自己车头后面 | 反复做 |
| **rebase** | 把你车厢里的**货卸下来**，重新装进新造的车厢 | 因为车钩改了，编号必须重印 |
| **conflict** | 两边给**同一节车厢装了不同的货** | 必须人来决定留哪批 |

### B.2 你的车队长这样（2026-10-18 真实数据）

```
你的本地车辆段（~/rm_notes）
  车头 main ─▶ [366fe56] ─▶ [103c89b] ─▶ [972722e] ─▶ [f46d26a] ─▶ ... ─▶ [1e8344f]
                 最新的        网页改的      分叉点

GitHub 远程车辆段
  车头 main ─▶ [366fe56] ─▶ [103c89b] ─▶ [972722e] ─▶ ...
                 同一个车头（已同步 ✅）
```

**每节车厢上印的车钩是这样的：**

```
[972722e] 车钩: 挂在 f46d26a 后面
[103c89b] 车钩: 挂在 972722e 后面      ← 你在网页上造的
[366fe56] 车钩: 挂在 103c89b 后面      ← rebase 后重造的
```

### B.3 push 唯一检查的一件事

**请求：** "把这个车辆段的 `main` 车头，改挂到我新造的 `e96bbb5` 上。"

**检查：** 顺着 `e96bbb5` 的车钩一路往回倒 —— **能不能倒到对方现在的车尾（`103c89b`）？**

```
能不能？
   e96bbb5 的车钩 → 972722e
   972722e 的车钩 → f46d26a
   f46d26a 的车钩 → ce2ea85
   ...
   一路下去，永远碰不到 103c89b
                    ↓
               ❌ 不能 → 拒绝
```

**拒绝的话是：**

```
! [rejected]  main -> main (fetch first)
```

**翻译成火车语言：**

> **"你的车钩接不上我这条线。先把我新造的车厢取回去（fetch），再来挂。"**

### B.4 为什么"我改的文件跟它不一样"没用

**因为检查发生在「看车钩」这一步，根本还没打开车厢看货。**

```
push 的检查顺序：

   ① 你的车钩链里有没有我车尾那一节？   ← ❌ 卡在这里
   ② 车厢里装的是什么货？                ← 根本走不到这一步
```

**所以：就算你造的车厢里装的是一块全新的砖（新文件 `git-全流程地图.md`），只要车钩接不上，照样拒绝。**

**实证：**

```
车辆段 A 造了「文件A」车厢 → push ✅
车辆段 B 造了「文件B」车厢 → push ❌ rejected
                                ↑ 两个货毫无关系，一样拒绝
```

### B.5 拒绝之后发生了什么：rebase = 换车钩重印编号

**你做的：**

```bash
git pull --rebase origin main
```

**火车语言：**

```
① fetch      把对方新造的 [103c89b] 车厢取回来
② checkout   把自己的车头先挂到 [103c89b] 上
③ 卸货        把 [e96bbb5] 车厢里的货（你的改动）卸下来
④ 重造        造一节新车厢，车钩挂在 [103c89b] 上
              → 因为车钩变了，编号必须重算 → 366fe56
⑤ 装货        把卸下来的货装进去
⑥ 挂车头      车头 main 挂到 [366fe56]
```

**结果：**

```
[972722e] ─▶ [103c89b] ─▶ [366fe56]
                            ↑ 新的车厢，编号不同，货车相同
```

**这就是为什么 `e96bbb5` 变成了 `366fe56`：**

```
车厢编号 = f(货物清单 + 前一节车厢的编号)

前一节从 972722e 改成 103c89b
→ 编号必然不同
→ 但里面的货一模一样（外加那一节带上来的 README 改动）
```

### B.6 两种"收口"方式：rebase vs merge

```
【pull --rebase】→ 一条直线（你用的）
     [972722e] ─▶ [103c89b] ─▶ [366fe56]
                                   ↑ 你的货换了节车厢，痕迹消失

【pull（merge）】→ 保留分叉 + 造一个"双车钩"车厢
     [972722e] ─▶ [103c89b] ─┐
              └▶ [e96bbb5] ──┴▶ [M]    ← M 有两个车钩，同时勾住两条线
                                   ↑ 你的车厢保持原样，编号不变
```

**"允许两节车厢并存"是 merge 的世界。rebase 选择的是"不留痕迹"。**

### B.7 关键区别：分叉 ≠ 冲突

| 概念 | 火车语言 | 你的情况 |
|---|---|---|
| **分叉（diverged）** | 两个车辆段从**同一节车厢**各自往后造 | ✅ 发生了 |
| **冲突（conflict）** | 两个车辆段给**同一节车厢装了不同的货** | ❌ 没发生 |

**你的两次改动分别在 `README.md` 和 `git-全流程地图.md`，是不同的货 → 换车钩时零冲突，丝滑通过。**

### B.8 下次遇到这些提示，这样想

| git 提示 | 火车语言 | 你该做什么 |
|---|---|---|
| `! [rejected] (fetch first)` | "车钩接不上，先取我的车厢" | `git pull --rebase` → `git push` |
| `Everything up-to-date` | "我这节你已经有了，没什么可挂" | 没新提交，正常 |
| `diverged` | "我们从同一个车厢分开了" | 同上，先 pull |
| `CONFLICT` | "同一节车厢的货打架了" | `git mergetool` 人工决定 |
| `Your branch is ahead by N` | "我比你多造了 N 节" | `git push` |
| `fast-forward` | "能直接接上，不用重造" | 无事，顺利 |

### B.9 一句话记住

> **push 不看你改了什么文件，只看你的车钩链能不能接到对方车尾。**
> **接不上就 fetch + 换车钩（rebase），别硬塞（push -f）。**

---

## 附录 C：我第一次 PR 的完整复盘（真实数据）

> 日期：2026-10-18｜结果：**PR #12 已创建**
> 地址：<https://github.com/OceanCing/missing-semester/pull/12>

### C.1 这次的真实数据

| 项目 | 值 |
|---|---|
| PR 编号 | #12 |
| 标题 | `Add lesson1 homework - DOSOMEACTIONS` |
| 方向 | `DOSOMEACTIONS:feat/DOSOMEACTIONS-lesson1` → `OceanCing:master` |
| 提交数 | 1 个（`9755655`）|
| 改动 | 3 个文件，+269 行 |
| 冲突 | 无 |
| 状态 | Open，可自动合并 |

**三个文件：**

```
2027/DOSOMEACTIONS/notes/lesson1-linux-vim-shell-git.md   +179
2027/DOSOMEACTIONS/homework/lesson1.sh                     +60
2027/DOSOMEACTIONS/homework/output.txt                     +30
```

### C.2 完整时序（每一步的真实命令）

```
【阶段一 · 准备】一次性
 ┌─────────────────────────────────────────────────────────┐
 │ ① 网页点 Fork                                           │
 │    OceanCing/missing-semester                           │
 │              ↓                                          │
 │    DOSOMEACTIONS/missing-semester                       │
 └─────────────────────────────────────────────────────────┘
                          ↓
 ② git clone git@github.com:DOSOMEACTIONS/missing-semester.git
                          ↓
 ③ git remote add upstream git@github.com:OceanCing/missing-semester.git
                          ↓
 ④ git switch -c feat/DOSOMEACTIONS-lesson1


【阶段二 · 干活】每次作业
 ┌─────────────────────────────────────────────────────────┐
 │ ⑤ 建目录                                                │
 │    mkdir -p 2027/DOSOMEACTIONS/notes \                  │
 │               2027/DOSOMEACTIONS/homework               │
 └─────────────────────────────────────────────────────────┘
                          ↓
 ⑥ 写文件
    notes/lesson1-linux-vim-shell-git.md       ← 笔记
    homework/lesson1.sh                        ← 脚本
                          ↓
 ⑦ 跑脚本生成产物
    cd 2027/DOSOMEACTIONS/homework && ./lesson1.sh
    → 生成 output.txt
                          ↓
 ⑧ 检查 + 暂存
    git status -sb              （我在什么状态）
    git add 2027/DOSOMEACTIONS  （挑进暂存区）
    git review                  （确认 3 个文件）
                          ↓
 ⑨ 提交
    git commit -m "Add lesson1 notes and homework script."
                          ↓
 ⑩ 推到自己 fork
    git push -u origin feat/DOSOMEACTIONS-lesson1


【阶段三 · 交付】
 ┌─────────────────────────────────────────────────────────┐
 │ ⑪ 网页开 PR，四个框填对                                  │
 │    base repository: OceanCing/missing-semester           │
 │    base:            master                              │
 │    head repository: DOSOMEACTIONS/missing-semester       │
 │    compare:         feat/DOSOMEACTIONS-lesson1           │
 │                                                         │
 │    ✓ Able to merge（出现这句 = 无冲突）                  │
 └─────────────────────────────────────────────────────────┘
                          ↓
 ⑫ 老师 review → 有评论 → 本地改 → commit → push
    （PR 自动更新，不用重开）
                          ↓
    老师点 Merge ✅
```

### C.3 我这次踩过的 10 个坑

| # | 错误 | 现象 | 正确做法 |
|---|---|---|---|
| 1 | `git commit -m` 后面不加引号 | 提交信息变成文件名 `git-全流程地图.md` | `-m "说明文字"` 必须加引号 |
| 2 | `git push 文件名` | `fatal: 无效的 gitfile 格式` | `git push` 只接「远程名 + 分支名」，不接文件 |
| 3 | `git commit` 不带 `-m` | 打开 vim 写说明，直接关了 → `提交说明为空，中止提交` | 加 `-m`；或在 vim 里写一行（不以 `#` 开头）再 `:wq` |
| 4 | 在 GitHub 网页改 README | 远程多一个提交 → push 被拒 `fetch first` | 只在本地改；网页改了就 `git pull --rebase origin main` |
| 5 | `git checkout -- 文件` | **不可恢复**，把一整节内容弄丢了 | 用 `git stash push -m "说明"`（可恢复）或 `git restore` |
| 6 | `git restore git- 四阶段地图.md`（中间有空格） | git 当成两个路径，命令失败 | 文件名不能有空格，用 `Tab` 补全 |
| 7 | 编辑器里还开着旧版本 | **复制了新版，编辑器一保存又变回旧版** | **复制前先关编辑器**；复制后 `wc -l` 验证 |
| 8 | Markdown 表格列数不齐 | `\|jk\| 代替 Esc\|` 是 2 列，表头 3 列 → 渲染错乱 | 每行竖线数量必须一致 |
| 9 | 正文塞进代码块 | 三条命令写在 ``` 里面，看起来像代码 | 只有真正的代码/命令才放进 ``` |
| 10 | API key 写进笔记并推上公开仓库 | 暴露 40 天 | 立刻作废 key；`.env` 写进 `.gitignore` |

### C.4 下次做同样的事，直接抄这段

```bash
# ========== 一次性（每学期只用做一次）==========
# 网页：Fork github.com/OceanCing/missing-semester
git clone git@github.com:DOSOMEACTIONS/missing-semester.git
cd missing-semester
git remote add upstream git@github.com:OceanCing/missing-semester.git
git switch -c feat/DOSOMEACTIONS-lesson2

# ========== 干活 ==========
mkdir -p 2027/DOSOMEACTIONS/notes 2027/DOSOMEACTIONS/homework
# 写文件…
./2027/DOSOMEACTIONS/homework/lesson2.sh

# ========== 提交 ==========
git status -sb
git add 2027/DOSOMEACTIONS
git review
git commit -m "Add lesson2 notes and homework script."
git push -u origin feat/DOSOMEACTIONS-lesson2

# ========== 网页开 PR ==========
# base repository: OceanCing/missing-semester
# base:            master
# head repository: DOSOMEACTIONS/missing-semester
# compare:         feat/DOSOMEACTIONS-lesson2
```

### C.5 三句话记住整件事

1. **Fork 是复制到我的账号，Clone 是下载到我电脑，Branch 是我在电脑上开的开发线。**
2. **`push` 只推到我的 fork，永远不会直接改老师的仓库。**
3. **PR 是「请求」不是「提交」—— 老师点了 Merge 才算真的进去。**

### C.6 如果老师留了评论要改

```bash
# ① 本地改文件
vim 2027/DOSOMEACTIONS/notes/xxx.md

# ② 照常提交推送
git add 2027/DOSOMEACTIONS
git commit -m "Fix formatting in notes."
git push

# ③ PR 自动更新 —— 不需要关掉重开
```

**⚠️ TASK.md 第 9 条明确写了：用 Close PR 再重开的方法规避 Conflict 会被扣分。**
