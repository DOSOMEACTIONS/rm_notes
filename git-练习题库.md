# git & GitHub 练习题库

> 用法：先答完再看答案。答错的题标出来，第二天重做一遍。
> 难度：★ 入门 / ★★ 进阶 / ★★★ 场景判断

---

## 第一组：基础概念（★）

### 1. `git status` 的三种状态
`git status` 输出里，文件可能出现在这几个区域：
- "Changes not staged for commit"（红色）
- "Changes to be committed"（绿色）
- "Untracked files"

**问：这三个区域分别叫什么？一句话说清区别。**

### 2. 三个 diff 的区别
```bash
git diff
git diff --cached
git diff HEAD
```
**问：这三个命令分别看的是什么？**

### 3. 提交后能改吗
你 `git commit` 之后，发现提交信息写错了（漏了一个文件）。
**问：还能补救吗？用什么命令？**（提示：不需要 `--amend`，还有别的）

---

## 第二组：危险操作（★★）

### 4. 丢掉修改的三种做法
```bash
git checkout -- 文件
git restore 文件
git stash push -m "说明" 文件
```
**问：这三个有什么区别？哪个最安全？为什么？**

### 5. 分支会不会丢改动
```bash
git checkout -b tune/yaw-pid
# 改 gimbal.yaml，commit
git checkout master
```
**问：切回 master 后，你刚才改的东西还在吗？在哪？**

---

## 第三组：场景判断（★★★）

### 6. 一次改动，几个提交
你一个下午做了三件事：
- `serial.cpp` 修了校验和 bug
- `gimbal.yaml` 把 kp 从 3.0 调到 4.5
- `README.md` 补了两行说明

**问：应该提交几次？每次的命令和提交信息怎么写？为什么不能合成一次？**

### 7. 冲突怎么读
冲突标记：
```
<<<<<<< HEAD
    send_frame(target.yaw, 0.02);
||||||| merged common ancestors
    send_frame(target.yaw, 0.02);
=======
    send_frame(target.yaw, 0.04);
>>>>>>> origin/master
```
**问：**
a) `||||||| merged common ancestors` 这一段是什么？是谁加的？
b) 从这三段能看出"谁改了什么"？
c) 你最终怎么决定留哪个？

### 8. push 被拒
```
! [rejected]        master -> master (fetch first)
error: failed to push some refs
```
**问：这是什么意思？直接 `git push -f` 会怎样？正确做法是什么？**

---

## 第四组：工具对应（★★）

### 9. 四个工具的分工
`gh` / `tig` / `lazygit` / `delta`

**问：分别解决什么问题？哪些能替代命令行，哪些只是让输出好看？**

### 10. 提交信息的四个类型
`feat` / `fix` / `tune` / `refactor`

**问：分别什么时候用？下面这条属于哪类？**
```
tune(yaw): kp 3.0->4.5, 阶跃超调 18%->7%, 稳态误差 <0.3deg
```

---
---

# 答案（先答完再看！）

<details>
<summary>点开看答案</summary>

### 1. 三个区域
- **Changes not staged**（红）= 工作区改了，但还没 `git add`，**不会进本次提交**
- **Changes to be committed**（绿）= 已暂存，**下次 commit 会包含**
- **Untracked** = 新文件，git 从来没见过，**不 add 就永远不会提交**

**核心**：git 有个"暂存区"（staging area）夹在工作区和仓库之间。`git add` 不是"提交"，是"挑进这次提交"。

### 2. 三个 diff
- `git diff` → **工作区 vs 暂存区**（还没 add 的改动）
- `git diff --cached` → **暂存区 vs 最后一次提交**（即将提交的内容）**← 提交前最该看的**
- `git diff HEAD` → **工作区 vs 最后一次提交**（所有未提交的总和）

### 3. 补漏
```bash
git add 漏掉的文件
git commit --amend --no-edit     # 追加进上一个提交，信息不变
```
或改信息：`git commit --amend -m "新信息"`
**⚠️ 只在还没 push 时安全**；push 过再 amend 会导致历史分叉，需要强推。

### 4. 丢修改的三种做法
| 命令 | 安全性 | 说明 |
|---|---|---|
| `git checkout -- 文件` | ❌ 不可恢复 | 老写法，直接覆盖工作区 |
| `git restore 文件` | ❌ 不可恢复 | 现代等价写法，只是更清晰 |
| `git stash push -m "说明" 文件` | ✅ **可恢复** | 存进抽屉，`git stash pop` 拿回来 |

**最安全是 stash**。纪律不是"不犯错"，是"犯错能救回来"。

### 5. 分支会不会丢
**不会丢。** 改动在你新建的分支 `tune/yaw-pid` 上，那个分支还在。
`git checkout master` 只是切换工作区内容，分支本身和它的提交都不受影响。
找回：`git checkout tune/yaw-pid` 或 `git log --all --oneline` 找到它。

### 6. 三次提交
```bash
# 第一次：修 bug
git add serial.cpp
git commit -m "fix(serial): 校验和漏算 XOR 高 8 位"

# 第二次：调参
git add gimbal.yaml
git commit -m "tune(yaw): kp 3.0->4.5, 超调 18%->7%"

# 第三次：文档
git add README.md
git commit -m "docs: 补充构建步骤"
```

**为什么不能合成一次**：
- 出问题时能**单独回滚**（`git revert` 只撤调参，不撤 bug 修复）
- 别人 review 能**看懂每步意图**
- `git log` 是可读的历史，不是"今天干了一堆"
- 用 `git add -p` 或 lazygit 可以按块暂存

### 7. 冲突三段
a) `||||||| merged common ancestors` 是 **merge 基础版本**（双方共同祖先），由 `merge.conflictstyle=diff3` 加上的。默认只给两段，看不出"谁改的"。

b) 能看出：
- 原始是 `0.02`
- 你的（HEAD）还是 `0.02` —— **你没改**
- 对方的（origin/master）改成了 `0.04` —— **视觉组改的**

c) 判断点变成：**40ms 合理吗？** 去问视觉组或看他们提交信息（`git log origin/master -- serial.cpp`）。不是"选一边"，是"理解为什么改"。

### 8. push 被拒
`fetch first` = **远程有你本地没有的提交**（别人先推了），git 拒绝覆盖。

**`git push -f` 的后果**：强推会**覆盖掉别人的提交**，可能造成队友的工作丢失 → 在队里基本等于事故。

**正确做法**：
```bash
git pull --rebase origin master    # 把你本地提交接到远程最新之上
# 如果有冲突：解决 → git add → git rebase --continue
git push
```

### 9. 四个工具
| 工具 | 解决什么 | 性质 |
|---|---|---|
| `gh` | 建仓库/PR/issue，不开浏览器 | **替代网页操作** |
| `tig` | 全屏浏览提交历史和 diff | **替代 `git log`** |
| `lazygit` | 图形化暂存/提交/分支/推送 | **替代大部分 git 命令** |
| `delta` | diff 加行号和语法高亮 | **只美化输出** |

### 10. 提交类型
- `feat` 新功能
- `fix` 修 bug
- `tune` 调参（PID 增益、阈值、延时）
- `refactor` 重构（不改行为）

那条是 **`tune`** —— 因为改的是增益参数，不是功能也不是 bug。

</details>
