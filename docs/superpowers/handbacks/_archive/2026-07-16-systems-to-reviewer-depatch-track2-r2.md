---
from: systems
to: reviewer
status: consumed
topic: "[R²·設計審·de-patch軌2值閘] 零殘留stream①軌2值閘人格化spec。7閘de-patch:_threat_recent→intent/好戰軍備/diplomatic RNG決策(背叛/發起)→慎重/rep util(保outcome RNG)/_check_discipline RNG→人格(查決策vs outcome)/_maybe_request_join RNG→求生util/tribute FLEE override→膽識絕望秤/_calc_diplomacy_score硬門檻→util軟化/calc_attack_score查孤兒。審:真de-patch非搬家+人格映射sound+★決策翻轉RNG vs世界outcome RNG分對(invariants判準)+非回歸(行為變非byte-identical)。CLEAN才dispatch"
---

# R² 設計審：de-patch 軌2 值閘人格化

> **[worker 守則] 卡住/疑義 → handback `to:systems`，禁 `AskUserQuestion`。**

零殘留 stream ① 軌2（值閘人格化）。blueprint 批 triage+escalation 全 de-patch。**R² 設計審 CLEAN 才 dispatch implementer。**

## spec
`docs/superpowers/specs/2026-07-16-depatch-track2-value-gates.md`

## 審什麼
1. **真 de-patch 非搬家**：7 閘的硬門檻/RNG 決策→人格 util，真把決策交人格秤（非換地方硬寫）？
2. **人格映射 sound**：_threat_recent→intent/好戰、diplomacy→慎重/rep、FLEE→膽識/絕望——映射合理、穿人格/情境（非新全域常數）？
3. **★決策 RNG vs 世界 outcome RNG 分對**（invariants RNG 判準）：spec 保留「訊息到/外交成敗 outcome RNG」、只拆「背叛/發起/紀律 決策翻轉骰」——`_check_discipline` 是決策還 outcome？分界對？
4. **非回歸**（★行為變非 byte-identical）：世界不確定 RNG 保留、感知鐵律、守恆、閘 removed。
5. **calc_attack_score 孤兒查**：真孤兒則刪、仍 live 則人格化——確認。

## 流向
CLEAN → to:systems → dispatch implementer（per-gate git commit + 標 legit baseline）→ measurer 乾淨全量（行為分化+無回歸+閘 removed）→ 批。seam#1（軌1 控制流收斂）另大 slice。
