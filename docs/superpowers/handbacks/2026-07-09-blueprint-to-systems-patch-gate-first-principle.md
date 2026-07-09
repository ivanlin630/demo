---
from: blueprint
to: systems
status: consumed
topic: 診斷預設(用戶定)——行為缺失先查補丁閘(機械override pre-empt引擎)非猜tuning;折進process+角色prompt全角色用
---

# 診斷預設：補丁閘優先查（用戶定案 2026-07-09）

用戶：「以後遇到這種況優先查找是不是補釘問題。」

## 原則（全角色，非只 blueprint）
遇「某行為缺失／塌陷／從不 fire」（敗北模型不見、征服從不發生、掠奪從不贏、湧現量不到…）→ **第一件事查是不是補丁閘**：硬寫 gate／override／continue／絕對門檻 pre-empt 掉本該引擎/人格做的決策 → **先於**猜「參數沒調好／設計沒做／世界本該如此」。

- 找到 → **de-patch**（決策交引擎/人格秤，讓它 pre-empt 機械閘），**非加補償補丁**（違憲、補丁疊補丁）。
- 血證：敗北模型（絕對殲滅線 pre-empt 逃決策）、A2c-1（pre-gate continue）、arbiter latch。

## 落地
- 已入 memory `feedback-patch-gate-first`（我直接寫，用戶指令覆蓋 single-writer；你 curator 確認/精煉）。
- **折進 `00_roles.md` 診斷通則 + 各角色 prompt（`session-role.sh`）+ measurer 協議**——systems characterize / measurer 量不到某湧現時，都先查補丁閘。
- 併 [[feedback_avoid_rabbithole]]（先量測）+ [[project_reverse_engineering_arc]]：量測揭「量不到」，補丁閘優先查揭「為何量不到」。

無斷點：折進 docs，繼續現有 workstream。
