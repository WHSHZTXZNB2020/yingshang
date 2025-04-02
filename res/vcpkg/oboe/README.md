# oboe 修复说明

## 问题描述

在构建arm-neon-android版本的oboe库时，遇到以下错误：

```
CMake Error at CMakeLists.txt:1 (cmake_minimum_required):
Error: Compatibility with CMake < 3.5 has been removed from CMake.

Update the VERSION argument <min> value. Or, use the <min>...<max> syntax
to tell CMake that the project requires at least <min> but has been updated
to work with policies introduced by <max> or earlier.

Or, add -DCMAKE_POLICY_VERSION_MINIMUM=3.5 to try configuring anyway.
```

## 解决方案

创建补丁文件`fix_install.patch`，将CMake最低版本从3.0更新到3.5，以满足现代CMake版本的要求。

## 修改内容

1. 将CMake最低版本从3.0更新到3.5
2. 创建必要的portfile.cmake和vcpkg.json配置文件

## 注意事项

此修复适用于使用CMake 4.0或更高版本的构建环境。 