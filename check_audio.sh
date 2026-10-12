#!/bin/bash

# =================================================================
# 脚本名称: Audio Sampling Rate Checker & Configurator (Fixed)
# 功能描述: 检测 WirePlumber 下音频 Sink 是否达到 192kHz，
#           若未达到，则自动初始化或引导用户修改配置文件。
# =================================================================

# --- 颜色定义 (增强视觉反馈) ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- 配置区 ---
if command -v pactl &> /dev/null; then
    PACTL_PATH="pactl"
else
    echo -e "${RED}Error: pactl not found. Please run 'sudo apt install pulseaudio-utils'${NC}"
    exit 1
fi

CONFIG_DIR="$HOME/.config/wireplumber/main.lua.d"
CONFIG_FILE="$CONFIG_DIR/51-alsa-custom.lua"
TARGET_RATE="192000"

# --- 函数：执行查询逻辑 ---
check_sampling_rate() {
    echo -e "${BLUE}--------------------------------------------------${NC}"
    echo -e "${BLUE}正在检索当前音频 Sink 状态...${NC}"
    
    if ! $PACTL_PATH list sinks &> /dev/null; then
        echo -e "${RED}[❌ 错误] 无法执行 pactl 命令，请检查路径是否正确：$PACTL_PATH${NC}"
        return 1
    fi

    OUTPUT=$($PACTL_PATH list sinks)
    
    if echo "$OUTPUT" | grep -q "$TARGET_RATE"; then
        echo -e "${GREEN}[✅ 状态：正常]${NC}"
        echo -e "${GREEN}已检测到 ${TARGET_RATE}Hz 采样率支持。${NC}"
        echo -e "${BLUE}--------------------------------------------------${NC}"
        return 0 
    else
        echo -e "${RED}[❌ 状态：异常]${NC}"
        echo -e "${RED}未发现 ${TARGET_RATE}Hz 采样率！当前设备可能运行在较低频率。${NC}"
        echo -e "${BLUE}--------------------------------------------------${NC}"
        return 1 
    fi
} # <--- 这里是函数结束的地方

# --- 函数：显示修改指南 ---
show_guide() {
    echo ""
    echo -e "${YELLOW}📖 【配置修改指南】${NC}"
    echo "--------------------------------------------------"
    echo -e "${BLUE}步骤 1:${NC} 找出目标设备的 ID"
    echo -e "   请在终端运行: ${YELLOW}wpctl status${NC}"
    echo "   在 'Audio -> Sinks' 列表中找到你的输出设备 ID。"
    echo ""
    echo -e "${BLUE}步骤 2:${NC} 获取设备的完整名称"
    echo -e "   假设 ID 是 49，请运行: ${YELLOW}wpctl inspect 49${NC}"
    echo "   在输出中寻找 'device.name' 或 'node.name' 的值。"
    echo ""
    echo -e "${BLUE}步骤 3:${NC} 编辑配置文件"
    echo -e "   请确保配置文件中的 \"node.name\" 与你查到的名称一致。"
    echo "--------------------------------------------------"
    echo ""
}

# --- 主逻辑流程 ---

# 1. 首次检查
check_sampling_rate
STATUS=$?

if [ $STATUS -eq 1 ]; then
    # 2. 显示详细的修改方法指南
    show_guide

    # 3. 确保配置目录存在
    if [ ! -d "$CONFIG_DIR" ]; then
        echo -e "${YELLOW}正在创建配置目录: $CONFIG_DIR${NC}"
        mkdir -p "$CONFIG_DIR"
    fi

    # --- 检查文件是否存在或是否为空，并填充默认代码 ---
    DEFAULT_LUA_CONTENT=$(cat <<EOF
rule = {
  matches = {
    {
      { "node.name", "matches", "alsa_output.pci-0000_00_1f.3.analog-stereo" },
    },
  },
  apply_properties = {
      ["node.description"]       = "Laptop Built-in Speaker",
      ["audio.format"]           = "S32LE",
      ["audio.rate"]             = 192000
  },
}
table.insert(alsa_monitor.rules,rule)
EOF
)

    if [ ! -s "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}检测到配置文件不存在或内容为空，正在自动写入默认配置模板...${NC}"
        echo "$DEFAULT_LUA_CONTENT" > "$CONFIG_FILE"
        echo -e "${GREEN}模板已成功写入: $CONFIG_FILE${NC}"
    else
        echo -e "${BLUE}检测到配置文件已存在且有内容，准备进入编辑模式...${NC}"
    fi

    # 4. 打开编辑器
    echo -e "${BLUE}🚀 正在为您打开配置文件: $CONFIG_FILE${NC}"
    if command -v gnome-text-editor &> /dev/null; then
        gnome-text-editor "$CONFIG_FILE"
    elif command -v gedit &> /dev/null; then
        gedit "$CONFIG_FILE"
    else
        nano "$CONFIG_FILE"
    fi

    # 5. 编辑器关闭后，提示重启服务
    echo ""
    echo -e "${YELLOW}==================================================${NC}"
    echo -e "${YELLOW}⚠️  配置已保存。为了使更改生效，请执行以下命令：${NC}"
    echo -e "${GREEN}👉 systemctl --user restart wireplumber.service${NC}"
    echo -e "${YELLOW}==================================================${NC}"
    echo ""
    
    # 6. 询问用户是否现在立即重启并重新检查
    read -p "是否立即尝试重启服务并重新检测？(y/n): " choice
    case "$choice" in 
      [yY][eE][sS]|[yY]) 
        echo -e "${BLUE}正在重启 WirePlumber...${NC}"
        systemctl --user restart wireplumber.service
        sleep 2 # 等待服务完全启动
        echo -e "${BLUE}正在进行二次验证...${NC}"
        check_sampling_rate
        ;;
      *)
        echo -e "${YELLOW}已取消自动重启。请手动执行命令以生效。${NC}"
        ;;
    esac
fi

echo ""
read -n 1 -s -p '按任意键退出...'

