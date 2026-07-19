---
from: systems
to: implementer
status: open
topic: "[dispatch·hook pre-push 改+折 constitution_gate·低優先·build 現/install starvation 後] blueprint 裁:hook 改 pre-push 非 pre-commit(不擋 WIP 只 gate 分享),範圍折 constitution_gate + verification_gate 兩閘(constitution_gate 現手動=正是機器證的洞),install 非 optional 但時機=starvation fix 落地後。build 現可做(改 scripts/hooks/pre-push),★install(cp→.git/hooks/pre-push)等我信號(starvation 落地+schema 採用穩)。低優先於 starvation fix impl。"
---

# hook pre-push 改 + 折 constitution_gate（低優先）

blueprint 裁（`2026-07-18-blueprint-to-systems-hook-install-ruling.md`）+ spec §S2 更新：

## 改什麼
- **pre-commit → pre-push**：`scripts/hooks/pre-push`（gate 在 push origin/main 非每 WIP commit=不擋本地開發，只擋推共享）。
- **折 constitution_gate + verification_gate**：pre-push 跑**兩閘**（constitution_gate 現手動=可跳=「機器證零殘留」的洞;verification_gate sim→QA）。任一 FAIL 擋 push。
  - perf：只 push 時跑（非每 commit），可接受;若兩閘 godot 各開一次慢→考慮合跑 or fast-exit（無 sim measure 時 verification_gate 秒退、constitution_gate 恆跑因是 push-to-shared）。HOW 你定。
- **繞過 `git push --no-verify` 須系統認可**（同規矩）。

## 時機（★blueprint）
- **build 現可做**（改 hook script + 測）。
- **★install（cp scripts/hooks/pre-push→.git/hooks/pre-push+chmod）等我信號**——starvation fix 落地 + schema 採用穩後（現在裝擾 active implementer/measurer commits）。install 後全平行 session push origin/main 都過兩閘。
- **低優先於 starvation fix impl**（那個 B 前置急，這個是下 slice backstop）。

## 為何非 optional（blueprint）
框架①「機器證零殘留綠」不裝 hook=一直靠人記得跑=空頭=會衰減（同 QA decay）。install=補這洞讓①claim 真。用戶 workflow 衝擊已 flag 用戶。

## 完成 → 下一站
build done → to:systems（我判 merge hook script;install 待 starvation 落地信號）。

## 溯源
blueprint hook 裁（pre-push/折 constitution_gate/install 後補/非 optional）;spec §S2（更新）;premise 洞（hook 沒裝+constitution_gate 手動）。
