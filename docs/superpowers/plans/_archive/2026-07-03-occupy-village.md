# 佔村 option — Plan

> Spec：`docs/superpowers/specs/2026-07-03-occupy-village-design.md`（先整份讀）。**measure-first:Task 1 數據定 Task 2 修哪根,別跳。**

## Task 1 — Measure（探針+量測,不動行為）
1. 探針（Probe guard）:`raid.extort`/`raid.combat_at_outpost`/`raid.combat_open_field`（interaction TASK_LOOT 解決點+combat 落點 tile outpost_level）;`raid.capture_flip`（capture 真翻旗）;翻旗後收益鏈驗（owner 產出/tax 是否到新 owner——讀 outpost tick 代碼+探針）。prey 組成:resident 村隊 vs 流浪隊（dispatch 時記 prey tags/residency）。
2. longwindow 6 月（seed 1337,輸出落檔）:抓 T36 型狼 raid 解剖分佈 → handback 報數字+判定（機制斷/權重斷/兩者佔比）。

## Task 2 — 佔村 option（按 Task 1 數據）
1. means-end 兩 option 並列（守不住→走:離家距/threat/pop 分駐;守得住+要根據地→佔:無 outpost/pop 夠/目標產出/征服 intent 加權）。連續 util,零新判斷器。
2. 佔住=複用:capture 翻旗+settle/residency pattern 派駐+村民受控人力+產出歸 owner（收取鏈若 Task 1 證斷則補接,走既有 bank）。
3. 若 Task 1 證「戰不落村格」主因:prey 選擇對有據點弱村加權（要據點的狼 means-end 導向打村）。
4. settle 派駐若成 latch → 配 timeout（invariant）。
5. headless 測:佔村 fire/搶走並存/守恆/收取鏈。

## Task 3 — 驗收
長窗:佔村事件>0+佔村狼 flow 轉正（糧引擎點火）+雙引擎弧一段可見;不 over-war;回歸全綠（headless 1 FAIL pre-existing 容忍/framework 7/7/coin_eq/InvariantAudit）。

## Handback
`2026-07-03-occupy-village.md`:Task1 分佈數字+判定、Task2 修法歸屬、佔村弧證據、TEST VALUE 清單。

## 注意
- 平行紀律:**勿碰** `diplomatic_ai`（結盟軌）/`world_generator`+stable tick（馬軌）;outpost_system 限收取鏈/佔住 wiring 函數。
- Godot wrapper;長窗 5400 背景;輸出先落檔。1 FAIL pre-existing。
