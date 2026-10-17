#!/bin/bash
# =============================================================
# check_env.sh —— RM 开发环境自检
# 作者: DOSOMEACTIONS
# 用途: 换新电脑 / 重装系统后，一条命令确认环境是否齐全
# 用法: ./check_env.sh          基础检查
#       ./check_env.sh --full   额外检查 GPU / Docker / 显示
# =============================================================

PASS=0
FAIL=0
WARN=0

ok()   { printf "  \033[32m[OK]\033[0m   %s\n" "$*"; PASS=$((PASS+1)); }
miss() { printf "  \033[31m[MISS]\033[0m %s\n" "$*"; FAIL=$((FAIL+1)); }
warn() { printf "  \033[33m[WARN]\033[0m %s\n" "$*"; WARN=$((WARN+1)); }
sec()  { printf "\n\033[1m=== %s ===\033[0m\n" "$*"; }

# ---- 1. 系统 ----
sec "系统"
echo "  发行版 : $(lsb_release -ds 2>/dev/null || echo 未知)"
echo "  内核   : $(uname -r)"
echo "  架构   : $(uname -m)"
echo "  主机名 : $(hostname)"
echo "  用户   : $(whoami)"
echo "  Shell  : $SHELL"

# ---- 2. 工具链 ----
sec "工具链"
for cmd in gcc g++ cmake make git python3 pip3 vim; do
    if command -v "$cmd" >/dev/null 2>&1; then
        ver=$("$cmd" --version 2>/dev/null | head -1)
        ok "$cmd  →  ${ver:0:52}"
    else
        miss "$cmd"
    fi
done

# ---- 3. 用户权限组 ----
sec "权限组（串口/相机必需）"
for g in dialout video plugdev sudo; do
    if id -nG 2>/dev/null | grep -qw "$g"; then
        ok "在 $g 组"
    else
        if [ "$g" = "dialout" ]; then
            miss "$g 组 —— 接飞控/串口会 Permission denied！"
            echo "         修复: sudo usermod -aG dialout \$USER  然后重新登录"
        else
            warn "不在 $g 组"
        fi
    fi
done

# ---- 4. 设备 ----
sec "设备节点"
found_dev=0
for pattern in /dev/ttyUSB* /dev/ttyACM* /dev/video*; do
    for d in $pattern; do
        [ -e "$d" ] || continue
        echo "  $d"
        found_dev=$((found_dev+1))
    done
done
[ "$found_dev" -eq 0 ] && echo "  (当前没有接入串口/相机设备 —— 未连接时正常)"

# ---- 5. 磁盘与内存 ----
sec "资源"
echo "  磁盘:"
df -h / 2>/dev/null | tail -1 | awk '{printf "    已用 %s / %s (%s)，可用 %s\n", $3, $2, $5, $4}'
AVAIL=$(df -BG / 2>/dev/null | tail -1 | awk '{print $4}' | tr -d 'G')
[ -n "$AVAIL" ] && [ "$AVAIL" -lt 20 ] 2>/dev/null && warn "根分区可用空间不足 20G"
echo "  内存:"
# 用 /proc/meminfo（永远是英文，不受 locale 影响）
awk '
  /^MemTotal:/      {mt=$2}
  /^MemAvailable:/  {ma=$2}
  /^SwapTotal:/     {st=$2}
  /^SwapFree:/      {sf=$2}
  END {
    if (mt) printf "    内存   总 %.1f GB，可用 %.1f GB\n", mt/1048576, ma/1048576
    if (st) printf "    交换   总 %.1f GB，空闲 %.1f GB\n", st/1048576, sf/1048576
  }
' /proc/meminfo

# ---- 6. 网络 ----
sec "网络"
if ping -c1 -W2 223.5.5.5 >/dev/null 2>&1; then
    ok "外网连通 (ICMP)"
else
    warn "ping 不通外网（校内常禁 ICMP，改用 HTTP 判断，见下）"
fi
GH_CODE=$(curl -s --max-time 12 -o /dev/null -w "%{http_code}" https://github.com 2>/dev/null)
case "$GH_CODE" in
    2*|3*) ok "GitHub 可访问 (HTTP $GH_CODE)" ;;
    000|"") warn "GitHub 连不上 —— 检查代理 / DNS" ;;
    *)     warn "GitHub 返回 HTTP $GH_CODE" ;;
esac

# ---- 7. git 配置 ----
sec "Git 配置"
NAME=$(git config --global user.name 2>/dev/null)
MAIL=$(git config --global user.email 2>/dev/null)
[ -n "$NAME" ] && ok "user.name  = $NAME" || miss "user.name 未设置"
[ -n "$MAIL" ] && ok "user.email = $MAIL" || miss "user.email 未设置"
if [ -f "$HOME/.ssh/id_ed25519" ] || [ -f "$HOME/.ssh/id_rsa" ]; then
    ok "SSH 密钥存在"
else
    warn "没有 SSH 密钥（用 HTTPS 或生成一个）"
fi

# ---- 8. --full 额外检查 ----
if [ "${1:-}" = "--full" ]; then
    sec "GPU"
    if command -v nvidia-smi >/dev/null 2>&1; then
        if nvidia-smi --query-gpu=name,driver_version --format=csv,noheader >/dev/null 2>&1; then
            nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader \
              | sed 's/^/  [OK]   /'
            PASS=$((PASS+1))
        else
            warn "nvidia-smi 失败（GPU 可能在低功耗状态）"
            echo "         唤醒: for d in 0000:01:00.0 0000:01:00.1; do echo on | sudo tee /sys/bus/pci/devices/\$d/power/control; done"
        fi
    else
        miss "nvidia-smi 不存在"
    fi

    sec "Docker"
    if command -v docker >/dev/null 2>&1; then
        ok "docker $(docker --version 2>/dev/null | awk '{print $3}' | tr -d ,)"
        if docker ps >/dev/null 2>&1; then
            ok "docker 免 sudo 可用"
        else
            warn "docker 需要 sudo（用户可能不在 docker 组，或未重新登录）"
        fi
    else
        miss "docker"
    fi

    sec "显示"
    echo "  显卡模式: $(prime-select query 2>/dev/null || echo 'N/A（非 NVIDIA 机器）')"
    echo "  内屏:"
    xrandr 2>/dev/null | grep -A1 " connected" | head -4 | sed 's/^/    /'
fi

# ---- 汇总 ----
printf "\n\033[1m=== 汇总 ===\033[0m\n"
printf "  \033[32m通过 %d\033[0m   \033[33m警告 %d\033[0m   \033[31m缺失 %d\033[0m\n" "$PASS" "$WARN" "$FAIL"
if [ "$FAIL" -eq 0 ]; then
    printf "\n  \033[32m环境完整，可以开搞。\033[0m\n"
else
    printf "\n  \033[33m有 %d 项缺失，按上面提示补齐。\033[0m\n" "$FAIL"
fi
exit "$([ "$FAIL" -eq 0 ] && echo 0 || echo 1)"
