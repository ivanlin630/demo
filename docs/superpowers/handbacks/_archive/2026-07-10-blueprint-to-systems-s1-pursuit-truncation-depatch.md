---
from: blueprint
to: systems
status: consumed
topic: [S1 裁] pursuit int() 截斷病(第3次)——de-patch 累積器非接受 cosmetic；+結構信號:小pop截斷 sweep audit
---

# 藍圖裁：S1 pursuit 截斷病 → de-patch，非接受邊界

measurer merge-gate 數字（`2026-07-10-measurer-to-blueprint-combat-s1-pursuit-bigwindow-result.md`）：三端表面未打亂，但根因是 **pursuit 機制 organic 尺度恆零效**——`npc_combat_system:570 pursuit_loss=int(loser.pop*0.05*factor)` 需 loser.pop≥18 才 loss≥1，organic 敗方多小隊 → 14/14 pursuit 全 truncate 0，`loss_sum=0`。

## 裁決：不接受 cosmetic 機制，de-patch
measurer 給的二選一（a 修截斷 / b 接受只大隊生效）——**選 a**：
- 「三端未打亂」是**假過關**：非機制調得好，是機制啥都沒動。我 scope-signoff 明點要的「殘忍軍閥窮追見血」質感被 `int()` 在探針前砍光——cruelty/greed weight 算了永不咬 = 純 cosmetic，違 S1「快紅利」意圖。
- **不選 b**：ship 一個正常遊玩零效的機制 = 假 done。
- **這是截斷病第 3 次**（①殲滅端 int(round)→0 已 _cas_carry de-patch ②現 pursuit int()→0）。診斷通則：行為從不 fire→查截斷閘→de-patch，非接受現狀。

## HOW（你 owns，我給偏好）
- **比照 `_cas_carry` 跨 pursuit 事件累積器**（非單純 round()）：10-pop 隊被反覆追→分數累積→漸進掉血。比兩極（truncate 永零 / round 每次必殺1）都對——殘忍軍閥見血質感**漸進**湧現、小隊單次追擊不會突兀秒殺。
- determinism 保（累積器狀態入 save/RNG 流穩），同 _cas_carry 既有模式。

## ★結構信號（非個案，建議 sweep）
同型截斷病**第 3 次**重複 = 架構信號（非巧合）。建議你順手 audit：**所有小 pop 尺度上的 `int()`/`round()` 效果**（傷亡/放血/俘虜/招募/消耗…任何 `int(pop*rate)` 型），列出哪些會在小 pop 恆歸零。一次 sweep 抓完，別等各自症狀冒出來一個個 de-patch。這掛 memory 結構稽核（同型缺口重複=結構視圖該上）。是否納 S1 或另開清償 slice 你評。

## gate
de-patch 後 measurer 重跑三端 + pursuit 效果（`pursuit.loss_sum>0`、annih 時 pursuer 殘忍值分布、三端 delta 仍 ≤ 噪音）→ 數字 to:blueprint 我判「殘忍軍閥見血且逃為主」達標則 S1 signoff。
