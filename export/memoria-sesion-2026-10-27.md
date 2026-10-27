# Memoria de la sesión — Misión Dashboard

- **Fecha:** 27-10-2026
- **Rol de quien dirige:** Product Owner, con Claude Code (Opus 5.5) como asistente.
- **Metodología:** Spec-Driven Development (SDD): Constitución → Especificar → Planificar → Tareas → Implementar.
- **Transcripción completa:** `transcripcion-sesion-2026-10-27.zip`. No está en el repositorio público, porque incluye el correo de la cuenta y las instrucciones de sistema del asistente; se entrega por separado al evaluador. Es el archivo `transcript.jsonl`, con todos los mensajes, llamadas a herramientas y resultados.

Este documento es un resumen legible para el evaluador. Ante cualquier duda, la fuente es la transcripción.

---

## 1. Artefactos producidos

| Archivo | Qué es | Estado |
|---|---|---|
| `inputs/` | Módulo 3 del curso SDD (4 fotos) y el feedback de una profesora (1 foto) | Material de entrada |
| `data/Base_Evaluaciones_1MA_Quimica_2026.xlsx` | Planilla de ejemplo con datos ficticios: 35 estudiantes, 9 evaluaciones y 525 resultados | Material de entrada |
| `data/OA_Quimica_1M_MINEDUC.csv` | OA oficiales de Química 1° medio (CN1M OA 17–20 y OAH a–m), tomados de curriculumnacional.cl | Generado en la sesión |
| `contexto-proyecto.md` | Contexto de negocio, modelo de datos, brechas, decisiones y preguntas abiertas | Vigente |
| `.specify/constitution.md` | Constitución del proyecto (reglas inmutables, límites para la IA) | v5.0.3 |
| `specs/001-dashboard-docente/spec.md` | Requerimientos e historias de usuario | v1.1, aprobada por el PO (con un ajuste en HU-04) |
| `specs/001-dashboard-docente/plan.md` | Plan técnico del mock up | v1.0, aprobado por el PO |
| `specs/001-dashboard-docente/tasks.md` | 28 tareas del mock up, con dependencias y criterios de término | v1.0, terminado (28 de 28 tareas) |
| `mockup/scripts/extract-data.ps1` | Extrae la planilla, convierte a OA oficiales y simula preguntas | Fase 0 |
| `data/mockup-data_generado.json` | Datos mínimos del mock up (sin género ni asistencia) | Generado |
| `mockup/dashboard-docente.html` | Mock up autocontenido: 6 pestañas, ficha del estudiante, maquetas de HU-21 y HU-22 y modo `?verificar` (76 casos) | Terminado |
| `docs/capturas/` | Capturas de las 6 pestañas a 1366 px y de la ficha del estudiante | Generado |

## 2. Cronología de la sesión

| # | Paso | Resultado |
|---|---|---|
| 1 | Crear la estructura del proyecto | Carpeta `mision-dashboard/` con su subcarpeta `inputs/` |
| 2 | Revisar el material del curso SDD | Resumen de la Constitución: componentes, límites en 3 niveles, workflow y rol humano |
| 3 | El PO entrega el contexto de negocio | Primer `contexto-proyecto.md` |
| 4 | Revisar el feedback de la profesora y la planilla | Modelo de datos documentado; necesidades P1–P4 contrastadas con la data disponible |
| 5 | El PO aclara: datos de la plataforma, preguntas por ítem, OA del año y PIE sin asistencia | Búsqueda de los OA oficiales en MINEDUC y propuesta de semáforo |
| 6 | El PO aprueba el semáforo | Constitución v1.0.0 |
| 7 | El PO define los cierres semestrales (30-06 y 03-12) y la cobertura solo de OA de conocimiento | Constitución v1.1.0 |
| 8 | El PO define que se muestran los promedios semestral y anual, y que el semáforo usa el semestral | Constitución v2.0.0 |
| 9 | El PO corrige: el promedio anual es el promedio simple de los dos semestres | Constitución v3.0.0 y cifras recalculadas |
| 10 | El PO pide traducir todo a requerimientos | `spec.md`: 9 épicas, 22 historias, 22 RF, 11 RNF, 8 reglas de negocio, 6 supuestos |
| 11 | El PO edita `spec.md` y pide revisión y export | Este documento (ver la sección 5) |
| 12 | El PO confirma que **todas las evaluaciones llevan nota** | Constitución v4.0.0, spec v0.2, notas recalculadas para las 9 evaluaciones y 2 escenarios de ponderación |
| 13 | El PO define la ponderación: la diagnóstica no pesa (línea base); cada formativa pesa 1; el promedio de sumativas pesa 1 | Constitución v5.0.0, spec v0.3 y cifras finales recalculadas |
| 14 | El PO acota la EP9 a la planificación semanal de evaluaciones | Spec v0.4: HU-22 reescrita; reuniones y entrevistas quedan fuera |
| 15 | El PO mantiene la HU-22 en prioridad W | Queda como maqueta visual, sin datos reales |
| 16 | El PO valida los supuestos S1–S6 | Spec v1.0, aprobada |
| 17 | El PO pide el plan técnico del mock up | `plan.md` v0.1: arquitectura, modelo de datos, reglas en JS, pantallas, verificación y 7 decisiones abiertas (D1–D7) |
| 18 | El PO aprueba D1–D7 y pide las tareas | Plan v1.0, Constitución v5.0.1 (aclaraciones del semáforo y carpeta `mockup/scripts/`) y `tasks.md` con 28 tareas en 4 fases |
| 19 | El PO pide implementar la fase 0 (T001–T004) | Script de extracción, JSON generado (490 resultados, 100 preguntas simuladas coherentes con los puntajes) y esqueleto HTML verificado en el navegador |
| 20 | El PO pide la fase 1 (T005–T014) | Reglas de dominio en JavaScript con aritmética exacta en décimas y `?verificar` con 67 casos, todos correctos. Conteo de 🟡 calculado (2° semestre: 9 🔴, 5 🟡, 21 🟢) y pendiente de validación |
| 21 | El PO valida los conteos del semáforo y pide la fase 2 (T015–T025) | Conteos fijados como control (Constitución v5.0.2). Vistas completas: Resumen, Estudiantes, Mapa de calor, Sumativas, Avance curricular, Mi semana y ficha. 76 de 76 casos correctos, probado a 1366 y 768 px |
| 22 | El PO pide mostrar "Requieren atención" como tabla tipo libro de clases | Tabla con ID, nombre, apellido, estado, línea base, notas por evaluación, promedios y motivos; spec v1.1 (HU-04) |
| 23 | El PO cambia el rótulo "Línea base" por "Diagnóstico" en todo el mock up | Mock up, spec (HU-04, HU-05, HU-20 y glosario), plan y Constitución v5.0.3 actualizados |
| 24 | El PO pide la fase 3 (T026–T028) | Contraste AA medido en ambos modos (se corrigieron dos colores de barra y el borde de controles), prueba de teclado, lista manual completa, capturas en `docs/capturas/` y documentación cerrada. 76 de 76 casos correctos |

## 3. Decisiones del Product Owner

| Tema | Decisión |
|---|---|
| Usuario de la etapa 1 | Docente de asignatura. El equipo directivo queda para la etapa 2. Cliente: el establecimiento. |
| Origen de los datos | La plataforma. Sin carga manual; el Excel solo simula esa fuente en el mock up. |
| Datos disponibles | Resultados por pregunta, OA del año de todas las asignaturas y marca PIE. **Sin asistencia.** |
| Escala de notas | De 1,0 a 7,0, con aprobación en 4,0 y 60% de exigencia. **Todas las evaluaciones llevan nota** (diagnósticas, formativas y sumativas). |
| Semáforo | 🔴 promedio del semestre en curso menor a 4,0. 🟡 si hay alertas tempranas: última sumativa menor a 4,0; 2 o más Insuficiente en 2 meses; caída de 20 puntos o más; 2 o más ausencias. 🟢 el resto. |
| PIE | Marca de contexto; nunca es un factor de riesgo ni un filtro. |
| Fechas de cierre | 30-06 (1° semestre) y 03-12 (2° semestre). |
| Cobertura curricular | Solo OA de conocimiento, sin habilidades (OAH). |
| Promedios | Semestral = promedio simple de [cada formativa, promedio de sumativas]; la diagnóstica no pesa (línea base). Anual = (semestre 1 + semestre 2) / 2. |
| Tecnología | Mock up en HTML. Desarrollo con Python en el backend y Node en el frontend. Repositorio en el git de Diana. |
| Datos sensibles | El RUT siempre protegido; en el mock up solo se usan datos ficticios. |

## 4. Hallazgos clave en la data de ejemplo (al 27-10-2026)

- **Cobertura:** el **CN1M OA 19** (compuestos binarios y ternarios, nomenclatura) **nunca se ha evaluado**, y quedan **37 días** para el cierre del 2° semestre.
- **Notas por evaluación:** la diagnóstica D1 tiene el promedio más bajo (3,9, con 19 de 35 bajo 4,0) y la formativa F5 el más alto (5,5).
- **Promedios del curso:** 4,4 en el 1° semestre, 4,7 en el 2° y 4,6 anual.
- **Riesgo:**
  - **9 estudiantes en 🔴** según el 2° semestre.
  - **8 bajo 4,0** según el anual.
- **Casos ilustrativos:**
  - **E30:** línea base 4,9 y anual 4,3, pero 3,7 en el semestre, así que está en 🔴. El promedio anual escondería su situación.
  - **E05:** línea base 2,9; va mejorando hasta 4,3 en el semestre.
- **Numeración de OA:** la planilla usa una numeración ilustrativa (OA1–OA5), que quedó mapeada a los códigos oficiales en `contexto-proyecto.md` 4.2.

## 5. Revisión de la versión de `spec.md` editada por el PO

Cambios del PO detectados:
- **Asistencia:** se agrega "la plataforma no la tiene **ni la tendrá**".
- **Carga manual:** se reescribe como exclusión explícita.
- **EP9:** pasa a llamarse "Planificación semanal **de evaluaciones**".
- **Glosario:** se modifica la definición de los tipos de evaluación.

**Observaciones:**

1. **Glosario: "Ambas llevan nota"** contradecía la RN-01 y la Constitución. ✅ **Resuelta:** el PO confirmó que todas las evaluaciones llevan nota. Se actualizaron la Constitución (v4.0.0), la spec (v0.2) y el contexto. La ponderación (S7) quedó definida en la Constitución v5.0.0.
2. **EP9:** el nombre nuevo no coincidía con el título de su sección ni con la HU-22. ✅ **Resuelta:** el PO la acotó a la planificación semanal de evaluaciones. Se reescribieron el título y la HU-22, y reuniones y entrevistas quedan fuera del alcance.
3. **Supuestos S1–S6:** ✅ **Resuelta:** el PO los validó todos y la spec quedó aprobada (v1.0).

## 6. Próximos pasos

1. Validación del mock up con docentes.
2. Plan del MVP (Python + Node), en una spec y un plan propios.

## 7. Nota para el evaluador sobre la transcripción

- **Exportada:** 27-10-2026 a las 15:20, después del paso 24. Cubre toda la sesión hasta el cierre del mock up. Lo que ocurra después de esa hora no queda en el zip.
- **Formato:** `transcript.jsonl`, un mensaje por línea en JSON (13 MB). El zip también trae una copia con el identificador de la sesión, las transcripciones de subagentes y los metadatos.
- **Revisión antes de incluirla:** se buscaron claves de API, tokens, claves privadas, contraseñas y RUT, sin coincidencias.
- **Contenido:**
  - Las instrucciones de sistema del asistente.
  - El correo electrónico de la cuenta de usuario, como contexto de identificación.
  - Los nombres de estudiantes de la planilla, que son **ficticios**.
- **No** contiene datos reales de estudiantes, credenciales ni claves.
