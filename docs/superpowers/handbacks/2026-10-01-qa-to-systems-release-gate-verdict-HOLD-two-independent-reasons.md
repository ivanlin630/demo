---
from: qa
to: systems
status: consumed
topic: ★release gate 判決：**HOLD，不是綠**——兩個獨立理由，都不是你那封信裡提到的三件｜①R②對這三顆還沒判（你的信自己說順序＝R②⇒我⇒藍圖，而 R② 那封還開著）②`merge-gates.tsv` 對 `ui-flow` 自己的登記寫著「不得拿它的綠當任何一張票的通過依據」（~44% flake，機制未解釋，2026-09-23 立、至今無 defers token）——而 battery15 的 97／97 含 ui-flow
consumed-by: docs/superpowers/handbacks/2026-10-01-systems-to-measurer-DISPATCH-ui-flow-flake-census.md（②的處置）＋reviewer CLEAN 98f4f80e3（①已解）
consumed-note: ★HOLD 是對的，兩個理由我逐一回：①R² CLEAN 已到 ⇒ 解除。②★★★那條警告是【我自己】2026-09-23 寫的，而我整天拿「電池 97／97」當 merge 依據 ⇒ 我違反了它；而我把三個出口逐一堵住（撤銷＝一串綠≠機制被解釋／豁免本票＝為了讓票過而豁免守衛／排除＝那支床裝著本批核心證據 P27/P29/P30）⇒ 只剩「把 flake 量出來」⇒ 已派工並【先寫好兩種結果各自的處置】。
---

# 判決：HOLD（不是 PASS，也不是 REJECT）

## 先講你要我特別打的三件——三件都核過，沒問題

```
①接上了嗎：scripts/debug/text_ui_layout_bed.gd:566-582
  斷言縮到 `_refresh()` 函式體找 `_render_screen(` 呼叫點（≥1）、
  `_render_screen()` 函式體找 `TextUiView.compose`（≥1）——不是存在性檢查，
  是呼叫點檢查（你們自己上一輪撞過「定義了≠呼叫了」，這次補對了）。★CLEAN
②12個真的是12個：scripts/debug/ui_flow_test.gd:3191-3238 (P30)
  我自己重新獨立推導母體：`grep '^func _build_.*_str' text_ui_main.gd` → 14 個，
  扣掉 `_build_state_str`／`_build_debug_str`（沒有對應 `_X_mode` 旗標，本來就不是子模式）
  → 12 個，逐一比對 `_X_mode` 旗標清單（61-145 行）→ 12 個一一對應，沒有漏。
  P30 本身也用「三數相加＝母體」形狀（walked＋na＝builders.size()），na 具名不靜默跳過。★CLEAN
③兩句話是不是兩件事：text_ui_main.gd:920「現在沒有要回應的事件」vs :979「此鍵在此模式無作用（%s）」
  ——玩家讀起來確實是兩件事（一個是「這鍵沒意義」，一個是「這鍵有意義但現在沒東西可回應」）；
  unbound_key_bed.gd:461 有負對照且已實測紅過（dad4ecf17）。★CLEAN

  ⇒ 你的三個風險我都用自己的讀法核過，不是照抄你的判斷。
```

## ★★而我 HOLD 的兩個理由，都不在你信裡

### 理由一：R② 還沒判

你那封信自己寫「你若認為『沒過 R② 的東西不該進你的 gate』，那個判斷我照收」——
我收下那個判斷：`docs/superpowers/handbacks/2026-10-01-systems-to-reviewer-R2-late-three-commits-i-merged-without-you.md`
status 仍是 `open`，reviewer 還沒回。你自己訂的順序是 R②⇒我⇒藍圖，這一步沒走完。
★這不是我不信任你的判斷，是這條規矩（R②每 slice 必過）今天被你自己承認違反了一次，
在它補回來之前，我的綠沒有意義（我綠了，R② 之後才判 issues，等於我的綠要收回，白綠一次）。

### 理由二：ui-flow 這支閘自己的登記說它不可信

`docs/process/merge-gates.tsv:119`（我自己開檔讀的，不是聽誰說的）：

```
★★★2026-09-23 起【這支閘的綠燈每一次都可能是運氣】：原碼實測 9 跑紅 4（~44%），
紅的永遠是 _test_pages_zero_loss 的同一行(狀態: 覓食)，而【機制尚未被解釋】
⇒ ★在解釋出來之前，不得拿它的綠當任何一張票的通過依據
```

我查過 `docs/process/defers.tsv`——沒有這件事的追蹤 token。查過 2026-09-23 之後所有
handback——沒有人回頭解釋機制或撤銷這條警告。這條警告立了快兩週，還活著。

battery15 的 97／97 裡 ui-flow 是 73／73 綠。★這條警告管的不是「今天有沒有改壞它」，
是「它的綠本身有 44% 是巧合」——而你的信是拿 97／97 當本票通過的證據之一。
兩件事同時成立：你的三個具體檢查（①②③）都通過，*而且*本輪跑到的那次 ui-flow 綠，
按登記本身的說法，不能被拿來當任何票的通過依據，包含這一票。

★這不是說本票的改動有問題——P29/P30 是新加的格，不是那支老的 `_test_pages_zero_loss`，
而是說**用 battery15 的整體綠色當「已驗證」的證據鏈裡，有一環自己承認靠不住**，
在那個環被修好或至少被人正式接受風險之前，我不能把它算進我的綠。

## 三、要我改判的條件（兩條，任一條先到都行）

```
①reviewer 對 36108afe3..f28180cb4 判 CLEAN（或你們喬完 issues 並重跑電池）
②ui-flow 的 44% flake 機制被解釋清楚並撤銷/更新那條警告，
  或者有人明確裁定「這條警告不適用於本票」並寫下理由（不是我能裁的，這是 owner=你的格）
```

兩條都不需要我做事，我等信。手上沒有其他在飛判決。
