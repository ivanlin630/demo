---
from: systems
to: implementer
status: consumed
topic: "[補甲distribute診斷第4 root角度(用戶戳出,加進feat/jia-distribute-diag同批,別pre-conclude):除原(i撮合local-only/ii convoy決策不fire/iii訊息斷received_buy_orders空)外——(iv)交易面太窄+surplus有沒流到公庫·背景:交易面=只屋主public_storage公庫(interaction:731-813,visitor只跟outpost owner交易+只買公庫貨,隊自己team.resources私產+同格非owner隊都非交易面,設計選擇interaction:742市場鏡射舊pairwise)·∴order_placed 426/fulfilled=0一大塊可能=貨在隊team.resources手上但沒流到可撮合面public_storage→賣不掉·加tap:①sell order代表的surplus是team.resources還是public_storage?(貨在哪)②surplus有無流到市場公庫(徵收tax/manufacturing output/convoy DELIVER哪條把私產→公庫)?③非owner同格隊能不能交易(撮合面是否排除)?·兩讀法measure定(禁猜):A市場-only intended但surplus流公庫斷了=修flow(私產→公庫哪環斷)/B市場-only太窄該加隊對隊尤同格·純觀測tap零行為變·同batch落地docs/measurements→我讀四角度(i/ii/iii/iv)定真root·別下修結論只交真值"
branch: feat/jia-distribute-diag
---

# 補甲 distribute 診斷第 4 root 角度（用戶戳出、加進同批）

原診斷（`2026-08-03-systems-to-implementer-jia-distribute-zero-diagnostic.md`）測 (i撮合local / ii convoy決策不fire / iii訊息斷)。★**用戶戳出第 4 角度、加進同批（別 pre-conclude）**：

## (iv) 交易面太窄 + surplus 有沒流到公庫
- **背景**（blueprint 讀 interaction:731-813 確認）：**交易面 = 只屋主 public_storage 公庫**——visitor 只跟 outpost owner 交易 + 只買公庫貨；**隊自己 team.resources（私產）+ 同格非 owner 隊 都非交易面**（設計選擇 interaction:742「市場鏡射舊 pairwise trade.meet」）。
- ∴ **order_placed 426/fulfilled=0 一大塊可能＝貨在隊 team.resources 手上但沒流到可撮合面 public_storage → 賣不掉**。

## 加 tap（同 batch）
1. **sell order 代表的 surplus 是 `team.resources` 還是 `public_storage`?**（貨在哪）。
2. **surplus 有無流到市場公庫?**（徵收 tax / manufacturing output / convoy DELIVER——哪條把私產→公庫、有沒有斷）。
3. **非 owner 同格隊能不能交易?**（撮合面是否排除同格非 owner）。

## 兩讀法（measure 定、禁猜）
- **A 市場-only intended 但 surplus 流公庫斷了**＝修 flow（私產→公庫哪環斷）。
- **B 市場-only 太窄該加隊對隊**（尤同格）。

## ★加：同格 willing-matchable 量（用戶 WHAT 定調交易面、量 unstall 上限）
用戶 WHAT：**任兩同格、雙方都想交易→就能成交（用各自 team.resources、非只公庫）**＝恢復 pairwise 一般性（同格 bounded、tile→teams 索引、非 O(N²)）。**先量此原則能 unstall 多少**（純觀測、零行為變）：
- **426 未成交 buy-order 中、有多少存在「同格（同 tile）+ 該貨在某隊 team.resources 手上 + 對方 willing」的對手方**（＝若交易面放寬到同格 team.resources 就能**立即 fulfill** 的筆數）。
- 對照：**剩下多少是隔格**（同格無對手方 → 仍需 convoy 物理橋接 / 訊息傳播湊）。
- ∴ 產出一條 **「同格立即可 fulfill X 筆 / 隔格仍需 convoy Y 筆」** 的拆分 → 我定「同格 pairwise 解多少、convoy/訊息 remainder 多少」。
- ★守感知鐵律：同格＝物理在場零 god-view（tile.teams 是真在場、非隔空讀值）。

純觀測 tap（零行為變）。**同 batch 落地 `docs/measurements/`** → 我讀四角度（i/ii/iii/iv）+ **同格/隔格拆分** 定真 root。**★別下修結論、只交真值。** 卡 → 報 `to:systems`。
