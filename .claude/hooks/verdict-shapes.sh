#!/usr/bin/env bash
# ★判決行形狀的【唯一清單】—— 兩個地方要用同一份：
#   ①`bed-triage-sweep.sh` 的 classify（讀【跑出來的輸出】判綠）
#   ②`bed-kind-gate.sh` 的 diagnostic 檢查（讀【床的原始碼】判它有沒有判決通道）
#
# ★★為什麼要抽出來：這兩處各自維護一份「判決長什麼樣」的清單，
#   而它們【必然 drift】—— 血證 2026-09-09：classify 已經認得 `errors: 0` 與 `TEST DONE ===`，
#   ★而 bed-kind 那邊只認字面的 `=== DONE ===` ⇒ 把 `ui_flow_test.gd`（有 `errors: N` 判決通道）
#   標成 `diagnostic` 時閘印 ok ―― ★★閘替一個【謊】蓋了章，而那正是它被蓋出來要擋的東西。
#
# ★★★兩個常數【不是同一個東西，不要合併】：
#   VERDICT_GREEN_RE   = 這份【輸出】說「我驗過了而且過了」（errors: 0 / fail=0 …）
#   VERDICT_CHANNEL_RE = 這份【原始碼】裡有一條會產生判決/完成彙總的通道（errors: %d 也算）
#   ⇒ 前者要求「零失敗」，後者只問「有沒有這條線」。

# 跑出來的輸出 ⇒ 綠（★樣本全部取自真實床，非照偵測器形狀造）
VERDICT_GREEN_RE='ALL PASS|FAILS=0|fail=0|TEST-SUITE-COMPLETE|ASSERTIONS PASSED|全部通過|errors: 0|TEST DONE ==='

# 原始碼裡存在判決/完成彙總通道 ⇒ 它就不是【純診斷】
# ★注意 `errors: ` 與 `DONE ===` 用【不含零】的寬形式：原始碼寫的是 `errors: %d`，
#   而它跑出 `errors: 3` 時 classify 判紅 ⇒ 通道存在。
# ★2026-09-09 收窄：原本收 `DONE ===`（任何完成行）——太寬。
#   classify 綠的那個 token 是 `TEST DONE ===`,而 `=== 和平經濟觀測床 DONE ===`
#   在 classify 眼中【不是】判決 ⇒ 收寬會把真的觀測床誤判成「有判決通道」。
#   ★兩份清單要對齊的是【同一件事】：classify 讀得出判決的那些形狀。
VERDICT_CHANNEL_RE='ALL PASS|TEST-SUITE-COMPLETE|ASSERTIONS PASSED|全部通過|TEST DONE ===|errors: |FAILS=|HAS FAILURE|fail=0'
