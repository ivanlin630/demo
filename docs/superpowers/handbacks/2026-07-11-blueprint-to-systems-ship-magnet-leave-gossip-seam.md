---
from: blueprint
to: systems
status: consumed
topic: [裁定] consolidation磁鐵ship+留gossip接口;defer名聲傳播本體到資訊維度後續;a/b/c收掉(磁鐵讓consolidation活)
---

# 藍圖裁：ship 磁鐵 + 留 gossip 接口

用戶定（2026-07-11）：**現在不建 gossip，但留好接口**讓之後訊息系統補名聲傳播。

## 1. ship consolidation 磁鐵
- 磁鐵大窗確認活（18-seed 196 次完成 vs 前版 4-19、10 倍跳、跨 faction 自願歸附穩定重現、mega-blob 受控均 34.67 隊、三端/gate#1 綠）。
- **決策統一 win + 工作磁鐵一起 merge**。merge 閘照常：reviewer diff R② + gate#1 非搬餓 + 隊數不崩 + determinism + 融合閘/憲法。
- **a/b/c 收掉**：consolidation 非「世界抗拒」，是**磁鐵讓它活**（跨 faction 自願歸附）。現況「中性 rep 無差別投靠」接受為現階段行為（無名聲資訊時投誰都合理、mega-blob 受控）。

## 2. 留 gossip 接口（核心要求，別漏）
現況：protector_rep 只從直接事件長（aided/looted/diplomacy），organic 尺度 `rep.host_nonneutral=0`（曝光缺口）。之後靠訊息系統 gossip 傳播名聲補。**現在留接口，非建本體**：
- **protector_rep 更新做成單一可擴充入口**（如 `update_protector_rep(observer, target, delta, source)`）——直接事件走它、**未來 gossip 也走它**，不用回頭重構 rep 模型。
- **message_system 標擴充縫**（`exchange_intel_on_arrival`/`_exchange_intel` 附近）：註明「未來 gossip：相遇交換情報時，也交換對第三方的 protector_rep 意見 → 收方經此入口更新」。留 TODO/seam，不實作。
- **確保現設計不擋 gossip**：rep 是 per-observer 主觀（已是）、更新入口不假設 source 只能是直接事件。

## 3. defer gossip 本體
- 完整名聲傳播（gossip loop-1）歸**資訊維度後續**（路線圖資訊 ███ 最弱那維、Phase D 帶）。
- 它讓磁鐵從「無差別投靠」→「擇良木而棲（仁君聚人望/暴君遭棄）」= 名聲靈魂。屆時接上留好的入口即可。
- 前提複用既有 message/belief 管道（相遇 hook + 信任 gate + distortion/decay 都在）→ 屆時是「擴 message 帶名聲內容」，中工非大 arc。

## 流程
- implementer 收尾磁鐵 slice（含 gossip 入口 + message seam 註記）→ R②（審設計 + 接口乾淨否）→ measurer 最終確認（磁鐵數字已有，補接口不改行為=零漂移驗）→ merge。
- gossip 本體記 backlog（你 owner，progress/known_issues 一筆：資訊維度、接口已留）。

ship 磁鐵、留縫、defer 傳播。出收尾 spec。
