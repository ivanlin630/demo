---
from: systems
to: implementer
status: open
slice: 威脅欄印附身隊所知的最急一句（＋頂列無值主張預設）
topic: ★**派工，R² CLEAN（`7a7874c1e`）**｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-06-threat-column-says-what-the-team-knows-HOW.md`｜★序 ＝ **排在票 #2 之後**｜★★最重要的一條不是任何一句威脅文字，是 H0：讀者用 `has("threat_line")` 判
---

# 一、做什麼（spec 已鎖；這裡只講白不要走錯的地方）

```
H0  寫入者**永遠帶** `threat_line` 鍵；「（無）」由**寫入者明示**；讀者用 `has()` 判
    ⇒ 鍵不存在 ⇒「尚未提供」（今天 merge 進去的那一行就是這個過渡）
    ⇒ ★不准用 `== ""`／`is_empty()` —— 那正是這一欄說謊了一整輪的機制
H0′ 頂列讀者 default 一律佔位符「—」：家／糧撐／威脅三欄（`map_controlled_team` 的 `{}` 出口下）
    ⇒ ★**不含** `player_api_mapper.gd:62-63`（R² 打掉：零讀者、沒有驗收列，已登 known_issues）
來源（§2）：②敵隊／③野獸群 ＝ **同一條 `best_estimate` 迴圈**（野獸是偽隊伍，`team_data.gd:179`）
           N ＝ `VisionSystem.vision_range`（不寫死）
           ①交戰中 ＝ `state.encounter_active and tid in [state.encounter_attacker_id, state.encounter_defender_id]`
             ★**不用 `encounter_log`**（今天安全是意外，不是結構保證）
           ④勢力交戰 ＝ **先查**：找不到「自己勢力在交戰」的狀態 ⇒ **④不做、回報我**，不准為一句話發明欄位
```

# 二、★★三個會咬人的地方

```
①P2 god-view 對照要**兩個方向**：belief 沒有 ⇒ 必印（無）；同一佈置讓 belief 有 ⇒ 必印那一句
  ⇒ ★只有前一半的話，「必印（無）」恆真（你上一張票剛付過這筆學費：方向②抓到抽取式恆回 0）
②P8 也要反向：有隊而真的 0 天糧 ⇒ **必須**照印「糧撐 0.0 天」（R² 核過可造：`set_amt(pt,"food",0.0,…)`，
  同 `terminal_selfcheck_bed.gd:117` 既有手法）⇒ 否則「不准印 0.0」會把真警報一起吃掉
③P5「②③一個迴圈」是反向掃 ⇒ 母體印出來（產生者裡呼叫 `best_estimate` 的地方 ＝ 1）
```

# 三、交件報數字

```
·P1 三種狀態各自的畫面原文（尚未提供／（無）／一句）＋負對照（改回 `== ""` 必紅）那一次的輸出
·P2 兩個方向各自的畫面原文 ＋ 母體地板（真值敵隊真的在 ≤N 格）印出的距離
·P4 改變 vision_range 輸入前後，同一距離敵隊進出那一句的兩次原文
·④若不做：貼你找的那一次 grep 與命中數
·新床連註冊表那一列四欄，expect 從輸出逐字抄
```
