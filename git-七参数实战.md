# Git 参数地图 + 今日错题（2026-10-23）

> 本文分两半：
> **前半 = 地图**（怎么读命令、参数分几类、流程里什么时候出来）
> **后半 = 错题**（今天真实撞的 10 个坑，每题配代码）
>
> 读法：先看图 1~6 建立框架，再看错题。**错题里每条都是我真敲过的。**

---

# 第一部分 · 地图

## 图 1 · 一条命令的解剖

```
    git    commit    -m    "说明"    --amend
     │       │        │      │          │
     │       │        │      │          └─ ④ 长选项：两个短横 + 完整单词
     │       │        │      └─ ③ 参数值（空格分隔）
     │       │        └─ ② 短选项：一个短横 + 单字母
     │       └─ ① 子命令
     └─ 程序
```

### 六条语法规则

```
①  -x        短选项，一个短横 + 单字母          -m  -u  -b  -p
②  --xxx     长选项，两个短横 + 单词           --amend  --all
③  -abc      短选项可合并                      -sb = -s -b
④  --xx=值   长选项用等号传参                  --zoom=2.5
⑤  --        单独两个短横 = 分隔符
              后面全当文件名，不再当选项         git checkout -- 文件
⑥  顺序      选项一般在子命令后
```

**⚠️ 规则 ⑤ 最容易踩：**

```bash
git checkout -- 文件     # ✅ -- 后面是文件名
git checkout 文件        # ⚠️ 有歧义，git 可能以为是分支
```

---

## 图 2 · 命令全景（按"我想干什么"查）

```
                         ┌── 我在什么状态？
                         │     status -sb
                         │     log --oneline --graph --all
                         │     diff / diff --cached / show --stat
                         │
                         ├── 改完要提交
                         │     add <路径>
                         │     commit -m "..."
                         │     commit --amend --no-edit   （改上一次）
                         │
   我 想 做 什 么  ──────┼── 和远程同步
                         │     pull --rebase
                         │     push -u / --force-with-lease
                         │     fetch / --prune / --unshallow
                         │
                         ├── 换分支 / 看分支
                         │     switch -c 新建
                         │     branch -vv 看跟踪
                         │     branch -r 看远程
                         │     branch -D 强删
                         │
                         ├── 撞冲突了
                         │     改文件 → add → rebase --continue
                         │     rebase --abort  ← 逃跑
                         │
                         └── 搞砸了
                               restore <文件>
                               stash
                               reset --hard  ← 危险
```

---

## 图 3 · Flag 速查（按用途 + 词源）

### A 组 · 精简输出

| Flag | 全称 | 意思 | 记忆锚点 |
|---|---|---|---|
| `--oneline` | — | 一个提交一行 | one line = 一行 |
| `-s` / `--short` | short | 简洁格式 | short = 短 |
| `-b` / `--branch` | branch | 显示分支名 | |
| `-sb` | `-s` + `-b` | 合并写法 | s 和 b |
| `--stat` | statistics | 改动统计 | stat = 统计 |
| `-p` / `--patch` | patch | 显示具体改动 | patch = 补丁 |
| `--graph` | — | 画成图 | graph = 图 |
| `-vv` | very verbose | 带跟踪关系 | 两个 v = 更详细 |

### B 组 · 范围

| Flag | 全称 | 意思 | 注意 |
|---|---|---|---|
| `--all` | — | 所有分支 | 配 `--graph` 才有意义 |
| `-a` | all | 看命令而定 | `branch -a` 全是分支；`commit -a` 是所有已跟踪文件 |
| `-r` | remotes | 只看远程分支 | r = remote |
| `--cached` | — | 已暂存的 | 和 `--staged` 同义 |

### C 组 · 同步与推送

| Flag | 全称 | 意思 | 记忆锚点 |
|---|---|---|---|
| `-u` | `--set-upstream` | 建立跟踪关系 | u = upstream |
| `--force-with-lease` | force with lease | 带检查的强推 | lease = 租约 |
| `-f` / `--force` | force | 无检查强推 | ⚠️ 危险 |
| `--prune` | — | 清掉失效引用 | prune = 修剪 |
| `--rebase` | re + base | 变基代替合并 | re-base = 换底座 |
| `--unshallow` | un + shallow | 解除浅克隆 | shallow = 浅 |

### D 组 · 修复与冲突

| Flag | 全称 | 意思 | 记忆锚点 |
|---|---|---|---|
| `--amend` | amend | 修改上一个提交 | amend = 修正 |
| `--no-edit` | — | 不打开编辑器 | 配 amend |
| `--continue` | — | 继续 rebase | |
| `--abort` | — | 放弃，回到冲突前 | abort = 中止 |
| `--skip` | — | 跳过这个提交 | |
| `-i` | interactive | 交互式 | i = interactive |
| `--hard` | — | 硬重置 | ⚠️ 不可恢复 |
| `-D` | `-d --force` | 强制删分支 | 大写 = 狠 |

---

## 图 4 · 流程里 flag 的出场顺序

```
① 克隆       git clone <url>
② 加遥控     git remote add upstream <url>
③ 确认       git remote -v
④ 建分支     git switch -c feat/xxx
⑤ 看状态     git status -sb
⑥ 挑改动     git add <路径>
⑦ 复查       git diff --cached          ← 提交前必看
⑧ 提交       git commit -m "..."
⑨ 推送       git push -u origin feat/xxx
                  │
        ┌─────────┴─────────┐
        │ 远程有新东西了      │
        └─────────┬─────────┘
⑩ 同步       git pull --rebase upstream master
⑪ 冲突       git status                → 看哪些文件
             vim 文件                  → 删整行标记
             git add 文件              → 标记为已解决
             git rebase --continue     → 继续
⑫ 强推       git push --force-with-lease
                  │
        ┌─────────┴─────────┐
        │ 搞砸了 / 想反悔    │
        └─────────┬─────────┘
⑬ 逃跑       git rebase --abort        （rebase 中途）
             git reset --hard <hash>   （已提交）
             git stash                 （先存起来）
```

---

## 图 5 · 最容易混淆的 6 组

### ① `-f` vs `--force-with-lease`

```
-f                 = 不管远程是啥，覆盖
--force-with-lease = 远程和我记录的一样才覆盖
```

### ② `--cached` vs `--staged`

```
两个名字指同一个东西（历史原因）
```

### ③ `-a` 在不同命令里

```
git branch -a    = 所有分支（含远程）
git commit -a    = 自动 add 所有【已跟踪】文件
```

### ④ `-s` 在不同命令里

```
git status -s        = short（简洁）
git commit -s        = signoff（加签名，不是 short）
git log -S"关键词"   = 大写 S，搜代码增删该字符串的提交
```

### ⑤ `-u` 在不同命令里

```
git push -u   = set-upstream（建立跟踪）
git add -u    = update（只更新已跟踪文件）
```

### ⑥ `-v` vs `-vv`

```
git branch -v    = 分支 + 最新提交
git branch -vv   = 再加上【跟踪哪个远程 + 领先/落后】
```

---

## 图 6 · 一句话记忆卡

```
┌─────────────────────────────────────────────────────┐
│  -u        建立跟踪（upstream）      ← push 时用     │
│  --all     看所有分支                ← 配 --graph    │
│  --amend   修改上一次提交            ← 配 --no-edit  │
│  --force-with-lease  安全强推        ← rebase 后用   │
│  --prune   清掉失效的远程引用        ← fetch 时用    │
│  --unshallow 补全历史                ← 一次性        │
│  --cached  看暂存区                  ← diff 时用     │
│  --  （两个横） 后面是文件名          ← 分隔符        │
└─────────────────────────────────────────────────────┘
```

---

# 第二部分 · 今日错题（10 题，题配代码）

> 每题格式：**场景 → ❌ 我敲了什么 → 现象 → ✅ 正确做法 → 教训**

---

## 错题 1 · 冲突标记只删了前缀

**场景：** rebase 冲突，要保留团队那一行。

**❌ 我敲的（用 vim 编辑时）：**

```
<<<<<<< HEAD
8. TASK.md 会更新（第二课已加入），PR 可能冲突，必须正确处理
||||||| parent of 94cd54d
8. TASK.md 会更新，可能出现 Conflict
=======
8. TASK.md 会更新，可能出现 Conflict（我已学会 rebase 处理）
>>>>>>> 94cd54d
```

我只删了 `<<<<<<< ` 这几个符号，留下 `HEAD` 三个字母。

**现象：**

```bash
grep -c "<<<<<<<" TASK.md    # 输出 0，看起来"干净了"
```

但文件实际长这样：

```
HEAD                                  ← 残留
8. TASK.md 会更新（第二课已加入）...
parent of 94cd54d (Update notes...)   ← 残留
8. TASK.md 会更新，可能出现 Conflict
8. TASK.md 会更新，可能出现 Conflict（我已学会...）
94cd54d (Update notes on conflict handling.)   ← 残留
```

**✅ 正确做法：删整行**

```bash
# 用这些命令检查残留（比只查 <<<<<<< 可靠）
grep -n -E "^HEAD$|^parent of|^[0-9a-f]{7} \(" 文件
grep -c "^8\." 文件        # 该是 1
wc -l 文件                 # 对一下行数
```

**教训：冲突标记是**整行**，不是前缀。`grep "^<<<<<<<"` 查不出残字。**

---

## 错题 2 · rebase 中用了 `git commit`

**场景：** 冲突改完了，想"提交一下"。

**❌ 我敲的：**

```bash
git commit
```

**现象：**

```
[分离头指针 445e0b9] Update notes on conflict handling.
 1 file changed, 6 insertions(+)       ← 6 行？我只改了 1 行！

git push
fatal: 您当前不在一个分支上。
```

**原因：**

```
rebase 进行中，HEAD 是【分离】的（没贴在任何分支上）
git commit 会创建一个没人指向的提交
而且提交内容 = 暂存区当时的状态（可能带着冲突标记）
```

**✅ 正确做法：**

```bash
git add 冲突文件            # 标记为"已解决"
git rebase --continue      # 让 git 自己创建提交
```

**教训：**

- rebase 中**不要** `git commit`
- 判断方法：`git status` 第一行如果是"分离头指针" → 你在 rebase 中途
- `X insertions` 数字异常大 → 停下来查

---

## 错题 3 · `--git-dir=~/xxx` 不展开 `~`

**场景：** 想直接操作裸仓库（模拟"队友删分支"）。

**❌ 我敲的：**

```bash
git --git-dir=~/git-flags-lab/team.git branch -D feat/bob
```

**现象：**

```
fatal: 不是 Git 仓库：'~/git-flags-lab/team.git'
```

**原因：** bash 的 `~` 只在**词首**展开。

```
git --git-dir=~/xxx
                └─ 这里 `~` 在 `=` 后面，不是词首 → 不展开
                   git 收到字面量 "~/xxx" → 找不到
```

**✅ 正确做法：**

```bash
git --git-dir="$HOME/git-flags-lab/team.git" branch -D feat/bob
# 或
git --git-dir=/home/heifeiyang/git-flags-lab/team.git branch -D feat/bob
```

**验证：**

```bash
echo ~                    # 展开
echo --x=~                # 不展开
echo "--x=$HOME"          # 展开
```

---

## 错题 4 · `cp -a` 复制仓库后，origin 还指旧路径

**场景：** 把沙盘从工作区复制到家目录练手。

**❌ 我以为：** 复制过来的仓库 origin 应该指向新的 team.git。

**现象：**

```bash
cd ~/git-flags-lab/alice
git remote -v
```

```
origin  /home/heifeiyang/Applications/D:\myharness/git-flags-lab/team.git
        └─ 还指着【工作区】的原位置！
```

结果：

```
所有 push 都进了工作区那个 team.git
我自己的 ~/git-flags-lab/team.git 一直没更新
→ 在错误的仓库里 branch -D feat/bob，当然没效果
```

**✅ 正确做法：**

```bash
# 复制后第一件事
git remote -v

# 如果指着旧路径
git remote set-url origin "$HOME/git-flags-lab/team.git"
git push -u origin 分支名        # 重推一遍
```

**教训：`cp -a` 会连 `.git/config` 一起复制，里面的绝对路径不会自动改。**

---

## 错题 5 · `--force-with-lease` 报 `stale info`

**场景：** rebase 后要强推。

**❌ 我敲的：**

```bash
git push --force-with-lease -u origin feat/xxx
```

**现象：**

```
! [rejected]  feat/xxx -> feat/xxx (stale info)
```

**原因：**

```
--force-with-lease 的工作方式：
    ① 读本地缓存的 origin/feat/xxx
    ② 拿它和远程真实值比对
    ③ 一样 → 允许；不一样/读不到 → 拒绝

我的本地没有这个引用 → 第 ① 步失败 → 拒绝
```

**✅ 正确做法：先 fetch 补"抵押品"**

```bash
git fetch origin
git branch -r                      # 确认 origin/feat/xxx 出现了
git push --force-with-lease -u origin feat/xxx
```

**教训：`--force-with-lease` 需要"上次看到的远程状态"当抵押品。没抵押 → 拒绝。**

**备选（知道就行）：**

```bash
git push --force-with-lease=feat/xxx:9755655 -u origin feat/xxx
#                          分支名:我认为的远程hash
```

---

## 错题 6 · fetch 了，但 `branch -r` 还是看不到

**场景：** fetch 完想看远程分支。

**❌ 我敲的：**

```bash
git fetch origin
git branch -r
```

**现象：** fetch 输出里有：

```
 * branch   feat/xxx -> FETCH_HEAD      ← 只进了 FETCH_HEAD
```

但 `branch -r` 里**没有** `origin/feat/xxx`。

**原因（查出来的）：**

```bash
git config --get-all remote.origin.fetch
# +refs/heads/master:refs/remotes/origin/master
```

**refspec 只映射了 master！** 这是 `git clone --depth 1` 留下的（隐含 `--single-branch`）。

**✅ 正确做法：修 refspec**

```bash
git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
git fetch origin
git branch -r                       # 现在有了
```

**教训：**

```
git fetch --unshallow 只补【历史深度】，不改【跟踪范围】
refspec 正常应该是  +refs/heads/*:refs/remotes/origin/*
```

---

## 错题 7 · `git add` 了一个仓库外的文件

**场景：** 想给提交加个测试文件。

**❌ 我敲的：**

```bash
echo "test" > /tmp/t.txt
git add /tmp/t.txt
git commit
```

**现象：**

```
git add 静默失败（或报 not under version control）
git commit → 无文件要提交，工作区干净
```

**原因：** **git 只能跟踪仓库目录内的文件。**

**✅ 正确做法：**

```bash
cd 仓库目录
echo "test" > note.txt        # 建在仓库内
git add note.txt
git commit -m "Add test note."
```

**教训：`git add` 的路径必须在仓库工作区内。**

---

## 错题 8 · 提交信息格式（空格 + 句号）

**场景：** 写提交说明。

**❌ 我写的：**

```
docs(demo&note):Both of them are rubbish .
```

**三个问题：**

```
① 冒号后没空格        docs(...):Both  →  docs(...): Both
② 句号前有空格        rubbish .       →  rubbish.
③ 内容描述"评价"不是"改动"
```

**✅ 作业要求：全英文 + 首字母大写 + 句号结尾**

```
Add demo and note files for template testing.
```

**✅ 队伍内部（Conventional，可选）：**

```
docs(demo): Add demo and note files.
```

**自检命令：**

```bash
git log -1 --format=%s
```

**判断法：写之前问自己"一个月后只看到这句话，能知道改了什么吗？"**

---

## 错题 9 · `rebase --continue` 时误改了提交说明

**场景：** 解决冲突后继续 rebase。

**❌ 我做了什么：** `git rebase --continue` 弹出了编辑器，我顺手改了内容。

**现象：** 原来的提交说明变成了新的：

```
原: Update README with my status.
新: Docs:(Has finished Deepseek's mission.)
```

**原因：**

```
rebase --continue 会为每个被重放的提交弹编辑器确认说明
（因为 rebase 会重写提交）
```

**✅ 正确做法：**

```bash
# 想保留原说明 → 直接保存退出，什么都别改
git rebase --continue

# 或者干脆不弹编辑器
GIT_EDITOR=true git rebase --continue
```

**教训：rebase 过程中的编辑器不是"给我改说明"，是"确认说明"。不改就存退。**

---

## 错题 10 · 概念错：`status` 干净 = 没做事？

**场景：** commit 完还没 push，`git status` 什么都没显示。

**❌ 我以为：** 我的提交不见了。

**现象：**

```bash
git status -sb
## feat/exercise
```

**真相：**

```
git status 只比较【三个本地状态】：
    工作区 ↔ 暂存区 ↔ 本地最新提交
它【不跟远程比】！

但它会显示"领先/落后"——前提是【配置了跟踪关系】
我的分支没配跟踪（没 -u 过）→ 连这个都不显示
```

**✅ 查未推送的提交：**

```bash
git log @{u}..HEAD --oneline            # 有上游时
git log origin/main..HEAD --oneline     # 没上游时
```

**✅ 确认提交确实存在：**

```bash
git log --oneline -3
git show --stat HEAD
git ls-files
```

**教训：**

```
status 干净 ≠ 没做事
status   = 现在有没有待办
log      = 过去做了什么
ls-files = 仓库里有哪些文件
```

---

# 第三部分 · 自测 10 题

**不查资料，先自己答，再看下面的答案。**

```bash
1.  git status -sb
2.  git log --oneline --graph --all
3.  git push -u origin feat/xxx
4.  git commit --amend --no-edit
5.  git fetch --prune
6.  git diff --cached
7.  git rebase --abort
8.  git push --force-with-lease
9.  git rev-parse --is-shallow-repository
10. git branch -vv
```

---

## 答案

**1. `git status -sb`**

- `-s` = short（简洁）
- `-b` = branch（显示分支名）
- 输出 `## 分支...origin/分支`，有数字才表示领先/落后
- **不跟远程实时比，比的是本地缓存**

**2. `git log --oneline --graph --all`**

- `--oneline` 一行一个提交
- `--graph` 画分叉
- `--all` **所有分支**（不只当前）
- 三个一起才看得到"分叉"

**3. `git push -u origin feat/xxx`**

- 推送到 origin 的 feat/xxx
- `-u` = set-upstream，建立跟踪关系
- 之后 `git push` 不用带参数，`status` 也能显示领先/落后

**4. `git commit --amend --no-edit`**

- 用暂存区内容**替换**上一个提交
- `--no-edit` 不打开编辑器，沿用原说明
- 提交数量不变

**5. `git fetch --prune`**

- fetch：下载远程更新（不合并）
- `--prune`：删掉"远程已不存在"的本地引用
- 输出 ` - [已删除] -> origin/xxx`

**6. `git diff --cached`**

- 比较**暂存区 vs 上次提交**
- `git add` 之后就靠它看"准备提交什么"
- 和 `git diff`（工作区 vs 暂存区）互补

**7. `git rebase --abort`**

- 放弃整个 rebase，回到开始前
- 只在 rebase 进行中有效
- 安全绳，随便用

**8. `git push --force-with-lease`**

- 强推，但先检查"远程是否被我之外的人改过"
- 改过 → 拒绝；没改过 → 覆盖
- **需要本地有 origin/分支 引用当抵押品**，否则 stale info

**9. `git rev-parse --is-shallow-repository`**

- `rev-parse` = 解析引用
- 判断是不是浅克隆，输出 `true` / `false`
- 浅克隆会导致 rebase 找不到共同祖先

**10. `git branch -vv`**

- 分支名 + 最新提交 + **跟踪的远程分支**
- 有 `[origin/xxx: 领先 2]` 说明该 push
- 有 `[origin/xxx: 落后 3]` 说明该 pull
- 没中括号 = 没跟踪

---

# 第四部分 · 一句话总结

```
-u                 建立跟踪
--rebase           换底座（冲突就发生在这）
--abort            逃跑
--continue         继续（前面必须先 add）
--force-with-lease 安全强推（要先有抵押品）
--prune            剪枯枝
-vv / -sb / --all / --cached / --amend   看清楚再动手
```
