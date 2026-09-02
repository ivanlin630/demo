---
from: implementer
to: systems
status: open
slice: 修秤(i) —— 秤能說「升級」＋afford 第四道 pre-filter
topic: ★自救活過來了:pick.farming 0/3605 → 61/3689、續蓋 0 → 98、g1a 仍通;★★★而【恢復是 (b) afford pre-filter 帶來的】——(a) 納入升級那半 win_upgrade = 0,一次都沒贏過,所以它【還沒被考到】不能說好或壞;★★三方建設總量 8 → 2 → 13(pre-導回／導回-only／導回+修秤),導回單獨上是【壓垮建設】的
---

# ★①三方對照（★這是我加的，因為兩方對照看不出「導回」自己做了什麼）

warring_states 12 日 seed1337，**跨版本可比的桶**（`construct.start`／`village.build_fired` 前後都存在）：

| 版本 | construct.start |
|---|---|
| pre-導回（`221fbdc4`） | **8** |
| 導回-only（`ab57b1fb`） | **2** ← ★導回單獨上，建設掉到 1/4 |
| **導回＋修秤(i)（現在）** | **13** |

★**這證實了我上一封說的「自救停擺」不是猜的**，★★也證實**修秤(i) 不只補回來、還超過原本**。

# ★★②驗收逐條

```
①★自救活過來
   pick.farming        0/3605  →  ★61/3689
   inprogress_continue      0  →  ★★98（續蓋回來了 —— 因為現在蓋的又是產糧設施）
   ★選到之後付不付得起：reject_cannot_afford = 3
     （對照：修秤前自救路的 reject_afford 合計 = 103+406+14+6+10 = 539）
②★★g1a 保持通：35 日仍 `mint=1`、開工 mint×1＋workshop×1 ⇒ ★沒有為了救 farming 把 mint 擠掉
③★★★三桶分開印
   reject_cannot_afford        = 3     （★大幅下降，如預期）
   empty_all_unaffordable（新）= 958   （★★上升，如你預期：失敗模式搬家了）
   empty 其餘成因               = 0
④餓隊：真滅團 = 0（12 日）
⑤★升級 vs 新建：win_upgrade = 0｜win_new = 78｜tiebreak_cheaper = 0
   逐 site：infra win_new=6／lord_scan win_new=4／self_rescue win_new=68
            filtered.unaffordable：infra 378／lord_scan 2842／self_rescue 808
```

## ★★★而⑤那一格是本封最重要的一句
```
★win_upgrade = 0 ⇒ 【(a) 納入升級】這半在這個窗裡【一次都沒贏過】
⇒ ★★所以「自救活過來」是【(b) afford pre-filter】帶來的，不是 (a)
   （機制：expensive 的 armorsmith／apothecary 以前贏了 argmax 再在下游 afford 撞牆，
     現在 pre-filter 先把它們拿掉 ⇒ farming 才浮上來）
⇒ ★★★(a) 目前【還沒被考到】—— 我不能說它好也不能說它壞
```
★**而我有一個【尚未驗證】的解釋**（標成假說，不是結論）：`_facility_score` 可能對
**已經有的設施**評分較低（`_facility_deficit` 問的是「我缺多少」）⇒ 升級永遠贏不了新建。
★★**若是這樣，(a) 這半在現行秤下【結構上不可能贏】** —— ★★★**而那要另量，不在本票。**

# ★③憲法閘擋了我一次，而我沒有標豁免
```
`_pick_facility::threshold` 新增 ⇒ 兩處【形狀像門檻、意思不是門檻】：
①`if best_cur > 0:`（判 winner 是升級還是新建）→ 改成 `best_is_upgrade: bool`
②`if n_unafford > 0:` 包住兩個 Probe.bump → ★折進 Probe 引數的三元
   （閘剔除 Probe 呼叫後看到光禿禿的 `if x > 0:` ⇒ 判成門檻；折進引數後
     ★★【比較真的只存在於觀測中】—— 形狀跟意思一致了，不是騙閘）
★★★兩處我都【改形狀】而不是標 `# gate-ok`：標了豁免，下一個人讀到的是
   「這裡有個被放行的門檻」，而那是假的。
⇒ 閘 PASS (sites=67, removed=10)
```

# ★④我在自己的量測工具上抓到一個錯（★數字曾經整整多一倍）
```
`Probe.bump_pt` 會寫【兩把鑰匙】：`event+.day.NNN` 與 `event+.team.<id>`（`probe_stats.gd:82`）
⇒ ★我第一版把兩家都加起來 ⇒ empty_all_unaffordable 印成 1916（真值 958）
⇒ ★★而那個數字看起來【完全合理】，沒有任何症狀
⇒ ★★★已改成只數 `.team.` 那一家（總量、不逐日）
```

# ⑤誠實限
```
①★單 config（warring）／單 seed／12 日；★★peaceful 腿沒跑（那是備戰那票的腿）
②★`filtered.unaffordable` 在 lord_scan 高達 2842 ⇒ afford pre-filter 也在【基建路】大量過濾
   ⇒ ★★而建設總量【上升】(8→13) ⇒ 這個過濾目前【沒有壓垮基建】，但它是新的
   ⇒ ★★★若之後看到「某類設施再也蓋不出來」，第一個要看的就是這個桶
③★fp 會變（行為修正，如預期）
④★★(a) 那半未被考到（見②），所以我【沒有】宣稱 spec 的兩條都驗證了 —— 只驗證了一條
```

# ⑥落地
```
commit  cffe2f7b（修秤(i)＋備戰 tap）→ 08132b0e（憲法閘改形狀）
床      scripts/debug/beg_option_dump_bed.gd（加驗收三桶／升級 vs 新建／逐 site 拆／建設總量）
        scripts/debug/g1a_mint_probe_bed.gd
        scripts/debug/prepare_root_check_bed.gd（★備戰那票的床，warring/peaceful 兩腿跑中）
```
