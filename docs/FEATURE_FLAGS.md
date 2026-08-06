# Winger Backend V2 – Feature Flags Specification

Runtime feature toggles and percentage rollouts.

---

## 1. Feature Flag Evaluation
`ops.fn_evaluate_feature_flag(flag_key, workspace_id)` checks global enablement and workspace-specific overrides.
