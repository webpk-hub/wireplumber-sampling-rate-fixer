WirePlumber Audio Sampling Rate Checker & Configurator
A lightweight Bash utility to help Linux users ensure their audio sink is running at high sampling rates (e.g., 192kHz) via WirePlumber.

一个轻量级的 Bash 工具，旨在帮助 Linux 用户通过 WirePlumber 确保音频输出设备运行在高采样率（例如 192kHz）下。

⚠️ Disclaimer | 免责声明
Environment: Tested and verified on Ubuntu 24.04 LTS. Effectiveness on other distributions or desktop environments is unknown.
环境： 已在 Ubuntu 24.04 LTS 上测试并验证。在其他发行版或桌面环境下的有效性未知。

Code Origin: This script was generated with the assistance of AI (Large Language Models). It is provided "as-is" without any guarantee of perfection. Please review the code before running it on critical systems.
代码来源： 本脚本由 AI（大语言模型） 辅助生成。按“原样”提供，不保证完美无缺。在关键系统上运行前，请务必检查代码逻辑。

Usage: Primarily for personal use, but others are welcome to try and experiment at their own risk.
用途： 主要供个人使用，但也欢迎他人尝试，风险自担。

✨ Features | 功能特性
 Auto-Detection: Checks if the current audio sink supports the target sampling rate (192kHz).
 自动检测：检查当前音频 Sink 是否支持目标采样率 (192kHz)。
 
 Smart Initialization: If no configuration file exists or it's empty, it automatically generates a default Lua template. 
 智能初始化：如果配置文件不存在或为空，自动生成默认的 Lua 模板。
 
 Guided Configuration: Provides step-by-step instructions on how to find your device ID and name using wpctl. 
 引导配置：提供使用 wpctl 查找设备 ID 和名称的分步指南。
 
[x easily] One-Click Restart: Offers an option to restart the WirePlumber service immediately after editing. 
一键重启：编辑完成后，提供立即重启 WirePlumber 服务的选项。

🛠 Prerequisites | 依赖安装
Before running this script, ensure you have the necessary tools installed.
在运行此脚本之前，请确保已安装必要的工具。

1. PulseAudio Utilities (for pactl)
The script uses pactl to query audio sink information.
脚本使用 pactl 来查询音频 Sink 信息。

bash
sudo apt update
sudo apt install pulseaudio-utils
2. WirePlumber
This script is specifically designed for systems using WirePlumber as the session manager for PipeWire.
本脚本专门为使用 WirePlumber 作为 PipeWire 会话管理器的系统设计。

bash
# Usually pre-installed on Ubuntu 24.04, but just in case:
sudo apt install wireplumber
3. Text Editors (Optional)
The script will attempt to use gnome-text-editor or gedit. If neither is found, it will fallback to nano.
脚本会尝试使用 gnome-text-editor 或 gedit。如果都没找到，将回退到 nano。

🚀 How to Use | 使用方法
Clone the repository:
克隆仓库：

bash
git clone https://github.com//webpk-hub/wireplumber-sampling-rate-fixer.git
cd wireplumber-sampling-rate-fixer/
Grant execution permission:
赋予执行权限：

bash
chmod +x check_audio.sh
Run the script:
运行脚本：

bash
./check_audio.sh
📝 Configuration Template | 配置模板参考
If you want to manually edit your configuration, the script uses this format:
如果你想手动编辑配置，脚本使用的是以下格式：

lua
rule = {
  matches = {
    {
      { "node.name", "matches", "YOUR_DEVICE_NAME" },
    },
  },
  apply_properties = {
      ["node.description"]       = "Your Device Description",
      ["audio.format"]           = "S32LE",
      ["audio.rate"]             = 192000
  },
}
table.insert(alsa_monitor.rules,rule)
