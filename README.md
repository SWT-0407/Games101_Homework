# GAMES101 作业与本机 Windows 环境

本仓库用于学习 [GAMES101：现代计算机图形学入门](https://games-cn.org/intro-graphics/)。课程原始 PA0 推荐 Ubuntu 18.04 虚拟机；这里改用原生 Windows 工具链，便于后续 CG 科研开发。

## 目录

- `assignments/`：解压后的 PA0-PA8 作业框架与作业文档
- `scripts/setup.ps1`：从零安装用户级工具和 C++ 依赖
- `scripts/games101.ps1`：统一的配置、编译、运行与检查入口
- `vcpkg.json`：Eigen、OpenCV、FreeType 的可复现依赖清单
- `archives/`：原始 ZIP，仅保存在本机，不提交到 Git

## 当前环境

- Visual Studio 2019 MSVC x64 与 Windows SDK 10.0.26100.0
- CMake 4.4.3、Ninja 1.13.2
- Eigen 5.0.1、OpenCV 4.12.0、FreeType 2.14.3
- VS Code 的 Microsoft C/C++ 与 CMake Tools 扩展

首次克隆到另一台机器时，需要先安装带有“使用 C++ 的桌面开发”组件的 Visual Studio 2019 和 Python，然后执行：

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
.\scripts\setup.ps1
```

## 使用

重新打开 VS Code，使用户 PATH 生效。常用命令如下：

```powershell
.\scripts\games101.ps1 verify
.\scripts\games101.ps1 build pa0
.\scripts\games101.ps1 run pa0
.\scripts\games101.ps1 build pa3 -Configuration Release
```

作业名可用 `pa0` 到 `pa8`。生成文件位于各作业的 `build/`，不会提交到 Git。VS Code 默认把 PA0 作为 CMake 源目录；学习其他作业时，可修改 `.vscode/settings.json` 中的 `cmake.sourceDirectory`，或直接使用上述脚本。

## 验证状态

| 作业 | 原生 Windows 验证 |
| --- | --- |
| PA0 | 配置、编译、运行通过 |
| PA1、PA2 | 配置、编译通过 |
| PA3 | 环境配置通过；框架中的投影矩阵函数是待完成题目，当前会因无返回值停止编译 |
| PA4、PA5 | 配置、编译通过 |
| PA6 | 环境配置通过；BVH 求交函数是待完成题目，当前会因无返回值停止编译 |
| PA7 | 环境配置通过；BVH 与路径追踪函数是待完成题目，当前会因无返回值停止编译 |
| PA8 | 配置、编译通过；已适配现代 CMake、MSVC、静态 GLEW、Windows getopt 与系统字体 |

这些“无返回值”错误属于课程刻意留出的作业内容，并非环境配置失败。原始 ZIP 未修改；所有兼容性调整只发生在 `assignments/` 的工作副本中。
