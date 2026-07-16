---
from: measurer
to: systems
status: consumed
topic: "[量測完·3datum定精確fix+方法論修正] arb_hit=0精確根：75次真到達裡65.3%(49)是賣方漫遊離outpost(_market_pos錯位坐實,owner_settled_here=false)，24%(18)是owner在家但仍零deal_merchant(回②成交條件另一半)，10.7%(8)無owner的怪target；preempt僅21.6%非主因(呼應死法①修正)；★重大方法論修正:TAG_MERCHANT本世界全程0隊(trade_funnel_bed native月報「商隊tag=0」逐月)——真正驅動_merchant_trade_target的閘是ambition_archetype==ARCHETYPE_TRADE(faction_ai:2045)非TAG_MERCHANT,先前用TAG_MERCHANT挑T5是誤判但巧合T5剛好也是ARCHETYPE_TRADE,結論不受影響需訂正"
---

# arb_hit=0 精確根確認：3 datum + 方法論修正

依 `2026-07-15-systems-to-measurer-arb-hit-confirm.md`，自建 `scripts/debug/arb_hit_confirm_bed.gd`（同seed1337同config main，force_full_hd 6月，純觀測不寫state），逐tick盯ARCHETYPE_TRADE隊的到達事件，記到達點對手/tile owner在家與否/preempt vs clean。

## 一次量完（鐵律6）

## ★先講方法論修正（影響你怎麼讀本輪+先前所有merchant相關數字）
本輪一開始用`TAG_MERCHANT`篩隊，**總到達次數=0**——查證後發現：`trade_funnel_bed`原生工具月報早就印過「**商隊tag=0**」**逐月皆0（月1-6全部0隊）**，本世界seed1337**全程沒有任何一隊真的掛`TAG_MERCHANT`**。真正驅動`_merchant_trade_target`(faction_ai_system.gd:2044-2045)的閘是`team.ambition_archetype == AmbitionLadder.ARCHETYPE_TRADE`（8-11隊/月），**非TAG_MERCHANT**。改用正確閘門後拿到下方75筆到達。

**先前session用「貿易task決策數最高」挑T5當「代表商隊」——巧合T5恰好也持有ARCHETYPE_TRADE（動用同一套arb機制），先前的move_target穩定性/29次抵達/[Market]零命中/binding層鎖定等結論仍有效（機制本身沒挑錯），但「TAG_MERCHANT商隊」措辭不精確，正名為ARCHETYPE_TRADE隊，特此訂正避免累積誤導。**

## 3 datum（75次到達，ARCHETYPE_TRADE隊，seed1337 6月）

### datum①：到達點有無對手隊
```
有對手(any team co-located) = 18 (24.0%)
空格(0對手)                 = 57 (76.0%)
```

### datum②：sell-order origin是settled還漫遊（依tile_outpost_owner + owner當下tile_pos）
```
無owner(-1)              = 8  (10.7%)   ← target連outpost都不是,詭異,見下方
owner在家(settled)       = 18 (24.0%)   ← 剛好=datum①的「有對手」全部
owner不在家(漫遊)         = 49 (65.3%)   ← ★★★主因
```
**owner_settled(18) 與 with_opponent(18) 完全對齊**——merchant到outpost時，「有沒有人在」100%取決於「owner在不在家」，非別的因素。**65.3%的到達是merchant走到一個outpost，但那outpost的主人早就離家去覓食/建設了——`_market_pos`固定抓outpost座標，但賣方隊實際位置跟座標脫鉤，這是最大宗（65.3%）。**

樣本(Team8→Team0的outpost(12,8)，反覆8次到達全部owner不在家)：
```
tick329/449/629/749/809/929/1109/1229 team=8 pos=(12,8) others_present=[] owner=0 owner_settled_here=false
```
（同一merchant反覆回同一空outpost，同earlier死法①/binding層trace看到的「T5反覆到(4,9)/(6,9)撲空」同款病灶，本輪精確坐實owner不在家是直因。）

### datum③：merchant commit到底 vs 中途preempt漂走
```
preempt(FLEE/DEFEND) = 22 (21.6%)
clean(正常轉場)        = 80 (78.4%)
```
（呼應先前死法①修正後的結論：真preempt占少數，多數是正常任務轉場，非本輪主因。）

## 判定 → 精確 fix 形狀
依你信裡的判準表對照：
- **賣方漫遊離outpost（_market_pos錯位）→ 65.3%坐實，是主因**。Fix方向＝merchant target賣方**實位/belief_pos**（鏡射`_refresh_attack_pursuit`追belief）。
- **賣方settled但merchant沒真到那格**：datum①②完全對齊(18=18)顯示「owner在家時merchant一定同格會遇到」，**沒有「owner在家但merchant沒到」的case**——這條路徑不成立，排除。
- **merchant多被preempt中途漂走**：21.6%，少數，非主因。
- **到了有對手但成交擋**：24%(18次)owner在家co-located，但`trade.deal_merchant`全程仍是0——**這18次全部卡在②另一半（成交條件本身）**，與liquidize驗證(HALT)看到的「meet了但meet_nodeal」同一道牆，非本輪新病。

## 待你裁
1. 主刀＝賣方實位/belief_pos修正（解65.3%大宗）。
2. `owner=-1`（無owner，10.7%，8次）的target詭異——merchant走到一個根本不是任何人outpost的格子，是fallback邏輯（code comment提過「無arb→巡最近市集」）還是bug，我可以另查code或補trace。
3. 18次owner在家仍零deal_merchant——這是①(位置)修好後才會浮現的下一層真章（成交條件/liquidize那道牆），先擱置等①上線再驗，或現在就併查？

---
measured_at_head: main(3739e6f0)
raw: docs/measurements/2026-07-15-arb-hit-confirm-v2-main.log（UTF-16 tee，Grep工具讀；v1(main.log,誤用TAG_MERCHANT閘,0筆)留存供對照方法論修正過程）
bed（純觀測,不寫state,真實advance_tick跑）: scripts/debug/arb_hit_confirm_bed.gd（已同步main dir）
