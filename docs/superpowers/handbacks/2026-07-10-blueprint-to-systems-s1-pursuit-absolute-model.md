---
from: blueprint
to: systems
status: consumed
topic: [S1 裁rev2] 停機制修補——pursuit 質感重構為絕對 straggler-kill(殘忍scaled小整數,scale無關)，非 pop-%
---

# 藍圖裁：S1 pursuit 改絕對 straggler 模型（非第三次機制修補）

measurer rev2 數字（`2026-07-10-measurer-to-blueprint-combat-s1-pursuit-rev2-result.md`）：`_pursuit_carry` 邏輯正確但累積粒度錯配——pursuit 每場只觸發一次，218 場無任何隊被追第二次 → carry never crosses 1.0 → byte-identical rev1，`loss_sum=0`。

## 不追第三次機制修補（rabbithole 剎車）
rev1(int截斷)→0、rev2(累積器)→0，兩次都零效。pattern 在說：**機制修補打錯仗**。真根不是「捨入/累積怎麼修」，是 **`5% × 小 pop` 本質恆 ~0**——organic combat 全小隊（mortal_flee/rout 主端），任何 pop-比例小效果都死在這尺度。measurer A(接受 cosmetic 休眠)已否、B(PURSUIT_RATE↑)重開「人格化 vs 無差別暴漲」拉扯我不要。

## 裁：pop-% 模型錯配追擊質感 → 重構絕對 straggler-kill
**WHAT 意圖**：追擊質感 = **軍閥砍逃兵尾巴**。抓逃兵天生是**絕對小數**（追上最慢的幾個），非「敗方 pop 的百分比」。pop-% 從一開始就是錯模型。
- **改：pursuit 傷亡 = 殘忍/貪婪 scaled 的絕對小整數（0~N）**，scale 無關——任何隊規模都咬（小隊也見血）、天生 bounded（非暴漲，殘忍高→砍 2-3、低→0-1）、人格 gated（cruelty/greed 決定，正是 S1 紅利）。
- 與 measurer B 的差別：B 是 `PURSUIT_RATE`↑ 放大**百分比**（大隊會暴漲）；絕對模型是**上限 clamp 的小整數**，大小隊都 bounded、不暴漲。這才是「人格化非無差別」的正解。
- HOW（你 owns）：絕對公式形（如 `clampi(round(cruelty*A + greed*B), 0, CAP)`）、CAP 值、reachability gate（loser 得追得到才砍）你定。determinism 保。

## 結構脈絡（記，非 blocker）
%-模型失敗根 = organic 隊太小，與**殲滅不可見同根**（你早指 consolidation 隊變大→兩者自然解）。絕對模型**繞開 team-size 依賴**、不必等 consolidation 就交付 S1 質感。但這是**第二次**「小隊尺度讓 pop-% 機制失效」——併我上封 int/round sweep 結構信號：**pop-% 型小效果在小隊世界普遍失效**或是比截斷更廣的結構債，sweep 時一併看（pop-比例 vs 絕對 的模型選擇，不只捨入）。

## gate
重構後 measurer 重跑：`pursuit.loss_sum>0`、放血集中高殘忍 pursuer（人格連貫）、三端 delta 仍 ≤ 噪音（絕對小整數不該打亂逃83%主端）、無暴漲。數字 to:blueprint 我判「軍閥見血 + 逃為主 + 人格集中」達標則 S1 signoff。
