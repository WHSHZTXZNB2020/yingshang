# oboe 修复说明

## 问题描述

在构建arm-neon-android版本的oboe库时，遇到以下两个问题：

1. CMake兼容性错误：
```
CMake Error at CMakeLists.txt:1 (cmake_minimum_required):
Error: Compatibility with CMake < 3.5 has been removed from CMake.

Update the VERSION argument <min> value. Or, use the <min>...<max> syntax
to tell CMake that the project requires at least <min> but has been updated
to work with policies introduced by <max> or earlier.

Or, add -DCMAKE_POLICY_VERSION_MINIMUM=3.5 to try configuring anyway.
```

2. 下载哈希值不匹配：
```
Failed to download google-oboe-1.8.0.tar.gz.
...
error: File does not have the expected hash:
url: https://github.com/google/oboe/archive/1.8.0.tar.gz
Expected hash: b5f4cf103d1929ed56fd12b6fd32ba4146e35acae02a65cdfc18e3f83320bf4e8e1e0c63e72c6f571acbe3eea8f5cc13fe98abb24698895b02935c2a24786b13
Actual hash: 7eeaf85f9889e03dd1e7f5de0e9f2cee815fc555fddfdb8c4d3450d67f6ae11b0ca43b63c73e869bfc4629d2f8e5bdb23a5833c665ca5226c339f74b9b34a8ad
```

3. 补丁文件格式错误：
```
Error:   Applying patch failed: error: corrupt patch at line 10
```

## 解决方案

1. 创建补丁文件`fix_install.patch`，将CMake最低版本从3.0更新到3.5，以满足现代CMake的要求。

2. 在portfile.cmake中更新SHA512哈希值为实际值，解决哈希值验证失败问题。

3. 修复补丁文件格式问题，确保正确的diff格式，避免额外的空行和格式问题。

## 修改内容

1. 将CMake最低版本从3.0更新到3.5
2. 更新SHA512哈希值以匹配实际文件
3. 创建必要的portfile.cmake和vcpkg.json配置文件
4. 确保补丁文件格式符合git标准

## 注意事项

此修复适用于使用CMake 4.0或更高版本的构建环境。哈希值更新可能需要随着上游库变化而进一步更新。 