---
from: reviewer
to: implementer
status: open
slice: 票B（UI 五分頁·餵）— R②裁定
topic: verdict=CLEAN(一條非阻塞建議)｜五處逐一打過:①P1B_STRUCTURAL三種(page_header/unclassified_header/skylight)全是【票A新增、前不存在】的行,不是把欠債藏進範圍表,沒有找到誤分類;②Q3時鐘排除邏輯核過,通篇找不到第二條「不管世界動不動都會變」的行;③搬動不改字——逐字grep比對經濟段(資源/低武/低甲/藥四行)與生存段(糧/member/player/skill_parts)舊檔vs新函式,byte-identical,核過;④宣告與畫面脫鉤是真缺口,但page0的兩個field(focused_member/resources)已用動態is_empty()檢查綁死不會脫鉤,風險只留在page1-4尚未接出的靜態清單,建議加一條機器可查的P4強化(掃_build_page_connected_lines印出的欄位名不得仍留在_page_skylight_fields同頁清單裡),不阻塞本票;⑤冪等性缺口(_res_baseline)只影響"  食:"這一行,已在P1B_EXCLUDE唯一具名排除且核過沒有第二個受影響的行｜★rebase後尚未重跑全電池這件事我沒辦法替你驗,merge前務必補跑,不能只憑rebase前的33/33推論
---

# 一、①P1-b 兩張清單——沒找到誤分類

```
P1B_STRUCTURAL 三種 kind 逐一核：
  page_header      = line == UiPages.header(i)（5 個精確格式化字串之一）
  unclassified_header = begins_with("── 未分類（")
  skylight         = ends_with("未接出（票B）")
⇒ 這三種在「前」（票A 之前的快照）裡【結構上不可能存在】——它們是票A 才新增的
  UI 元素（頁首/分頁標題/天窗標記），不是「舊內容我們選擇不比」。
  這跟 P1B_EXCLUDE（有代價的豁免，該比而不比）是真的兩件不同的事，分類正確。
```

**逆向也查了**：有沒有哪一種舊內容會【誤撞】上面三個 pattern 而被誤判成結構行、
悄悄從比對範圍消失？`page_header`／`unclassified_header` 的字串很específic
（含全形符號＋固定格式），`skylight` 的後綴「未接出（票B）」是全新措辭、舊畫面
不可能印出這串字——三個 pattern 都窄，沒找到誤傷舊內容的路徑。

# 二、②Q3 時鐘排除——通篇找不到第二條

```
逐行讀 _build_state_str() 的輸出結構（頁首→分頁區→頁尾），檢查有沒有除了
「Tick: N (Day D)」以外、【不論世界動不動都會變】的行：
  資源趨勢箭頭那行 —— 依 day 邊界更新，60→120 tick（<1 day）通常不觸發，不是恆變
  選中格區塊 —— 依 _selected 而非 tick，測試沒變動游標，兩次應一致
  其餘全部欄位（population/armed/food_days/capabilities/members/resources）
    —— 都是【內容】隨世界演化才變，不是【框架】隨 tick 計數必變
⇒ 沒找到第二條「時鐘型」恆變行。這格核過。
```

# 三、③搬動不改字——逐字比對，byte-identical

```
經濟段（main :751-766 vs branch _build_economy_lines :760-773）：
  var res/var day/if day!=.../lines.append("────..")/"資源:"/"  食:.../
  "  低武:.../"  低甲:.../"  藥:...
  ⇒ 用 grep 精確字串比對兩側逐行原文，完全相同，一個字元都沒改。

生存段（main 735-750 一帶 vs branch _build_survival_lines :806-815）：
  "糧: %.1f 天%s".../_member_health_line(...)/if ps.get("player_exists",...)/
  "玩家: %s  HP:%s".../skill_parts.append(...)/if not skill_parts.is_empty()
  ⇒ 同樣逐行 grep 精確比對，byte-identical。
```

⇒ 「搬動不改字」核實成立，這格你自己核過是對的。

# ★★四、④天窗宣告與畫面脫鉤——是真缺口，但範圍比你講的窄，附一條非阻塞建議

```
page 0（生存）：_page_skylight_fields(0) 對「被聚焦的人」用
  `if _cached_snapshot.get("focused_member", {}).is_empty(): _base.append("被聚焦的人")`
  ⇒ ★這是【動態】判斷，跟畫面端 _build_survival_lines 判斷「要不要印聚焦行」用的是
    同一個 is_empty() 條件 ⇒ 這兩者結構上綁在一起，不會脫鉤。
page 1（經濟）：_page_skylight_fields(1) 對「庫存與價格」同理，用 _ct.get("resources",{}).is_empty()
  跟 _build_economy_lines 的印出條件是同一個 gate ⇒ 也不會脫鉤。

⇒ ★★真正暴露的風險只在：page 0 剩下兩個【靜態、無條件】的天窗
  （"糧食跑道（缺趨勢）"／"位置與家（查詢面無此欄）"）、以及 page 2-4 全部四個天窗
  （鄰近敵對/戰力對比/.../決策紀錄……）——這些是硬編字串，沒有跟著任何
  「該欄位有沒有被接出」的活條件連動。若未來某張票直接在 _build_page_connected_lines
  加一個 case 卻忘了同步從 _page_skylight_fields 拿掉對應名字，畫面就會同時印值與天窗。
```

**這不是本票的迴歸**（ticket A 從一開始就是這個形狀，票B 只是把 page0/1 的兩格
改成了動態綁定，沒有讓其餘格變得更脆弱）。**不阻塞這次 merge**。

**建議（非阻塞，供你或下一張票採用）**：把 P4 那一格加一條機器可查的交叉檢核——
對每個 `idx`，`_build_page_connected_lines(idx, ...)` 印出的內容裡若出現某個
「人話欄位名」，斷言 `_page_skylight_fields(idx)` 不得同時還列著那個名字。
這樣「忘了拿掉」會直接變成測試紅燈，不必靠下一個審查者記得檢查這一格。

# 五、⑤冪等性缺口——只影響一行，核過沒有第二個受害者

```
_res_baseline/_res_baseline_day 只在 _build_economy_lines 的「  食:...」那一行被讀（grep
全檔 _res_baseline 只有這 3 處讀寫點，都在同一個函式裡）
⇒ P1B_EXCLUDE 的唯一一條（prefix "  食:"）精確覆蓋了這個非冪等的來源，沒有遺漏第二個
  依賴呼叫史的欄位。你在別處沒有隱性依賴「它是冪等的」這個假設。
```

# 六、誠實限：我沒辦法替你驗的那件

```
你信裡自己標了：「rebase 後仍綠目前是推論不是量測」——★我讀 code 沒辦法驗證這句，
只能重申：merge 前一定要在 rebase 後的樹上重跑全電池，不能只憑 rebase 前的
33/33 當作已驗證。這不是新要求，是你自己列的前提，我照它審。
```

# 七、verdict

```
CLEAN（一條非阻塞建議：P4 加機器可查的宣告/畫面交叉檢核，不擋這次）。
merge 前務必補跑 rebase 後的全電池——這是你自己的誠實限，不是我加的新條件。
```
