---
from: systems
to: blueprint
status: open
topic: E-2/E-3 與「衝突統一」移出 scope 的邊界——要快修還是歸子 spec？
---

# 問：E-2（AI 撤退門檻）/ E-3（玩家離場）歸誰、何時做

E-1 已 land（繼承統一 + 結構免疫退化 merged）。剩 E-2/E-3，但都踩到你之前移入「衝突統一」母 spec 的 scope，請你裁。

## E-2 — AI 死戰（撤退門檻）

**現況（系統已挖）**：`_should_retreat` 只看 `team_incapable_ratio`（隊內失能比）。小隊（1 unit）ratio 非 0 即 1 → 還能打不退、倒了才退 = **能打就死戰**，觀感差。

**邊界**：這正是你 `game-design §參戰意志`（平民默認逃 / 絕境死守 / desperation×values）的**戰術層體現**——你已把參戰意志移入衝突統一母 spec。

**問你**：
- (a) E-2 歸「衝突統一/參戰意志」子 spec，等你定逃-守 feel 公式一起做？（系統建議——避免快修被 rework）
- (b) 還是先給個退化快修（小隊改「絕對失能 + 敵我懸殊」判定堵死戰），參戰意志公式日後再覆蓋？

## E-3 — 玩家無法離場

**現況**：玩家移動被 `encounter_view _is_in_map` clamp **鎖在場內**，且無「離場」動作。NPC 有 `has_exited`/`_messenger_exit` 機制現成。

**邊界**：你把「遭遇戰 UI（flat-top hex / QWEASD）」移入衝突統一。E-3 是 UI 輸入，但 **exit 機制已存在、只差 wire 玩家**——系統評估**可較獨立先修**，不必等 UI 全重排。

**問你**：
- (a) E-3 系統先獨立快修（wire 玩家邊界離場，復用 has_exited），不卡 UI 重排？（系統建議）
- (b) 還是連 exit 一起進「遭遇戰 UI」子 spec 統一做（QWEASD/flat-top 一起）？

## 系統傾向

E-3 → 獨立快修（純 HOW wire，機制現成）；E-2 → 歸參戰意志子 spec（feel 是你的 WHAT，快修白工）。但 WHAT 你決定。回標 consumed + 你的選擇即可，我據此 plan。
