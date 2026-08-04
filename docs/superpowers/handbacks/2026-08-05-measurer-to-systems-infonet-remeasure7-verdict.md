---
from: measurer
to: systems
status: open
topic: "RE-measure#7症1端到端閉環verdict:★★機制層真閉環——distribute.deliver bail全歸零(0 bail keys,前輪5/6 sell_owner_no_coin/sell_ownerless)、food_delivered 1.0→58.0(9次真settle)。★★outcome層T1真救活——alive_at_end true(前6輪首次撐過day60),食物day6/17/55三次真回升注入(0→24.3/0→8/0→7.3)且day55後穩定6-7.3持續到day60,非曇花一現。但T3(從未派letter,同faction2但被T2神秘忽略)死因/死時點與前6輪完全不變(day42/tick10080)——T2(neglectful lord)這兩輪convoy home/leader皆指向自己卻market目標鎖定T1(faction1的resident,非自己faction2的T3)★跨faction relief目標錯位,連續2輪重現,純觀察不下因果。warring seed1337 1mo regression:attrition 0.68%→1.80%(~2.6倍,同已知seed1337易變類別,只跑1seed非2seed)、distribute仍0(warring窗inert,呼應implementer原報告)、coin守恆經code讀確認(bid=0雙向no-op數學上必零,非runtime雙式帳審)。determinism persist bed 2跑byte-identical(除TickPerf)。已誠實回報不下accept，機制層/outcome層分開判"
---

# RE-measure #7：症1端到端閉環真值（誠實分機制層/outcome層，別下 accept）

## ①重跑 setup

- against `feat/info-network-whole 9b502d52`（免費直注 fix）。
- 用已 persist 的床（`config/infonet_whole.json` + `scripts/debug/infonet_whole_diag_bed.gd`，`0b599dc8`），沒改一字。
- `GODOT_TIMEOUT=1200`。跑 2 次（determinism check）。

## ②★★機制層：真閉環

```
distribute.dispatch=5 convoy.deliver(arrive)=2 convoy.deliver_settled=2 distribute.deliver(settle)=9 food_delivered=58.0
```

- **★bail 全歸零**：本輪 print 迴圈掃 `convoy.deliver_bail_*` 一個 key 都沒印出來（=全部 count=0）。對照 RE-measure#6 同 seed 同 fixture：`sell_owner_no_coin=4 / sell_ownerless=1`（5/6 bail）。**免費直注 fix 確實把 settle 站的 bail 清空了**。
- `food_delivered` 1.0→**58.0**，`distribute.deliver`(settle)=9 次真交付（非卡在 1 次不動）。
- porter 逐站表本輪出現 4 個 porter id（10/11/12/13），3 個 `GONE_mid_OUTBOUND`／1 個 `DELIVERED_then_gone`——**★誠實揭露 bed 本身限制**：porter 生命表用 `tid` 當 key，同 id 若被重派會疊加進同一筆記錄（RE-measure#6 就是 6 次 dispatch 疊成 1 筆），本輪 5 次 dispatch 對 4 個 id，讀不出精確的「逐次」對應，`GONE_mid_OUTBOUND` 標籤在此已知有假陽性風險（cargo 真減少但因新一輪覆寫未必被本 bed 抓到）——**這是量測工具的已知盲點，非新黑洞證據**，真正可信的彙總數字是 Probe tap（dispatch/deliver/bail/food_delivered），不是逐 porter 表本身。

## ③★★outcome 層：T1 真救活，T3 依舊零救援

**T1**：`alive_at_end=true`（★前 6 輪 T1 從未撐過 day60，本輪首次）。
- 食物曲線出現 3 次明確 relief 注入：day5→6（0→24.3）、day16→17（0→8）、day54→55（0→7.3），第三次注入後 **day55-60 穩定維持 6-7.3**（非單次曇花一現，是持續補給的痕跡）。
- pop 仍在 day15 觸底 2 人後不再回升（relief 只救活了殘存的 2 人，沒讓 team 重新繁盛），但**確實不再滅團**——runway 真回升、真活下來。

**T3**：`alive_at_end=false death_tick=10080(day42)`——**跟前 6 輪完全逐位元一樣**（同 tick、同 last_task、同 pop 曲線），`letter_dispatched` 仍 `false`。本輪修法對 T3 **零效果**。

**★連續 2 輪重現的結構觀察（純觀察不下因果）**：兩輪（#6、#7）porter 的 `home` 座標都精確落在 T2（neglectful 領主，faction2）的 tile `(14,8)`、`market` 都精確落在 T1（faction1 的 resident）的 tile `(18,14)`——即**實際送賑濟的是 T2（"疏忽型"領主），送給的目標是 T1（不屬於自己 faction 的 resident），而非 T2 自己 faction 的 T3**。這解釋了為什麼 T3 全程零 letter/零 relief：本輪唯一活躍的 distribute 通道根本沒對準它。只讀 tap/log 觀察到此，未讀 `_distribute_candidates`/belief-resolve 相關 code 確認因果，交你們判斷是否為既有跨 faction 目標錯位。

## ④arc 迴歸（warring seed1337 1mo）

```
                          main(baseline)   branch(9b502d52)
attrition                0.68%            1.80%
teams/final               84               105
help.letter_dispatched     0                 1
help.delivered              0                 0
help.severity_positive      0                83
help.target_resolved        0                 4
scout.dispatched             0                38
distribute.dispatch          0                 0
trade.deal                  36                98
g1.order_placed            1374             1514
g1.order_fulfilled            5                29
convoy.dispatch              30                48
convoy.deliver_settled         7                12
```

- `distribute.dispatch=0` 在 warring 1mo 窗仍是 0——跟 implementer commit message 自報「free-relief 在此 warring 窗 inert」一致，非新問題（distribute candidate 在此規模/時窗從未 applicable，本 fix 沒有、也不該改變這點）。
- **★attrition watch**：0.68%→1.80%（約 2.6 倍）。本輪只跑 seed1337（★未跑 seed42，效率考量：implementer commit 已自報 seed1337 1mo 3-run determinism byte-identical，這輪我的重點驗證放在 persist bed 機制/outcome 層,warring 只做單 seed 抽驗）。這波 attrition/team 數上升，跟過去 4 輪（RE#3-#6）反覆出現的「seed1337 易變、seed42 常穩」同型 seed-cascade 類別一致方向,不代表因果,單 seed 不足以下結論,如實回報供你們留意。
- **coin 守恆**：讀 `interaction_system.gd:850-885` 本輪 diff——`free_dist` 路徑 `bid=0`，兩端 `ResourceBank.add` 皆乘 `bid`（=0）,`owner==null` 時整段跳過 owner 側扣款,數學上必為 no-op。**此為 code-read 驗證,非 runtime 雙式記帳審計**（沒有另外掛 coin 逐 tick sum 追蹤）,如實聲明範圍。

## ⑤determinism

- persist bed 2 跑（`run1`/`run2`）逐行 diff，扣 `TickPerf` 計時行後 **零差異**（byte-identical）。

## 落地檔案（已 ls/wc 驗證存在）

- `docs/measurements/2026-08-05-infonet-remeasure7-whole-run1.txt`（1511行）/ `-run2.txt`（1511行,determinism對照)
- `docs/measurements/2026-08-05-infonet-remeasure7-diagnostic.json`（819行,結構化 dump）
- `docs/measurements/2026-08-05-infonet-remeasure7-warring-main-seed1337-1mo.txt`（7226行）/ `-warring-branch-seed1337-1mo.txt`（8859行）

## 清理狀態

- warring_harness.gd 本輪加的 temp PROBE_KEYS(help./scout./trade bail)+SpecimenDumpHelper hook 已用 `git checkout --` 還原確認乾淨。
- temp `infonet_warring_compare_bed.gd`（main+worktree 兩邊）已刪除。
- persist bed（`config/infonet_whole.json`+`infonet_whole_diag_bed.gd`)本身不動,仍在 branch 上原樣持久。

## ★誠實淨判

- **機制層**：真閉環——distribute.deliver 5/6 bail→0 bail、food_delivered 1.0→58.0，這是本 fix 明確達成的目標,證據扎實。
- **outcome 層**：T1 真被救活（首次撐過 60 天）,但**只對 T1 有效,T3 完全沒被觸及**（連續 2 輪同一組座標鎖定同一個跨 faction 目標,純觀察）。「症1 端到端真閉環」若指「機制真的能讓一個瀕死 resident 存活」——★成立(T1)；若指「所有瀕死 resident 都被覆蓋」——★不成立(T3 依舊零救援,原因疑似目標錯位非量級不足)。
- 別下 accept，機制層/outcome層/T3零覆蓋 三線交你們判 arc-done vs economy-balance/target-resolve follow-up。
