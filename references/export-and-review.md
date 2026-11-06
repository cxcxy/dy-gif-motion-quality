# GIF 编码与验收

先锁定帧的像素尺寸、顺序和逐帧停留时间。时间按百分之一秒表达，按用途保留长停顿。复杂平台规格从目标平台核对。保留高质量帧序列或原视频，从它重新编码。

## 按症状找原因

| 看到的问题 | 先检查 | 优先处理 |
| --- | --- | --- |
| 动作像几张图硬切 | 未压缩序列的姿势差和时间 | 只在运动跨度大的区间补中间姿势，保留峰值停顿 |
| 脸和道具抖，纸纹像沸腾 | 对比未压缩帧，确认固定区域是否一起变化 | 固定共用底层、对齐锚点，修问题帧 |
| 成品色带明显或出现噪点闪烁 | 同一时刻的源帧与解码帧 | 比较整段共享调色板与其他方案，试不同抖动强度，按实际尺寸比较 |
| 透明边发白、动作后留影 | 在深浅底分别看解码帧和上一帧残留 | 修正透明边缘或帧处置方式，重新检查优化后的合成帧 |
| 文件过大 | 画布、帧间变化面积、重复帧和粒子噪点 | 从合理缩小画布、稳定底层、合并相邻相同帧并累加延时开始 |

GIF 的颜色表最多 256 项，透明像素使用透明索引。渐变、细颗粒、半透明阴影和全屏噪点要看实际编码结果。对平涂、清楚的外轮廓和短文案，优先试整段共享调色板。摄影画面或颜色变化明显时比较编码方案。透明版在浅色和深色底上都验。 [GIF89a 规范](https://www.w3.org/Graphics/GIF/spec-gif89a.txt)

## 本地示例

下面是四张等尺寸、已排好字的**不透明** PNG，只有示例使用这组延时。ImageMagick 的 `-loop 0` 输出无限循环，`-layers Optimize` 后重新解码检查。透明素材需按目标背景与帧处置情况另验。

```bash
magick frame-0.png frame-1.png frame-2.png frame-3.png \
  +append +dither -colors 192 -unique-colors palette.png
magick -delay 80 frame-0.png -delay 7 frame-1.png \
  -delay 12 frame-2.png -delay 7 frame-3.png \
  +dither -remap palette.png -loop 0 -layers Optimize output.gif
```

运行 [scripts/inspect-gif.sh](../scripts/inspect-gif.sh) 读取画布、每帧延时、循环、解码后不同画面的数量和体积。它依赖 ImageMagick 7。相同画面用于有意停顿是合理的。不同画面也可能只有纸纹变化，需要结合目视判断。

```bash
bash scripts/inspect-gif.sh output.gif
magick output.gif -coalesce -resize 120x120 +append decoded-strip.png
```

帧表适合检查锚点和动作轨迹。播放成品才能检查停顿、循环和残影。需要平台适配时，在目标客户端按实际显示尺寸完成最后一次核对。

## 聊天表情的轻量版

- 有明确字节上限或平台规格时，以实际要求为准。没有指定时，用最复杂的一张试档。小驴这类不透明、色彩简单的手绘表情，可以先比较 280 与 240 像素、整段共享约 48 色的效果。文字太细、眼神模糊或色带明显时，提高尺寸或颜色数，再按聊天实际显示大小比较。
- 用合成后的完整帧缩放和统一量化，再优化帧间存储。对只要求缩小文件的任务，逐帧对照数量、顺序和延时，并核对循环设置。用户指定循环次数时沿用该设置。透明或有大面积渐变的作品单独试档。
- 保存独立的轻量文件，并比较同一组 GIF 或同一组 ZIP 的实际字节数。小驴追加包从 400 降到 240 像素，整包约从 4.9 MB 降到 1.1 MB，缩小约 77%。5 张均保留原来的 9 帧、逐帧延时和无限循环。压缩幅度会随素材变化。

下面的示例适用于**原本就无限循环的不透明 GIF**。在临时目录操作中间文件，先根据尺寸要求确定导出档位。示例在当前目录中读取 `input.gif` 并写出 `output-lite.gif`。

```bash
work_dir=$(mktemp -d)
magick input.gif -coalesce -resize '240x240>' "$work_dir/frames.miff"
magick "$work_dir/frames.miff" +append +dither -colors 48 -unique-colors "$work_dir/palette.png"
magick "$work_dir/frames.miff" +dither -remap "$work_dir/palette.png" \
  -loop 0 -layers Optimize output-lite.gif
cmp <(magick identify -format '%s %T\n' input.gif) \
    <(magick identify -format '%s %T\n' output-lite.gif)
wc -c input.gif output-lite.gif
rm -f "$work_dir/frames.miff" "$work_dir/palette.png"
rmdir "$work_dir"
```

用检查脚本核对循环和画布。把源帧与压缩后的同一帧缩到相同显示尺寸，重点比较黑色线条、眼神和字边，再播放成品检查动态闪烁与接缝。
