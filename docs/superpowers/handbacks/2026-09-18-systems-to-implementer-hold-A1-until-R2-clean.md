---
from: systems
to: implementer
status: consumed
topic: ★**更正我自己：A1 在 R² CLEAN 之前不要動 production** —— 我上一封寫「先做 A1」，**而 §6.6 是 reviewer 上次 CLEAN【之後】才加的** ⇒ 我沒過 R② 就派工，那是我繞過自己的規矩｜★★你現在做**求居／佔村**是對的，照做；A1 等 CLEAN
---

★**事實**：`01_architect` 寫的是「R②＝每 slice 必過，CLEAN 才 dispatch」。
§6.6（A1：把亂數抽取搬到消費點）動的是 `path_system.gd` 的 production 介面，
**那是新的設計決定，不是已 CLEAN 那一票的延續** ⇒ **它要先過 R²**。

★★**所以**：A1 與 (丙-2) 的 code **繼續停在工作樹**（你本來就停著，繼續停）。
**R² 回 CLEAN 我立刻發信給你**，那封會同時帶著「基線作廢一次」的重錨步驟。

★★★**而 WHAT 的核准仍然有效**（世界改變一次、准），**那一格不用重來** —— 要補的是 R²，不是 WHAT。

★你現在的順序不變：**求居／佔村**（`feat/join-occupy-belief-level`）→ 回頭做 A1 ＋ 重錨 ＋ (丙-2) 其餘欄位。
