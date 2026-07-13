---
from: blueprint
to: systems
status: consumed
topic: [★追加第四項·併入打包]覓食util該檢查目標搆不搆得到,非選了才發現失敗——併入正在做的三項一起修,量測前完成
---

# 追加第四項：覓食(及同類)util該先看搆不搆得到

補`2026-07-13-blueprint-to-systems-bundle-all-fixes.md`（consumed），三項已在飛，追加第四項一起做完再量測。

## 背景
今天釐清一件事：Team7「覓食util最高但恆不可派→fallthrough買糧」的行為，用戶指出模型完全沒有「盤算」——util算分時根本不檢查`_find_forage_tile`(radius-1)搆不搆得到獵物，選了才發現target=(-1,-1)撞牆，靠dispatch fallthrough補救。這次是良性(健康fallthrough)，但**模型應該在選之前就知道搆不到**，而非選了才撞牆再補救——現行設計看起來「笨」，非真的笨，但值得修，讓它至少像「先看一眼有沒有獵物再決定」。

## 請做
覓食（以及其他有明確可達性判斷的option，如有需要你評估範圍）的util計算，加入一次可達性預檢查（例如`_find_forage_tile`結果if(-1,-1)則該option util直接大幅降權或不列入candidates），而非現行「util不管搆不搆得到都算高分，靠dispatch fallthrough事後補救」。

## 定位
這是**選項1輕量版**（非真正多步前瞻/盤算——那是長期願景，非本輪範圍，已記project memory）。目的：讓候選分數本身反映「這個option現在做不做得到」，減少「選了才撞牆」的表面笨拙感，不改變fallthrough機制本身（fallthrough仍保留當保險，只是正常情況下不該常態觸發）。

## 併入既有三項
與Team10 override thrash / crisis-381 de-patch / 尊重層乘法陷阱一起做，**量測前全部完成**，仍是一次量測驗收、不分批回報。

## 邊界
HOW層修法，你owner，照標準spec→reviewer R②→implementer流程走。若你判斷這條牽動範圍過大（例如要幫哪些option都做可達性預檢查是設計判斷），回報讓我裁範圍，但基本方向(覓食至少要做)已定。
