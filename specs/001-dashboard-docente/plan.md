# Plan 001 — Mock up del dashboard docente

| | |
|---|---|
| **Estado** | ✅ Aprobado por el Product Owner (27-10-2026) |
| **Versión** | 1.0 (decisiones D1–D7 aprobadas) |
| **Fecha** | 2026-10-27 |
| **Rige** | [Constitución v5.0.1](../../.specify/constitution.md) |
| **Implementa** | [Spec 001 v1.0 (aprobada)](spec.md) |
| **Alcance** | Solo la entrega **Mock up**. El MVP (Python + Node) tendrá su propio plan. |

---

## 1. Objetivo del mock up

Construir una maqueta navegable con datos ficticios que una docente pueda abrir con doble clic. Debe servir para validar con docentes:

- Si las vistas responden a P1–P4.
- Si el semáforo y sus motivos se entienden.
- Si se llega a cualquier dato de un estudiante en 3 clics o menos.

El mock up **no** es el MVP. Pero sus reglas de dominio se escriben igual que en producción (una sola fuente, con casos de prueba), para que el MVP las porte a Python sin reinterpretarlas.

---

## 2. Revisión contra la Constitución (gate)

| Regla | Cómo la cumple este plan |
|---|---|
| 2 · Stack | Un archivo HTML con CSS y JavaScript vanilla (ES2020). Gráficos en SVG/CSS propio. Sin librerías ni CDN. |
| 3 · Estructura | El mock up va en `mockup/`. El JSON derivado de la planilla lleva el sufijo `_generado`, y los originales de `data/` no se tocan. |
| 3 · Reglas en un solo bloque | Todas las fórmulas viven en el bloque `// === Reglas de dominio ===` del HTML. La interfaz solo llama a esas funciones. |
| 5 · Pruebas | Hay un modo de verificación automática (`?verificar`) con los casos obligatorios y las cifras de control, además de la revisión manual (sección 10). |
| 6 · Dominio | Las notas, promedios, semáforo y cobertura siguen la sección 6 al pie de la letra. Los umbrales y las fechas son parámetros con nombre (sección 6.3 de este plan). |
| 7 · Privacidad | Solo datos ficticios. No se cargan RUT, género ni asistencia. PIE solo como etiqueta. Sin llamadas de red. |
| 7.4 · Accesibilidad | Cada color va con ícono y texto, y el contraste es AA. |
| 9 · Ask First | Lo que requería decisión del PO está en la sección 11, ya aprobado. |

**Resultado:** sin conflictos con la Constitución. Las 7 decisiones de la sección 11 fueron aprobadas por el PO el 27-10-2026.

---

## 3. Alcance del mock up

| Tipo | Historias |
|---|---|
| **Funcionales, con datos reales de la planilla** | HU-02, HU-04 a HU-10, HU-12 a HU-20 |
| **Solo maqueta visual (contenido escrito a mano)** | HU-21 (ideas de actividades, "Vista previa") y HU-22 ("Mi semana", "Próximamente") |
| **Fuera del mock up (solo MVP)** | HU-01 (control de acceso), HU-03 (actualización automática) y HU-11 (filtro del mapa por tipo de evaluación) |

**Simplificaciones del mock up:**
- En lugar de la fecha de actualización (HU-03), el encabezado muestra **"Datos de ejemplo al 27-10-2026"**.
- El selector de curso muestra un solo curso, 1° Medio A · Química (supuesto S5).

---

## 4. Arquitectura

```
data/Base_Evaluaciones_1MA_Quimica_2026.xlsx   (original, solo lectura)
data/OA_Quimica_1M_MINEDUC.csv                 (OA oficiales)
        │
        ▼  mockup/scripts/extract-data.ps1   (PowerShell; se corre una vez)
        │
data/mockup-data_generado.json                 (datos mínimos + preguntas simuladas)
        │
        ▼  el mismo script lo inserta entre los marcadores del HTML
        │
mockup/dashboard-docente.html                  (autocontenido; se abre con doble clic)
```

- **Por qué PowerShell:** en el equipo de trabajo no hay Python ni Node instalados, y la planilla ya se leyó así (descomprimiendo el `.xlsx` y leyendo su XML). El script no forma parte del producto: solo prepara los datos ficticios.
- **Sin build:** el HTML se edita a mano. El script solo reemplaza el bloque de datos: un `<script type="application/json">` entre los comentarios `<!-- DATA:BEGIN -->` y `<!-- DATA:END -->`. Van como comentarios HTML porque un comentario dentro del JSON impediría leerlo (ajuste hecho en T004).

**Bloques internos del HTML, en este orden:**

| Bloque | Contenido | Puede leer el DOM |
|---|---|---|
| `// === Configuración ===` | Umbrales, fechas de cierre, fecha de referencia y ponderaciones | No |
| `// === Reglas de dominio ===` | Funciones puras de la sección 6 de la Constitución | No |
| `// === Datos ===` | Lectura del JSON embebido e índices (por estudiante, por evaluación, por OA) | No |
| `// === Formato es-CL ===` | Coma decimal, `dd-mm-aaaa`, etiquetas de nivel y semáforo | No |
| `// === Vistas ===` | Una función de render por pantalla (sección 8) | Sí |
| `// === Verificación ===` | Casos de prueba y cifras de control; se activan con `?verificar` | No (escribe en la consola y en un panel) |

---

## 5. Modelo de datos del mock up

El JSON imita lo que entregará la plataforma: evaluaciones, resultados por OA y respuestas por pregunta. Por **minimización**, solo se extrae lo que alguna historia usa.

| Entidad | Campos | Origen |
|---|---|---|
| `students` | `id` (E01…), `name`, `pie` (bool) | Hoja Estudiantes. **No** se extraen género ni asistencia. |
| `objectives` | `code` (`CN1M OA 17`…), `kind` (`knowledge` / `skill`), `text` | CSV MINEDUC. Incluye CN1M OA 19, aunque no tenga evaluaciones. |
| `evaluations` | `id`, `type` (`diagnostic` / `formative` / `summative`), `name`, `date`, `weight` (solo sumativas), `objectives` con su puntaje máximo | Hoja Evaluaciones |
| `results` | `studentId`, `evaluationId`, `objective`, `score`, `maxScore`, `absent` | Hoja Resultados |
| `questions` | `evaluationId`, `number`, `objective`, `points` | Simuladas (sección 7) |
| `answers` | `studentId`, `evaluationId`, `correct` (cadena de 0 y 1, una posición por pregunta) | Simuladas (sección 7) |

**Lo que no se extrae:**
- La hoja `Notas`. Sus promedios no son fuente de verdad (Constitución 6.1).
- Las columnas de % y nivel de la hoja `Resultados`. Se recalculan.

**Conversión de OA de la planilla a códigos oficiales** (contexto 4.2):

| Planilla | Oficial | Tipo | Efecto |
|---|---|---|---|
| OA1 | CN1M OA 17 | Conocimiento | — |
| OA2 | CN1M OA 18 | Conocimiento | — |
| OA3, OA4 | CN1M OA 20 | Conocimiento | Sus puntajes **se suman** (obtenido y máximo) cuando una misma evaluación mide ambos. |
| OA5 | CN1M OAH d, f | Habilidad | Cuenta para la nota de la evaluación. **No** entra en la cobertura ni en el mapa de calor (Constitución 6.4). |
| — | CN1M OA 19 | Conocimiento | Sin resultados: aparece "Sin evaluar". |

**Fecha de referencia:** el mock up fija "hoy" en **27-10-2026** (parámetro `REFERENCE_DATE`), para que las cifras coincidan siempre con las de control de la sección 10.

---

## 6. Reglas de dominio en JavaScript

### 6.1 Aritmética exacta

Los puntajes de la planilla son enteros. Para que el redondeo "0,05 sube" sea exacto y no dependa de errores de punto flotante (por ejemplo, 3,95 → 4,0), **las notas se manejan como enteros en décimas** (`39` = 3,9) y solo se convierten a texto al mostrarlas.

- **Redondeo de un promedio:** para `round(sum / n)` con 0,5 hacia arriba, se usa `Math.floor((2 * sum + n) / (2 * n))`. Es entero y exacto para valores positivos.
- **Puntaje a nota, en décimas,** con `p = score / maxScore`:
  - Si `p < 0,6`: `10 + 50 · p`. Ejemplos: 0% → 10 y 30% → 25.
  - Si no: `75 · p − 5`. Ejemplos: 60% → 40, 80% → 55 y 100% → 70.
  - Se calcula como fracción entera (`score`, `maxScore`) y se redondea con la regla anterior.

### 6.2 Funciones

| Función | Regla de la Constitución | Devuelve |
|---|---|---|
| `scoreToGrade(score, max)` | 6.1 | Nota en décimas |
| `achievementLevel(score, max)` | 6.2 | `insufficient` / `elemental` / `adequate` |
| `semesterOf(date)` | 6.4 | `1` o `2` |
| `evaluationGrade(studentId, evalId)` | 6.1 | Nota en décimas, o `null` si está Ausente |
| `summativeAverage(studentId, semester)` | 6.1 | Promedio de sumativas con sus ponderaciones reescaladas, o `null` |
| `semesterAverage(studentId, semester)` | 6.1 | Promedio simple de [formativas, promedio de sumativas], o `null` ("Sin notas") |
| `baseline(studentId)` | 6.1 | Nota de la diagnóstica ("Línea base"), o `null` |
| `annualAverage(studentId)` | 6.1 | (S1 + S2) / 2 más una marca `partial`; si falta un semestre, el que tenga nota |
| `riskStatus(studentId, semester, refDate)` | 6.3 | `{ status: red/yellow/green, reasons: [texto…] }` |
| `objectiveCoverage(objectiveCode)` | 6.4 | `covered` / `worked` / `notEvaluated` |
| `daysToClose(refDate)` | 6.4 | Días corridos hasta el cierre del semestre en curso |

Los promedios del curso se calculan **promediando los promedios de los estudiantes** y redondeando una vez. Así lo hace el cálculo de control (5.7 del contexto).

### 6.3 Parámetros de configuración

| Nombre | Valor | Fuente |
|---|---|---|
| `PASSING_THRESHOLD` | 0,6 | Constitución 6.1 |
| `PASSING_GRADE` | 40 (4,0) | Constitución 6.1 |
| `LEVEL_ADEQUATE` | 0,8 | Constitución 6.2 |
| `RISK_RECENT_WINDOW_MONTHS` | 2 | Constitución 6.3 (b) |
| `RISK_RECENT_FAILS` | 2 | Constitución 6.3 (b) |
| `RISK_DROP_POINTS` | 20 | Constitución 6.3 (c) |
| `RISK_ABSENCES` | 2 | Constitución 6.3 (d) |
| `SEMESTER_CLOSE` | `{ 1: "06-30", 2: "12-03" }` | Constitución 6.4 |
| `REFERENCE_DATE` | 2026-10-27 | Este plan, sección 5 |
| `CRITICAL_QUESTION` | 0,5 | Supuesto S2 |
| `TOP_N` | 5 | Supuesto S1 |
| `COVERAGE_ALERT_DAYS` | 45 | Supuesto S3 |

---

## 7. Simulación de preguntas (HU-15 y HU-16)

La planilla llega hasta el grano estudiante × OA. La plataforma sí tiene las preguntas, así que el mock up las **simula** de forma determinista y coherente:

1. **Preguntas:** cada sumativa tiene **1 pregunta de 1 punto por cada punto máximo del OA** (supuesto S6: una pregunta, un OA). Por ejemplo, un OA de 20 puntos en S1 da 20 preguntas.
2. **Dificultad:** cada pregunta recibe una dificultad ficticia, generada con un generador pseudoaleatorio de **semilla fija**.
3. **Respuestas:** un estudiante con `score` puntos en un OA acierta exactamente `score` preguntas de ese OA. Se asignan con preferencia a las más fáciles, con algo de variación de la misma semilla.
4. **Garantía de coherencia:** la suma de aciertos por estudiante y OA es **igual** al puntaje de la planilla. El script lo comprueba y se detiene si no se cumple.
5. **Ausentes:** no tienen respuestas y no entran en el % de acierto de la pregunta.

Solo se simulan preguntas para las sumativas (S1, S2 y S3), que es lo que pide P2.

---

## 8. Pantallas y navegación

**Encabezado fijo** (HU-02):
- Selector de curso (uno solo en el mock up).
- Selector de semestre (por defecto el 2°, según `REFERENCE_DATE`).
- La leyenda "Datos de ejemplo al 27-10-2026".

**Pestañas:**

| # | Pestaña | Historias | Contenido principal |
|---|---|---|---|
| 1 | **Resumen** | HU-04, HU-05, HU-18 | Tarjetas con el promedio del semestre, el promedio anual (con "parcial"), el conteo 🔴🟡🟢, OA cubiertos del total y días al cierre. Alerta de OA sin evaluar. |
| 2 | **Estudiantes** | HU-06 a HU-09 | Lista con semáforo (ícono + texto), motivos, línea base, promedio semestral y anual, y etiqueta PIE. Filtro por color; orden por color, promedio o nombre. |
| 3 | **Mapa de calor** | HU-10 | Estudiantes × CN1M OA 17–20. Celdas con % y nivel; semáforo en la primera columna; promedio del curso en la última fila. "Sin evaluar" y "Ausente" diferenciados. Texto oficial del OA al pasar el cursor. |
| 4 | **Sumativas** | HU-12 a HU-16 | Selector S1/S2/S3. Resumen y distribución en 4 tramos, reprobados, mejores resultados, preguntas ordenadas por % de acierto ("Crítica" bajo 50%) y logro por OA. |
| 5 | **Avance curricular** | HU-17 a HU-19, HU-21 | Estado de cada OA de conocimiento, días al cierre, línea de tiempo con las 9 evaluaciones, los cierres y "hoy". Botón "Sugerir actividades" en OA descendidos (maqueta). |
| 6 | **Mi semana** | HU-22 | Calendario lunes a viernes con evaluaciones de ejemplo, tipo por color y etiqueta, y el cierre marcado. Banda "Próximamente". |

**Ficha del estudiante** (HU-20): panel lateral que se abre al hacer clic en un nombre, desde cualquier pestaña. Muestra:
- El semáforo y sus motivos.
- Los promedios semestral y anual, y la línea base.
- Un gráfico SVG de la evolución del % de logro.
- El logro por OA comparado con el curso.
- La etiqueta PIE, si corresponde.
- **RUT: no se muestra.** La planilla no lo trae, y la Constitución 7.1 lo permite.

**Regla de 3 clics (RNF-05):** desde el Resumen, cualquier dato de un estudiante se alcanza así: pestaña → nombre → ficha (2 clics). Un dato de pregunta: Sumativas → evaluación → Preguntas (3 clics).

**Visualizaciones** (SVG o CSS propio, sin librerías):
- Barras de distribución de notas y de logro por OA.
- Celdas del mapa de calor.
- Línea de evolución en la ficha.
- Línea de tiempo.

**Colores** (accesibles, AA, cada uno con su texto):
- **Semáforo:** 🔴 "En riesgo", 🟡 "Alerta", 🟢 "Sin alerta".
- **Niveles de logro:** Insuficiente, Elemental y Adecuado.
- **Sin evaluar:** gris con trama.

**Diseño:** pensado para 1366 px; se puede leer a 768 px.

---

## 9. Formato y textos (es-CL)

- **Números:** notas con un decimal y coma (`4,6`), porcentajes con un decimal (`62,5%`) y fechas `dd-mm-aaaa`.
- **Códigos de OA:** siempre oficiales (`CN1M OA 19`). Nunca OA1–OA5.
- **Términos:** diagnóstica, formativa, sumativa, PIE, apoderado. La nota de la diagnóstica se rotula "Diagnóstico" (Constitución 6.1, v5.0.3).
- **Valores vacíos:** "Sin notas", "Ausente" o "Sin evaluar". Nunca `0`, `1,0` ni `NaN`.

---

## 10. Verificación

### 10.1 Automática (`dashboard-docente.html?verificar`)

Ejecuta los casos y muestra un panel ✅/❌ (también en la consola). La entrega no se da por terminada con algún ❌.

| Grupo | Casos |
|---|---|
| Nota | 0% → 1,0 · 30% → 2,5 · 60% → 4,0 · 80% → 5,5 · 100% → 7,0 |
| Nivel | 59,9% → Insuficiente · 60% → Elemental · 79,9% → Elemental · 80% → Adecuado |
| Semestre | 30-06 → 1° · 01-07 → 2° · días al cierre al 27-10-2026 = 37 |
| Promedios | Sumativas 4,0 y 4,4 (pesos 30 y 35) → 4,2 · E05 2° semestre → 4,3 · E05 1° semestre → 3,3 (F2 Ausente; D1 no pesa) · anual 3,4 y 4,2 → 3,8 · 3,9 y 4,0 → 4,0 · semestre sin notas → "Sin notas" y sin 🔴 |
| Ausente | F2 de E05 → "Ausente", sin nota y fuera del promedio |
| Semáforo | Al menos un caso por cada condición: 🔴, 🟡 (a), (b), (c), (d) y 🟢. PIE no cambia el color. |
| Cifras de control | D1: promedio 3,9 con 19 bajo 4,0 · S1: promedio 4,6 con 10 reprobados · curso: 4,4 (1° sem.), 4,7 (2° sem.) y 4,6 (anual) · 9 en 🔴 en el 2° semestre (E07, E09, E17, E18, E21, E30, E31, E32, E33) · 8 bajo 4,0 anual · E30 en 🔴 · 3 de 4 OA cubiertos · CN1M OA 19 "Sin evaluar" |
| Preguntas | Aciertos por estudiante y OA = puntaje de la planilla, en las 3 sumativas |

### 10.2 Manual (antes de mostrar a docentes)

- [x] Se abre con doble clic, sin conexión a internet y sin errores en la consola.
- [x] Se lee bien a 1366 px; a 768 px no hay scroll horizontal en el Resumen.
- [x] Ningún semáforo ni nivel depende solo del color.
- [x] No aparecen RUT, género ni asistencia en ninguna vista.
- [x] PIE no aparece como filtro ni como criterio de orden.
- [x] HU-21 y HU-22 están marcadas como "Vista previa" y "Próximamente".
- [x] Todos los OA usan códigos oficiales.

La revisión se hace en el navegador integrado de la app, con capturas a 1366 px y a 768 px.

---

## 11. Decisiones del PO (aprobadas el 27-10-2026)

Eran puntos donde la spec y la Constitución admitían más de una lectura. El PO **aprobó las 7 propuestas tal como estaban**.

| # | Tema | Situación | Decisión aprobada |
|---|---|---|---|
| D1 ✅ | **Mapa de calor en el 2° semestre** (S4) | En el 2° semestre solo CN1M OA 20 tiene evaluaciones. OA 17 y 18 se midieron en el 1°, y OA 19 nunca. Con S4, el mapa del 2° semestre tendría una sola columna con datos. | Mostrar siempre las 4 columnas y distinguir "No evaluado en este semestre" (gris claro) de "Sin evaluar en el año" (gris con trama). |
| D2 ✅ | **Habilidades en el análisis de sumativas** | S3 mide OA 20 y una habilidad (planilla OA5 → CN1M OAH d, f). La Constitución excluye las OAH de la cobertura, pero no dice nada del análisis de sumativas (HU-13, HU-15, HU-16). | Mostrarla en el análisis de la sumativa con la etiqueta "Habilidad", porque es parte de la prueba. Excluirla del mapa de calor y de la cobertura. |
| D3 ✅ | **Ventana "últimos 2 meses"** (6.3 b) | Al 27-10, ¿entra una evaluación del 27-08 (justo 2 meses antes)? | Ventana **inclusiva**: fecha ≥ hoy − 2 meses. Entran F4 (27-08) y F5 (17-09). |
| D4 ✅ | **"Evaluaciones consecutivas"** (6.3 c) | ¿La caída se mide solo dentro del semestre o en la secuencia del año? ¿La diagnóstica cuenta? | Secuencia del **año**, por fecha y con todos los tipos. Así se detecta una caída justo al empezar el semestre (F3 11-06 → S2 02-07). |
| D5 ✅ | **Ausencias** (6.3 d) | ¿Las 2 o más ausencias se cuentan en el semestre o en el año? | En el **semestre** seleccionado, igual que el 🔴. |
| D6 ✅ | **Semáforo de un semestre cerrado** | Si la docente elige el 1° semestre, ¿qué semáforo ve? | El semáforo del semestre elegido, calculado a su fecha de cierre (30-06), con la leyenda "Estado al cierre del 1° semestre". |
| D7 ✅ | **Carpeta `mockup/scripts/`** | La estructura de la Constitución 3 no tenía una carpeta para scripts de preparación de datos. | Crear `mockup/scripts/` solo para `extract-data.ps1`, y agregarla a la estructura (Constitución 5.0.1). |

D3 a D6 aclaran el semáforo y D7 la estructura: quedaron registradas en la **Constitución v5.0.1** (PATCH). D1 y D2 son decisiones de interfaz y viven en este plan.

---

## 12. Riesgos

| Riesgo | Mitigación |
|---|---|
| Las docentes leen las preguntas simuladas como reales | Etiqueta "Preguntas de ejemplo" en la vista de sumativas. |
| Las cifras se desalinean de la Constitución al iterar la interfaz | El modo `?verificar` corre las cifras de control; se ejecuta antes de cada entrega. |
| El HTML crece demasiado para mantenerse a mano | Bloques separados con marcadores (sección 4); los datos van aparte, en JSON. |
| El conteo de 🟡 aún no tiene cifra de control | Con D3–D5 aprobadas, se calcula en la primera implementación y se registra como cifra de control (tarea T014). |
| Las reglas en JavaScript divergen del futuro backend en Python | Los casos de 10.1 se reutilizan tal cual como tests `pytest` del MVP. |

---

## 13. Siguiente paso

Las tareas están en [`tasks.md`](tasks.md). Orden general:

1. Script de extracción y JSON generado.
2. Reglas de dominio y modo `?verificar`.
3. Encabezado y pestañas Resumen y Estudiantes.
4. Mapa de calor.
5. Sumativas y preguntas.
6. Avance curricular.
7. Ficha del estudiante.
8. Maquetas de HU-21 y HU-22.
9. Revisión manual y capturas.
