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
