---
from: systems
to: reviewer
status: open
slice: 裁定(A)——把每小時那一趟 pass 按隊錯開相位
topic: R² 審設計｜spec `docs/superpowers/specs/2026-09-23-stagger-the-hourly-pass-HOW.md`（commit 77e28104a）｜★我自己最沒把握的五個點列在 §B，請優先打那五個｜★★其中一個我在寫的過程中已經自打臉一次（空批次那段），形狀還在，理由換了
---

# §A 這張票是什麼

blueprint 已裁 (A)：**頻率不動**（每隊仍每小時決策一次），只把「在**哪一顆** tick」
按隊散開。前置票（faction_ai 吃自己的批次）已 merge `16c5e0409`，指紋逐字未變。

spec 在 `docs/superpowers/specs/2026-09-23-stagger-the-hourly-pass-HOW.md`（`77e28104a`）。

---

# §B ★請優先打這五個（我自己最沒把握的）

## B1 §1 那個減法，分母真的共用嗎

我沒有重新量，我是**從既有卷面相減**：

```
S_fixed(含 faction_ai) = 70.3%（seed1337）／72.5%（seed42）
faction_ai 單格        = 50.8%          ／45.6%
⇒ S_fixed(post-fix)    = 19.5%          ／26.9%   ⇒ 都在 40% 門檻內
```

★**這整個推導只靠一件事**：那兩個百分比共用同一個分母（卷面寫 `pass_dt_over2s`）。
★★我在卷面上確認它們共用，但那是我讀的、不是我量的 ⇒ **請當成待驗斷言打**。
★★★若分母不共用，這張 spec 的「值不值得做」那一段就沒有根據（驗收 P1／P7 仍然會抓到，
但那是花完整個 slice 之後才知道）。

## B2 分組表裡我最可能放錯的三支

```
events      放【錯開組】—— 它產生的事件被別人消費；若有消費者假設「事件都在整點出現」，
                          錯開會讓它們在任何一顆 tick 冒出來
cleanup     放【錯開組】—— npc goal cleanup；我沒有逐行確認它不碰別隊的 goal
ambush      放【錯開組】—— ★它的 encounter 早退會從「只在整點」變成「任何一顆 tick」
```

★**判準請用你自己那條**（你第二輪給我的，比我的「雙層 for」準）：
**「內層迴圈的資料來源是 `team_ids` 批次，還是 `state.teams` 全域」**。

## B3 `>=` 而不是 `==`，以及它擋住的那個靜默失效

```gdscript
var due: bool = cur >= team.pass_next_tick
```

`ambush` 早退會讓一顆 tick 後半段的系統沒跑。若寫 `==`，錯過的隊**從此再也不到期** ——
而那是**靜默**的：它不會紅，它只會變窮然後餓死。
★請打的是：**還有沒有別的路徑會讓一顆 tick 提前結束**（我只找到 ambush 那一條）。

## B4 §4d 那個「誤差會自己抵銷」的論證

`teams_cadence` 那 5 支仍然收到 `cadence = 60`，但實際間距是 `60 + (o_{k+1} − o_k)`。
我的論證是 telescoping：

```
N 次後累計實際 = N×60 + (o_N − o_0)   ／ 累計發放 = N×60
⇒ 誤差 = −(o_N − o_0) ∈ [−59, +59]，有界且不累積
```

★**我自己知道的漏洞**：`CadenceStagger` 的 wrap clamp（`MIN_GAP = 30`）會打斷 telescoping。
我的處置是加 tap ＋ 床斷言間距落在 `[30, 119]`。
★★請打的是：**clamp 觸發的頻率有沒有可能高到讓誤差變成系統性的**
（例如某些 team_id 的 offset 序列特別容易撞 clamp ⇒ 那一隊長期少拿）。
★★★這一格若破了，受害的是**同一批固定的隊**，而 P4（餓死數同量級）**未必抓得到**
——因為它看的是總量。

## B5 §4e 那個樁：我聲稱「關掉 ⇒ 指紋與世代 7 逐字相同」

這是本票最強的一格（它把「我重構壞了」跟「錯開改變了世界」分成兩個可以各自判的問題）。
★但它成立的條件是 **§4c 那一行空批次 `continue`** ——
★★而我寫那一行的**理由**在寫 spec 的過程中被我自己推翻過一次：

```
我原本寫：LaborSystem.ensure_fresh 會全域掃 ⇒ 空批次不是 no-op
開檔之後：★不成立 —— ensure_fresh 吃的是單一 tile，由 per-team 迴圈【內部】呼叫
        ⇒ 批次為空時那個迴圈一次都不跑
⇒ 形狀留著，理由換成【構造保證】：我不想靠 14 支系統各自剛好是 no-op（那是清單保證）
```

★★★請打的是：**這個等價聲稱本身**。我說「樁關掉 ⇒ 每一顆非整點 tick 什麼都不做
⇒ 那一趟 pass 與今天逐字相同」。若 `_run_systems` 在我沒注意到的地方有
**每次呼叫都會發生的副作用**（例如 `check_registry_assumptions()` 的 latch、
`_ph` 相位表、或任何 static 狀態），這個等價就不成立，而**它失效的樣子是指紋紅** ——
★看起來會像「錯開改變了世界」，**歸因會指到錯的地方**。

---

# §C 我已經自己處理掉的（列出來免得你重打）

```
①faction_snapshot（你第二輪坐實「會壞、靜默漏」）⇒ 用【擺位】解：留在整點組，一行 code 都不改
   ★問題消失是因為前提消失，不是因為我們修好了它（spec §3c 寫死這句）
②乙組 6 支（propagate/intel/market/interactions/move/vision）你沒逐行證完
   ⇒ 全部保守留在整點組；它們合計 500.0ms／pass，本來就在門檻內（spec §7④）
③forced_event 逾時區塊「該掛哪個 phase」⇒ 我按 HOW 自己裁了：留整點（語意逐字不變）
   ★這是可逆的一行，blueprint 要別的擺法隨時改（spec §3d）
④§2 那個取樣格的坑 —— code 裡已經有人踩過並留了字（sim_runner.gd:403-409），
   我把那段逐字引進 spec，並讓 P3 成為抓它的那一格
```

---

# §D 我要的 verdict 形狀

```
CLEAN            ⇒ 我 dispatch 給 implementer
issues           ⇒ 逐條帶 file:line，我改 spec 再送一次
premise_contradiction=true ⇒ halt，我回 blueprint
```

★**不要只回「看起來合理」**：B1 與 B5 是**斷言**，不是意見 ——
它們錯的時候，症狀都出現在**花完整個 slice 之後**。
