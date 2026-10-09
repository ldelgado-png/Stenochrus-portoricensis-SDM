# Continuación de sensibilidad de muestreo — Stenochrus portoricensis

Estado al 8 de octubre de 2026. Este paquete se preparó a partir del RAR compartido por el investigador y de los resultados de consola del diagnóstico 25. **El diagnóstico 25 ya terminó en RStudio**, pero el RAR fue empaquetado antes del cierre y contiene ocho de los doce objetos RDS por pliegues; faltan los cuatro `Arachnida_floor20_fold*.rds`, así como las tres tablas finales (`validation_by_fold.csv`, `validation_summary.csv`, `paired_auc_differences.csv`) y `sessionInfo.txt`.

## Orden recomendado

1. **`26_complete_diagnostic25_archive.R`**: ejecuta/verifica únicamente los modelos de cada pliegue faltantes, reutiliza los RDS ya existentes y reconstruye las tablas exactas; compara automáticamente los AUC con 0,7417520 / 0,7077332 / 0,7116284. Al finalizar, comprime y comparte únicamente `results/sampling_bias/common_background_spatial_validation/` para actualizar el archivo del repositorio.
2. **`27_multiseed_background_validation.R`**: amplía la comparación a cinco semillas (123–127) y los pisos 0,10 y 0,20; se ajustan los modelos LQHP/RM1 con cuatro pliegues para **cada nueva realización del fondo**, conservando el mismo fondo de evaluación. El área donde se eligen nuevos fondos excluye las 9.987 celdas de evaluación. Esta exclusión significa que incluso la semilla 125 produce un diseño nuevo que no debe confundirse con el diagnóstico 21.
3. **`28_nonfocal_target_group_audit.R`**: consulta GBIF por registros georreferenciados de Schizomida, años 1980–2025, elimina coincidencias identificables de *S. portoricensis*, filtra por M200 y calcula el número de celdas distintas no focales. Sólo es una prueba de viabilidad: no declare TGB 9.987 comparable si no hay 9.987 celdas independientes y una revisión taxonómica.
4. **`29_temporal_1980_2025_sensitivity.R`**: coteja las celdas de la tabla original de 172 registros con las 171 presencias efectivas y retiene las 136 del periodo de esfuerzo; ajusta las 40 configuraciones para cada uno de los tres fondos. Los AICc de n=136 no se comparan en valor absoluto con los de n=171, ni entre fondos diferentes.
5. **`30_future_weighted_projections.R`**: crea el manifiesto de 16 entradas (cuatro GCM, dos SSP, dos periodos), que debe asociarse a las 16 pilas climáticas CMIP6 del proyecto. Una vez que los 16 archivos estén identificados, proyecta LQHP/RM1 bajo fondo uniforme y los dos fondos ponderados, guarda rásteres futuros, áreas y el consenso 2/4 por escenario. No calcula estas proyecciones hasta que los datos de futuro estén presentes.

## Criterios de cierre

- `26`: doce archivos `models/*.rds` + tres tablas de validación + `sessionInfo.txt` presentes, con valores de AUC verificados.
- `27`: tabla por semilla y pliegue, resumen entre las cinco semillas y diferencias pareadas contra el uniforme.
- `28`: resultado de viabilidad de TGB con procedencia GBIF (taxonKey, registros, fechas, celdas); documentar como inviable si la cantidad es insuficiente.
- `29`: subconjunto de 136 presencias y ajuste de 40 configuraciones por escenario, con archivos propios y sin sustituir el análisis original.
- `30`: 48 GeoTIFF futuros, consensos 2/4 de los tres modelos en los cuatro combinados SSP-periodo, y tablas de cambio en km².

**Limitación de reproducibilidad:** estos scripts se prepararon y revisaron estáticamente; el entorno de ejecución actual no cuenta con R ni con los insumos completos del proyecto en `data/` para ejecutar los ajustes. Ninguno de los diagnósticos 27–30 debe marcarse como ejecutado o completado sin sus resultados en RStudio.
