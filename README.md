### Dialog Shell UI

#### 介绍

该项目是一个基于 Bash 脚本的功能管理用户界面，用于动态地启用和禁用系统功能。它允许用户通过一个简洁的图形界面配置和控制各种系统功能的启用状态。适用于需要通过脚本集中管理多个配置文件和命令的开发者和系统管理员。

#### 核心功能

1. **动态功能配置**：通过 conf 目录下的 .conf 文件动态定义功能，每个功能可单独启用或禁用。
2. **图形界面选择**：使用 dialog 工具提供的图形界面来展示和选择功能。
3. **日志记录**：详细记录操作日志，支持调试信息的输出，方便跟踪和排错。

#### 目录结构

- **conf/**：存放功能配置文件，每个配置文件定义一个功能的启用和禁用命令、日志信息和描述。
- **lib/**：包含脚本库文件，实现功能的检查、启用、禁用等核心操作。
- **tests/**：存放测试脚本，测试功能配置文件是否有效。
- **logs/**：存放日志文件，记录所有操作和系统输出。
- **dialog.sh**：主执行脚本，启动功能管理UI。
- **run_ui.sh.copy_to_parents** shell-ui控制面板的的启动脚本，先复制该文件到父级目录再运行。

#### 集成使用方法

- **安装依赖**
```bash
sudo apt update
sudo apt install dialog
```

- **克隆项目到本地并设置必要的执行权限：**
```bash
git clone https://github.com/Loongel/dialog-shell-ui.git
chmod +x dialog-shell-ui/*.sh dialog-shell-ui/lib/*.sh
cp dialog-shell-ui/run_ui.sh.copy_to_parents_folder run_ui.sh && chmod +x run_ui.sh
# 配置修改文件 dialog-shell-ui/*.conf 添加UI功能
# 复制配置文件
# for file in dialog-shell-ui/conf/*.conf.template; do mv "$file" "${file%.template}"; done && 
# ./run_ui.sh
```

#### 开发和二次开发指南

1. **添加新功能**：
   - 在 `conf/` 目录下，参考*.conf.template，创建新的 `.conf` 文件。
   - 定义 `name`, `enable_command`, `disable_command`, `check_command`, 和 `description`。

2. **测试新功能**：
    - 执行conf测试脚本
	```bash
	cd dialog-shell-ui
	chmod +x tests/*.sh lib/*.sh
	./run_ui.sh
	```
    - 根据测试脚本反馈错误信息(控制台，或者 `logs/dialog-shell-ui.log `)，修改对应配置文件。

3. **修改界面和逻辑**：（一般情况下无需修改）
   - 调整 `lib/interaction.sh` 中的 `present_menu` 函数以改变界面布局和逻辑。
   - 更新 `lib/utils.sh` 中的函数以优化日志记录和错误处理。

#### 调试

- 设置 `debug_mode` 为 `1` 开启基本调试，设置为 `2` 开启详细日志记录。
- 查看 `logs/dialog-shell-ui.log` 文件以获取运行时的详细信息和错误日志。
