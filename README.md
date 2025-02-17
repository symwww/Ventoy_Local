# Ventoy_Local - 自定义分区格式与部署的引导工具

[![License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

## 项目简介

本项目是基于 [Ventoy](https://www.ventoy.net/) 的修改版本，主要针对分区格式和部署方式进行了自定义调整。以下是主要的修改内容：

1. **移除了对分区格式的强制要求**：原版 Ventoy 对分区格式有严格限制，本版本允许在更多分区格式上使用。
2. **将 Ventoy 位置改为第一分区**：默认情况下，Ventoy 需要安装在特定分区，本版本将其改为第一分区，简化了部署流程。
3. **去除了对引导扇区的校验**：原版 Ventoy 会对引导扇区进行校验，本版本移除了这一限制，允许更灵活的手动部署。
4. **支持手动部署**：用户可以根据需求手动部署 Ventoy，而无需依赖自动化工具。

## 适用场景

- 需要在非标准分区格式上使用 Ventoy。
- 需要将 Ventoy 部署到第一分区。
- 需要手动控制 Ventoy 的部署过程。
- 对引导扇区有特殊需求的用户。

## 使用方法

### 1. 克隆本仓库

```bash
git clone https://github.com/symwww/Ventoy_Local.git
cd Ventoy_Local
```

### 2. 按照Ventoy官方版构建

得到ventoy.img.xz后解压得到ventoy本体，请自行部署至第一分区。

/EFI/BOOT/grubia32_real.efi

/EFI/BOOT/grubx64_real.efi

分别为32/64位下的UEFI引导文件。

/grub/i386-pc/core.img

为LeagcyBIOS下的引导文件，请自行使用。

## 注意事项

- 本版本移除了对分区格式和引导扇区的校验，请确保你的设备兼容性， 第一分区最好从2048扇区开始。
- 手动部署需要一定的技术知识，请谨慎操作。
- 本版本基于 Ventoy 原版代码修改，可能存在未测试的边缘情况。

## 已知问题

- 本版本Windows安装镜像无法在进入系统后自动挂载，Windows PE iso也无法自动挂载。
- 原版Ventoy Linux启动时通过磁盘签名查找磁盘，如果出现冲突，则无法正确查找。

## 致谢

- 感谢 [Ventoy](https://www.ventoy.net/) 项目的开发者提供了优秀的开源工具。
- 感谢所有贡献者和用户的支持。
