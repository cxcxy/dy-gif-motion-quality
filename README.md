# dy-gif-motion-quality

一个制作、诊断和压缩动画 GIF 的 Agent Skill。适合手绘表情包、短动作和循环演示。它指导 Agent 先设计关键姿势与停顿，再检查角色一致性、循环接缝和导出画质。

## 小驴 GIF 演示

| 收到！ | 这合理吗？ | 我先溜了 |
| :---: | :---: | :---: |
| <img src="examples/01-received.gif" width="180" alt="小驴抬蹄敬礼，收到！"> | <img src="examples/02-really.gif" width="180" alt="小驴挑眉侧眼，这合理吗？"> | <img src="examples/03-sneak-away.gif" width="180" alt="小驴交替迈步，我先溜了"> |

| 给你鼓掌 | 我裂开了 |
| :---: | :---: |
| <img src="examples/04-applause.gif" width="180" alt="小驴连续拍手两次，给你鼓掌"> | <img src="examples/05-shocked.gif" width="180" alt="小驴瞪眼张嘴，我裂开了"> |

「给你鼓掌」画出了蹄子分开、靠近、接触、再分开的过程。「这合理吗？」靠挑眉、侧眼和短暂停顿传达怀疑。这两张用同一只小驴演出了两种不同的节奏。

仓库里的五张是 240 × 240 像素的轻量版，每张约 198–244 KB。相比对应的 400 × 400 像素原版，整套 ZIP 从约 4.9 MB 降到 1.1 MB，缩小约 77%。五张均保留 9 个动作画面、原来的逐帧延时和无限循环。

## 在 Codex 使用

```bash
git clone https://github.com/cxcxy/dy-gif-motion-quality.git ~/.codex/skills/dy-gif-motion-quality
```

打开新聊天并调用 Skill。

```text
用 $dy-gif-motion-quality 把这只手绘小驴做成拍手表情。
动作做两下，保留原画风和白字黑边配文，并导出轻量 GIF。
```

制作从 [SKILL.md](SKILL.md) 开始。需要压缩现有 GIF 时，参考 [编码与验收](references/export-and-review.md#聊天表情的轻量版)。本地检查脚本需要 ImageMagick 7，可以读取画布、逐帧延时、循环和体积。

```bash
bash scripts/inspect-gif.sh examples/04-applause.gif
```
