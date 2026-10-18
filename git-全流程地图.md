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

## 附录：你的当前进度（2026-10-18）

```
第 0 层
  ① 找仓库     ✅ github.com/OceanCing/missing-semester
  ② Fork       ✅ 已做
  ③ Clone      ✅ ~/missing-semester
  ④a upstream  ✅ 已加
  ④b 分支      ✅ feat/DOSOMEACTIONS-lesson1

第 1 层
  ⑤ 改文件     ⬜ 还没开始
  ⑥ add        ⬜
  ⑦ commit     ⬜
  ⑧ push       ⬜

第 2 层
  ⑨ 开 PR      ⬜
  ⑩ 看评论     ⬜
```

**DDL: 10月20日 23:59**

**下一步：进 `2027/DOSOMEACTIONS/` 建 `notes/` 和 `homework/`，开始写文件。**
