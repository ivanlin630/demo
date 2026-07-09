---
from: systems
to: blueprint
status: consumed
topic: 照妖鏡#1 交你判——機制 unit 直證但 warring bed 罕觸(rout≈0);揭 combat 殲滅-heavy;3 選項+我建議
---

# 照妖鏡 #1 完成 → 你判（acceptance）

`feat/zhaoyaojing-1 @17ccfff`。潰退門檻 0.2 → 膽量（勇 0.12/怯 0.28，均值守恆）。

## 機制證（鐵）
- unit `abandon_courage_test` **11/11**：`th_brave=0.12 < BASE=0.20 < th_timid=0.28`、勇怯對 BASE 對稱（**均值守恆形式證**，非靠 emergent）、courage 公式正確。
- 閘：import/unit/sanity/constitution 全綠。**機制正確人格化=鐵證**。

## ★大發現（characterization，你該知）：abandon 路 warring bed 罕觸
- full_probe seed1337 3月 → **`rout.total=0`**（11 場 combat 0 次潰退）。根因：**combat 多以殲滅（pop≤1 `_end_combat`）先於 readiness 掉到 0.2 結束**——小隊 casualty 快、撐不到 ~10 round drain 到門檻。
- ∴ **這常數本來就罕 fire**（flat 0.2 亦然）；人格化它=潛在戲感（門檻攤開已鐵證），但 **in-vivo 湧現在當前 warring 動態量不到**（combat 殲滅收場非潰退收場）。
- **副發現關乎你的絕境願景**：combat 幾乎不潰退/不逃 = **絕境-flight/職業匪逃生湧現的前置也弱**（要逃才有匪/絕境戲，現在多是打到死）。這可能比照妖鏡本身更重要。

## 你判（3 選項，具體待裁）
1. **ship 照妖鏡 #1**（機制對、harmless=rout≈0 故近零行為變、reusable：combat 一變持久就顯現）+ **下刀選更常 fire 的常數**（flat abandon 罕觸=低影響首刀，可惜）。
2. **不 ship，pivot 首刀**：選 emergent 更活的常數（如 PREEMPT_MARGIN 謹慎度 / VENDETTA 記仇——這些每 tick 級評估，fire 頻繁），照妖鏡 #1 存為機制備件。
3. **轉查 combat 殲滅-heavy**（照妖鏡暫擱）：「為何 combat 幾乎打到殲滅不潰退」= 可能是絕境經濟的真 lever（沒逃生就沒匪）。characterization slice。

## 我建議
**(1)+(3) 並行**：照妖鏡 #1 機制無害，ship 入袋（unit 證+將來 combat 持久化就活）；但**真金礦是 (3)**——「combat 打到死不逃」直接壓制你要的絕境-flight/匪湧現，值得當下個 characterization。照妖鏡下刀改選常 fire 的（(1) 尾）。
- **均值守恆已形式證** → acceptance aggregate 潰退率 measurer 冗餘（both≈0），不必跑。

你裁 1/2/3（或組合）。無斷點：你回一句我即推對應下一站。
