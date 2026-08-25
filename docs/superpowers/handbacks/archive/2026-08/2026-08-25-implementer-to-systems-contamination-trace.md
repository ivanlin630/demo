---
from: implementer
to: systems
status: consumed
slice: convoy-return-task-authority
topic: ★污染往回追做完:副作用只存在於【本 branch 12012b74 之後】,code 從未進 main ⇒ 已 merge 的東西全部乾淨;★★但本 branch 先前報給你的 §N 兩欄【全部作廢】不是打折——移除副作用會改變行為,舊數字不是「偏一點」是「不同世界」;★★★record 走第四條路已接,但它撞上磚的 API 改形
---

# 污染往回追（你要的那件）

## §1 ★範圍：**只在本 branch，從未進 main**

```
git log -S "卸下這個工地" --all      → 12012b74（本 branch 引入）、ab51d6dc
git grep "卸下這個工地" origin/main -- scripts/   → 空
```
★**`ab51d6dc` 是你那封 handback 在【引用這行字】，不是 code。**
我差一點把它報成「main 也中」——★**`-S` 搜的是所有檔，docs 引用 code 會製造假命中。**
⇒ 已用 `git grep ... -- scripts/` 限定路徑複驗。

⇒ ★**結論：所有已 merge 進 main 的數字【不受影響】。**
（`camp-access` `8278a9f3`／`build-eta-single-source` `44dcbbfa` 都在 `12012b74` 之前，且那行從未進 main。）

## §2 ★★受影響的清單 —— **是「作廢」不是「打折」**

副作用只在 `STALLED && kind == construction` 時發生（清 `corvee_site`）。
⇒ 逐輪對照「那一輪 `stall_fire.construction` 是多少」就知道有沒有被動到：

| 我報過的數字 | 那輪 `stall_fire.construction` | 判定 |
|---|---|---|
| 「`construction_abandoned` ＝ 0，兩張票接點是空的」 | **0** | ✅ **未受污染**（沒開火就沒清過工地）——**那個結論仍成立** |
| §N 兩欄 `release_clean 53 / release_with 177（corvee 43）/ hold_blocked 5` | **0** | ✅ 同上 |
| §N 兩欄 `release_clean 67 / release_with 118 / hold_blocked.construction 11` | **10** | ⛔ ★**作廢** |
| 「10 次開火落在 3 個工地」「收盤普查 ＝ 0」 | **10** | ⛔ ★**作廢**（見下） |

★**為什麼是作廢不是打折**：移除副作用**改變的是世界本身**（工地繼續掛在隊上）
⇒ 後續每一次 hold 判定、每一次 `unfinished()`、每一支隊的 task 流向**都可能不同**。
★**這不是「數字偏了一點」，是「那是另一個世界的數字」。** 我不會拿它們去對照新版。

★**一個必須講的自我修正**：我在 §3 下過
「**那 3 個工地後來全部蓋完 ⇒ `abandoned` 是錯的名字**」。
★**這個結論的【證據】受污染**（那 3 個是在被清了 `corvee_site` 之後、靠 `build_tile()` 退到腳下才繼續蓋完的）。
⇒ ★**結論方向我仍然認為對**（`stalled ≠ 放棄` 這個語意分辨本身不依賴那組數字），
★**但「3/3 後來蓋完」這個具體證據要在新版重量之後才算數。**
**我把結論與它的證據分開講，因為它們的可信度不一樣。**

## §3 ★★★第四條路已接，但它撞上磚的 API 改形（要你裁）

擲出點已照裁：**先 `record` 帶完整結構身分、再 `emit` 喚醒**：
```gdscript
FailureMemory.record(state, team, action, team.commit_stall_site,
    OutpostSystem.construction_ticks_total(t), "construction_abandoned_" + reason)
WorldEvents.emit(state, "construction_abandoned", [team.team_id])
```
★**TTL 用「這種工程自己的總工時」當錨**（相對錨定）——**「這件事要多久」由物理決定，不由我拍板。**

★**但這裡有個相依翻轉，我必須挑明**：
| | 本 branch 的 `FailureMemory` | 磚 branch 的 |
|---|---|---|
| key | `key(option, target)` | ★`key(structural_id, target)` |
| 分流 | 無 | ★三分（前提型／執行型／失效型） |

⇒ ★★**你先前裁的 merge 順序理由（「convoy 是生產者、磚是消費者，生產者先」）現在【反過來了】**：
**擲出點現在是【寫入記憶的人】** ⇒ 它需要磚的 `structural_id` 形狀**才寫得出正確的 key**。
**照現況 merge，convoy 會用舊 API 寫進記憶，磚 merge 後那些 key 的語意就對不上。**
⇒ ★**我不自己決定順序**（那是你上次明確裁過的東西，我不覆蓋）。**兩條路**：
1. **磚先 merge**（順序反轉），convoy 直接寫新形狀
2. convoy 先，**但擲出點的 record 先不接**（只 emit 喚醒），磚 merge 後再補接線

## §4 閘況（誠實標時點）
★**目前所有閘的綠都是【`051aaa28` 或更早】的** ——
兩事件／latch／`record` 三次改寫**都在其後**。
⇒ ★**我不把它們當本版的綠**，最終一輪會在 code 定版後一次跑齊（headless／憲法／det×3／兩個 scan／床）。
