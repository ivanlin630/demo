---
from: systems
to: implementer
status: open
slice: 顧問讀信念＋文本外置試點
topic: GO｜spec 2026-10-15-advisor-reads-belief-and-text-externalization-pilot-HOW（R² 兩輪，CLEAN）｜順位：游標即選中之後、第 7 張之前
---

# GO
spec：`docs/superpowers/specs/2026-10-15-advisor-reads-belief-and-text-externalization-pilot-HOW.md`

## 順位
游標即選中 → **本張** → 第 7 張戰後收尾 → 你領導的勢力 → 真玩小修 → 我的掛單與押貨（spec 審查中）。
★「我的掛單與押貨」讀本張的 `TextBank.res_name`，所以本張一定要在它之前合。

## 重點
- 問顧問改成一道玩家指令 `ask_advisor`（VERB／dispatch／describe 同 commit），刪掉 UI 直呼。
  - 前置只有四條會回 ok:false；其餘答不出來的一律走「不知道」（ok:true）。
- 雜訊：只准經 `AdvisorSystem.noise_u` 一支，內含命名空間 `1<<40` 與情境序 salt。零 randf。
- diplomatic 只讀 known_reputations（隊長的 feud 邊是 god-view，拿掉）。
- `advice` 進 FUNC_KINDS＋KIND_LABEL。
- 文本外置：
  - `data/text/advisor.tsv`、`data/text/names.tsv`。
  - 顯示名一張表（藍圖裁）：用字粗製／精製、護甲。`resource_name` 轉呼 short，查不到回原鍵。
  - ITEM_DISPLAY（text_ui_main:1794）刪掉，讀者改呼 item_name。
- 同 commit 要改的既有東西：headless_test:4511、terminal_input_prompts_bed:284、menu_situations。
- 守衛：鍵對帳是執行期（fmt 落預設句＝0，兩向）；T4 母體是 weapon_*／armor_* 那 6 個值。

## 交件信要列
見 spec 末節（己方武裝讀哪支、來源詞數、A4／A5 數字、威脅欄 E2E 逐字、TEMPLATES grep、A2b 位移、舊字 grep）。
