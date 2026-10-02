# Attributions

Code and data Dawn builds on, with their licences. Add an entry before porting anything.

- WakeTF (https://github.com/acwo/waketfapp), MIT, copyright (c) 2026 acwo; the licence's notice is in `LICENSES/WakeTF.txt`. Ported from it, and adapted to 30-second epochs: the extended runtime session controller (`ExtendedRuntimeWakeSession`), the next-occurrence rule (`WakePlan`), the motion monitor's feature extraction and sampling (`MotionFeatures`, `DeviceMotionStream`), the heart-rate monitor (`HeartRateFeatures`, `PassiveHeartRateStream`), the wake scorer and its baseline (`ArousalScorer`, `ArousalBaseline`), the trigger reasons and outcome model (`WakeTrigger`, `WakeOutcome`), and its scorer and schedule tests (`ArousalScorerTests`, `WakePlanTests`).
- Alarm sounds (`Apps/Dawn/Resources/Sounds/dawn-chimes.caf`, `dawn-sunrise.caf`, `dawn-pulse.caf`), CC0 1.0. Synthesised for Dawn by `Scripts/make-alarm-sounds.swift`, with no recorded material, and dedicated to the public domain (https://creativecommons.org/publicdomain/zero/1.0/).
