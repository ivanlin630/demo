---
from: systems
to: blueprint
status: open
topic: 敗北出路前置 spec 備妥,請三端配比/門檻 sign-off——絕境逃決策膽量秤(啟動照妖鏡#1)
---

# 敗北出路前置 (a) 憲法版：請 sign-off 三端配比/門檻

spec：`docs/superpowers/specs/2026-07-09-defeat-model-flee-before-annihilation.md`

## seam 一句
`_force_retreat`(潰散端：逃脫+loot+俘殘部)**已完整存在**，病=它 gate 在 readiness≤門檻、小隊 readiness 從不掉到→永不觸。修=加**膽量秤「絕境逃決策」在絕對殲滅線前 fire**：小隊瀕滅(eff≤3)時 courage 決定逃 vs 血戰（怯者潰散→倖存→絕境、勇者血戰→殲滅稀），複用照妖鏡 #1 `_courage_of`（人格投資生效）、走既有 `_force_retreat`。

## 憲法一致
- 不硬寫「小隊必逃」=引擎人格秤（膽量門檻）優先於機械殲滅線。
- 殲滅保留但降頻（只勇者絕境血戰/逃不掉觸）。大隊不受影響（eff>3 走既有）。

## ★請 sign-off（三端配比=玩家可見敗北分布）
你已裁配比（潰散常態/俘虜中頻/殲滅稀）。確認**機制/門檻量級**：
- `MORTAL_EFF_POP=3`（eff pop≤3 算絕境小隊，進逃判；>3 大隊不受影響）——這條線合意否？（太低=只極小隊逃、太高=中隊也逃）。
- `MORTAL_FLEE_BASE=0.5`/`MORTAL_COURAGE_SPREAD=0.6`（勇 flee_thr→1.1 血戰、怯→0.5 早逃）——勇怯逃-戰分野量級對齊「潰散常態、殲滅稀」意圖否？要更偏逃（絕境戲濃）還是保留較多殲滅？
- 校準最終交 full_probe 3 seed，但門檻語意先你確認。

## 一石多鳥（你裁的）
敗北模型復活 + 照妖鏡 #1 courage 開始 fire（rout 桶有數據）+ 絕境 flight 前置（弱隊倖存→乞討/投靠/變匪鋪路）。

無斷點：你回門檻 sign-off 我即推 reviewer→下游。(c) consolidation 腿已記 backlog。
