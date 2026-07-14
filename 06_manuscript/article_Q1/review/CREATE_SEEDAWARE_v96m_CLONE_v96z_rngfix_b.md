# CREATE_SEEDAWARE_v96m_CLONE_v96z_rngfix_b

## Diagnosis

`SEEDAWARE_V96M_CLONE_CREATION_PASS`

## Decision

`CLONE_READY_FOR_PREFLIGHT_AUDIT`

## Next step

`9.6z-rngfix-c — PREFLIGHT-SEEDAWARE-CLONE-NO-GA-001`

## Source

`C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_triobjective_formal_ga_v96m.m`

## Clone

`C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m`

## Old signature

```matlab
function formal = run_guarded_triobjective_formal_ga_v96m(confirm_execute)
```

## New signature

```matlab
function formal = run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix(confirm_execute, rngSeed)
```

## RNG replacement

Old:

```matlab
rng(614960,'twister');
```

New:

```matlab
if rngSeedWasProvided_v96z
    rng(rngSeed,'twister');
    rngControl_v96z = "EXTERNAL_SEED_APPLIED";
else
    rng(614960,'twister');
    rngControl_v96z = "LEGACY_INTERNAL_SEED_614960_APPLIED";
end
rngStateAfterSeed_v96z = rng;
```

## Checks

| id | check | pass | evidence |
|---|---|---:|---|
| `RNG_B01` | Source v96m exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_triobjective_formal_ga_v96m.m` |
| `RNG_B02` | Clone created | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m` |
| `RNG_B03` | Function renamed | 1 | `seed-aware signature found.` |
| `RNG_B04` | External seed branch inserted | 1 | `external seed branch found.` |
| `RNG_B05` | Legacy branch preserved | 1 | `legacy branch found.` |
| `RNG_B06` | Original fixed rng not unconditional | 1 | `unconditional fixed rng not found.` |
| `RNG_B07` | gamultiobj still present | 1 | `gamultiobj call preserved.` |
| `RNG_B08` | Tsolutions still present | 1 | `Tsolutions preserved.` |
| `RNG_B09` | RNG metadata inserted | 1 | `rng metadata inserted.` |
| `RNG_B10` | No GA executed | 1 | `No gamultiobj call; file generation only.` |
| `RNG_B11` | No model executed | 1 | `No objective/model call.` |
| `RNG_B12` | Original v96m not modified | 1 | `Only clone created.` |
