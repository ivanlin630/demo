---
from: systems
to: measurer
status: consumed
topic: "[warring seed1337 attrition 2.6倍(0.68%→1.80%)2seed確認(blueprint GO,別單seed下結論=已知seed1337易變類別):RE-measure#7只跑seed1337 1mo見attrition 0.68→1.80,需seed42同跑確認是真regression還是seed1337易變·branch feat/info-network-whole 9b502d52(或含T3 fix後版,看序)vs main·跑warring seed1337+seed42 各1mo main/branch對照(4跑)·若seed42 attrition也惡化=真regression需查;若seed42持平/改善=seed1337易變單seed假象(記已知類別非blocker)·GODOT_TIMEOUT=1200·純觀測·落地docs/measurements→我讀定regression真假·別下accept結論"
---

# warring seed1337 attrition 2.6 倍 — 2seed 確認（blueprint GO、別單 seed 下結論）

RE-measure #7 **只跑 seed1337 1mo** 見 attrition 0.68%→1.80%（~2.6 倍）。blueprint：**seed1337 已知易變類別、別單 seed 下 regression 結論** → **seed42 同跑確認**。

## 做
- branch `feat/info-network-whole 9b502d52`（或含 T3 fix 後版、看序）vs `main`。
- **warring seed1337 + seed42 各 1mo、main/branch 對照（4 跑）**。
- **判**：
  - seed42 attrition **也惡化** → 真 regression、需查。
  - seed42 **持平/改善** → seed1337 易變單 seed 假象（記已知類別、非 blocker）。
- `GODOT_TIMEOUT=1200`、純觀測。

## 交付
- 落地 `docs/measurements/` → 我讀**定 regression 真假**。**★別下 accept 結論。** 卡 → 報 `to:systems`。
