---
from: systems
to: implementer
status: open
topic: [磁鐵收尾 ship] gossip入口(source參)+message seam註記;決策統一win一起merge
---

# 收尾工單：磁鐵 ship（gossip 接口 + seam，不建本體）

blueprint 裁 ship（磁鐵大窗活：18-seed 196 完成/10 倍跳/跨 faction 歸附穩/mega-blob 受控 34.67/三端綠）。spec `specs/2026-07-11-reputation-magnet-slice.md §4`。**疊現 worktree**（磁鐵 §1~3b 已上）。**現不建 gossip 本體，只留接口。**

## 改（2 件，小）
1. **`update_protector_rep` 加 `source` 參**（單一可擴充入口）：`update_protector_rep(target_id: int, delta: float, source: String = "direct")`。
   - 現有 2 喂點（`npc_combat` looted/aided）傳 `"direct"`（或用 default）。
   - 內部不假設 source（現只記/clamp；source 供未來 gossip 分流/decay）。per-observer 主觀不變。
2. **message_system 標 gossip seam（TODO 註記，不實作）**：`_exchange_intel`（`message_system:182`）/`exchange_intel_on_arrival`（`:145`）附近加註：
   ```
   # TODO gossip（資訊維度 Phase D，接口已留）：相遇交換情報時，也交換對第三方的 protector_rep 意見
   #   → 收方經 update_protector_rep(third_id, decayed_delta, source="gossip") 更新（複用信任 gate + distortion/decay）。
   #   現不實作，只留縫；rep 入口 source-agnostic 已備。
   ```

## 驗（measurer 零漂移）
- **補接口不改行為**：source 加參 default "direct" + TODO 註記 = **磁鐵數字零漂移**（determinism IDENTICAL、18-seed 完成數不變）。measurer 補一次確認即可（非重測全部）。
- `--import`/sanity/constitution 綠。

## merge（決策統一 win + 磁鐵一起）
- merge 閘：reviewer 對完整 diff R②（審設計 + gossip 接口乾淨否）+ gate#1 非搬餓 + 隊數不崩 + determinism + 融合閘/憲法。
- handback to:reviewer（R②）→ CLEAN → to:measurer（零漂移驗）→ 數字 to:systems → **systems merge**（決策統一 win + 完整 utility + 磁鐵一起入 main）。

卡點 → to:systems（別問 user）。
