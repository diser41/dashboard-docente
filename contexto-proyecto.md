# Misión Dashboard — Contexto del proyecto

_Última actualización: 2026-10-27_

## 1. Quiénes somos

Plataforma que facilita el proceso de evaluación (diagnóstica, sumativa y formativa) a docentes de Latinoamérica. Los docentes configuran la evaluación y los estudiantes la rinden a través de la plataforma.

## 2. Propósito del dashboard

Permitir que los docentes analicen los resultados de sus estudiantes **a medida que se recolecta la data**, y tomen decisiones y acciones pedagógicas en el camino (no solo al cierre del período).

## 3. Usuarios

| Etapa | Usuario | Necesidad |
|---|---|---|
| **Etapa 1 (actual)** | Docente de asignatura | Ver resultados de sus cursos y estudiantes, detectar quién está en riesgo y qué OA reforzar. |
| Etapa 2 (futura) | Equipo directivo | Panorama macro del establecimiento y por asignatura. |

- **Cliente:** el establecimiento.
- **Usuario del dashboard en esta etapa:** el docente.

## 4. Datos

- **Origen real:** los datos **ya existen en la plataforma** (evaluaciones, resultados por pregunta, OA del año, marca PIE). El docente **no carga nada**: el dashboard los lee directamente.
- **Mock up:** se usa la planilla Excel de ejemplo como sustituto de esa fuente.
- **Futuro:** conexión directa a la base de datos de la plataforma.

**Datos disponibles en la plataforma** (confirmado el 2026-10-27):

| Dato | ¿Disponible? |
|---|---|
| Resultados por pregunta o ítem | Sí |
| OA del año completo, todas las asignaturas | Sí |
| Estudiantes PIE | Sí |
| Asistencia | **No**. La planilla de ejemplo la trae, pero no se usará. |

### 4.1 Planilla de ejemplo: `data/Base_Evaluaciones_1MA_Quimica_2026.xlsx`

Datos **ficticios** de 1° Medio A, Química 2026: 35 estudiantes, 5 OA y 9 evaluaciones, entre el 12-03-2026 y el 01-10-2026.

| Hoja | Grano (una fila por…) | Columnas |
|---|---|---|
| Léeme | — | Descripción y reglas de cálculo |
| Estudiantes | estudiante (35) | ID estudiante, Nombre, Género, PIE, Asistencia (%) |
| OA | OA (5) | Código OA, Descripción |
| Evaluaciones | evaluación (9) | ID evaluación, Tipo, Nombre, Instrumento, Fecha, OA evaluados, Puntaje máximo por OA, Ponderación en nota final |
| Resultados | estudiante × evaluación × OA (525) | ID estudiante, Estudiante, ID evaluación, Tipo, Fecha, OA, Puntaje obtenido, Puntaje máximo, Estado, % de logro, Nivel de logro |
| Notas | estudiante (35) + promedio del curso | % logro y nota de S1, S2 y S3, Promedio ponderado, Situación |

**Evaluaciones:**
- **D1:** diagnóstica, evalúa los 5 OA.
- **F1 a F5:** formativas, una por OA.
- **S1, S2 y S3:** sumativas. S1 mide OA1 y OA2; S2 mide OA3; S3 mide OA4 y OA5.

**Reglas de cálculo (vienen de la planilla):**
- **% de logro** = puntaje obtenido ÷ puntaje máximo. Queda vacío si el estudiante estuvo ausente.
- **Nivel de logro:**
  - Insuficiente: menos de 60%.
  - Elemental: de 60% a 79%.
  - Adecuado: 80% o más.
- **Nota:** escala de 1.0 a 7.0 con **60% de exigencia** (4.0 = 60%). La planilla la calcula solo en las sumativas, pero **por decisión del PO todas las evaluaciones llevan nota** (ver 5.7).
  - Si el % es menor a 60%: `1 + %/0.6 × 3`.
  - Si no: `4 + (% − 0.6)/0.4 × 3`.
  - Se redondea a 1 decimal.
- **Promedio ponderado:** S1 35% · S2 30% · S3 35%.
- **Situación:** "En riesgo" si el promedio es menor a 4.0. En el ejemplo hay 11 de 35 estudiantes en riesgo.
- **Estado:** Rendida o Ausente. Las 8 ausencias del ejemplo son todas en formativas.

**Lo que la planilla NO trae, aunque la plataforma sí lo tiene:**
- Resultados **por pregunta o ítem**: en la planilla el detalle más fino es estudiante × OA. Para el mock up habrá que **simular preguntas ficticias** coherentes con los puntajes por OA.
- **OA del año completo:** ver 4.2.

**Lo que no existe en ninguna fuente:**
- Calendario escolar, planificación semanal, reuniones o entrevistas.
- Asistencia.

**Otras limitaciones de la planilla:**
- Solo hay un curso y una asignatura.
- No trae RUT: usa un ID interno (E01…) y el nombre.

### 4.2 OA del año: Química 1° medio (MINEDUC)

- **Fuente:** [Currículum Nacional, Ciencias Naturales 1° medio](https://www.curriculumnacional.cl/curriculum/7o-basico-2o-medio/ciencias-naturales/1-medio). Consultado el 2026-10-27.
- **Archivo:** [`data/OA_Quimica_1M_MINEDUC.csv`](data/OA_Quimica_1M_MINEDUC.csv), con el texto oficial.
- En 1° medio, Química es un **eje de la asignatura Ciencias Naturales**. Sus OA de conocimiento son **CN1M OA 17 a 20**. Las 13 habilidades científicas (**CN1M OAH a–m**) son comunes a los tres ejes.

| OA oficial | Tema | OA de la planilla | Evaluado en |
|---|---|---|---|
| CN1M OA 17 | Reacciones químicas en la vida diaria | OA1 | D1, F1, S1 |
| CN1M OA 18 | Conservación de la materia (átomos y masa) | OA2 | D1, F2, S1 |
| **CN1M OA 19** | **Compuestos binarios y ternarios, nomenclatura inorgánica** | **—** | **Nunca** |
| CN1M OA 20 | Estequiometría y compuestos útiles para los seres vivos | OA3 + OA4 | D1, F3, F4, S2, S3 |
| CN1M OAH d, f… | Investigación científica | OA5 | D1, F5, S3 |

**Hallazgo para el dashboard:** en el ejemplo, a octubre **el OA 19 no se ha evaluado nunca**. Es justo la alerta de cobertura curricular que debe mostrar P1 ("¿cuánto me queda?").

**Nota:** la numeración OA1–OA5 de la planilla es ilustrativa. En el mock up se usará la numeración oficial.

## 5. Requisitos

### 5.1 Requisitos definidos por el equipo

1. **Cobertura curricular:** contrastar los **OA del año** (Objetivos de Aprendizaje del currículum) con los **OA medidos en cada proceso evaluativo**.
2. **Estudiantes en riesgo:** identificarlos de forma sencilla y visual (idea inicial: mapa de calor o semáforo; abierta a propuestas).
3. **Escala de notas chilena:** de 1.0 a 7.0, con nota de aprobación 4.0.

### 5.2 Lo que pide la profesora (`inputs/WhatsApp Image 2026-10-27 at 11.54.16.jpeg`)

| # | Necesidad | ¿Se puede con la data actual? |
|---|---|---|
| P1 | **Avance curricular:** cuántos objetivos he trabajado y cuánto tiempo me queda para completarlos. | **Sí**, con los OA del año (4.2) y las fechas de cierre de 5.5. |
| P2 | **Por cada evaluación sumativa:** cantidad y nombres de quienes reprobaron, mejores resultados, promedio del curso y **preguntas** con menor logro, para retroalimentar. | **Sí.** La plataforma registra resultados por pregunta; en el mock up se simulan. |
| P3 | **Ideas de actividades** para los aprendizajes más descendidos (conectado con IA). | **Futuro.** Los OA descendidos se identifican con la data actual; la generación de actividades requiere integrar IA. |
| P4 | **Mini planificación semanal** estilo calendario: qué hacer en cada curso, actividades, reuniones y entrevistas con estudiantes o apoderados. | **Acotada por el PO (27-10) a evaluaciones.** Las fechas de las evaluaciones ya están en la plataforma. Actividades, reuniones y entrevistas quedan fuera. |

### 5.3 Propuesta de alcance para el mock up (por validar)

- **Incluir:**
  - P2 completo, con preguntas simuladas.
  - P1 con los OA oficiales de conocimiento y las fechas de cierre de 5.5.
  - El semáforo y mapa de calor de estudiantes en riesgo (criterio en 5.4).
- **Dejar como maqueta visual, sin datos reales:**
  - P3, como un botón "Sugerir actividades".
  - P4, como un calendario de ejemplo.

### 5.4 Criterio de riesgo: semáforo con alerta temprana (aprobado el 2026-10-27)

Usa solo datos de la plataforma, **sin asistencia**. Se recalcula cada vez que se cierra una evaluación.

| Color | Condición |
|---|---|
| 🔴 **En riesgo** | Promedio **del semestre en curso** (sumativas rendidas hasta la fecha) menor a 4.0. |
| 🟡 **Alerta temprana** | No está en rojo, pero cumple al menos una de estas señales: <br>• Última sumativa con nota menor a 4.0. <br>• 2 o más formativas o diagnósticas en nivel **Insuficiente** (menos de 60%) en los últimos 2 meses. <br>• Caída de 20 puntos porcentuales o más en el % de logro entre dos evaluaciones consecutivas. <br>• 2 o más evaluaciones con estado **Ausente**. |
| 🟢 **Sin alerta** | No cumple ninguna de las condiciones anteriores. |

- Cada alerta muestra **el motivo** (por ejemplo, "2 formativas Insuficiente: OA 18, OA 20") para que el docente sepa qué hacer.
- **PIE no es un factor de riesgo.** Se muestra como una marca de contexto junto al nombre (ver 7).
- Los umbrales (60%, 20 puntos, 2 meses, 2 ausencias) son **parámetros configurables**, no valores fijos en el código.
- **Conteos validados por el PO (27-10-2026)** con la data de ejemplo:
  - 2° semestre al 27-10-2026: 9 🔴, 5 🟡 y 21 🟢. Los 5 🟡 son por caída de 20 puntos o más (E01, E15, E22, E25 y E34).
  - 1° semestre al cierre del 30-06: 9 🔴, 13 🟡 y 13 🟢.
  - Una caída cuenta para el semestre de la evaluación más reciente del par (Constitución v5.0.2).

### 5.5 Calendario de cierre y alcance de la cobertura (definido el 2026-10-27)

**Fechas de cierre:** son las fechas límite para tener **todas las calificaciones registradas**.

| Período | Cierre de calificaciones |
|---|---|
| 1° semestre | **30 de junio** |
| 2° semestre | **3 de diciembre** |

- **"Tiempo restante" (P1):** días hasta el cierre del semestre en curso. Al 27-10-2026 quedan **37 días** para el cierre del 2° semestre.
- **Cobertura curricular:** **solo OA de conocimiento** (en Química 1° medio, CN1M OA 17–20). Las habilidades (OAH) no se muestran por ahora.

**Semestres en la planilla de ejemplo:**
- **1° semestre:** D1 (12-03), F1 (09-04), F2 (23-04), S1 (07-05) y F3 (11-06).
- **2° semestre:** S2 (02-07), F4 (27-08), F5 (17-09) y S3 (01-10).
- **Alerta del mock up:** al 27-10 quedan 37 días y el **OA 19 sigue sin evaluar**.

### 5.6 Promedios: semestral y anual (definido el 2026-10-27)

El dashboard muestra **los dos promedios**:

| Promedio | Cálculo | Uso |
|---|---|---|
| **Semestre en curso** | Promedio simple de **cada formativa + el promedio de sumativas** del semestre. La diagnóstica no pesa (ver 5.7). | Vista principal y **semáforo** 🔴 |
| **Anual** | **Promedio simple de los dos semestres**: `(semestre 1 + semestre 2) / 2`. Cada promedio semestral se redondea a 1 decimal antes de promediar. | Referencia |

- **Dentro del semestre en curso**, mientras no termine, el anual se calcula con el semestre 1 cerrado y el semestre 2 parcial.
- **Diferencia con la planilla:** la hoja `Notas` calcula el anual con 35/30/35 sobre todas las sumativas. El dashboard **no** usa esa columna: recalcula con la regla de esta sección.

### 5.7 Todas las evaluaciones llevan nota (definido el 2026-10-27)

- Diagnósticas, formativas y sumativas tienen nota de 1,0 a 7,0, con la misma escala y la misma exigencia del 60%.
- Un estudiante ausente no tiene nota en esa evaluación, y esa evaluación no cuenta en su promedio.

**Nota promedio del curso por evaluación (recalculada con la planilla):**

| Evaluación | Tipo | Fecha | Promedio del curso | Bajo 4,0 | Rindieron |
|---|---|---|---|---|---|
| D1 | Diagnóstica | 12-03 | 3,9 | 19 | 35 |
| F1 | Formativa | 09-04 | 4,7 | 3 | 33 |
| F2 | Formativa | 23-04 | 4,1 | 12 | 33 |
| S1 | Sumativa | 07-05 | 4,6 | 10 | 35 |
| F3 | Formativa | 11-06 | 4,1 | 15 | 33 |
| S2 | Sumativa | 02-07 | 4,1 | 18 | 35 |
| F4 | Formativa | 27-08 | 4,0 | 13 | 34 |
| F5 | Formativa | 17-09 | 5,5 | 3 | 34 |
| S3 | Sumativa | 01-10 | 4,9 | 7 | 35 |

**Ponderación en el promedio semestral** (definida por el PO):

| Tipo | Peso en el promedio |
|---|---|
| **Diagnóstica** | **No pesa.** Es la **línea base**: una referencia del punto de partida del estudiante. |
| **Formativa** | Cada una pesa 1; todas pesan igual. |
| **Sumativas** | Su promedio (con las ponderaciones de cada sumativa, reescaladas dentro del semestre) pesa 1, igual que una formativa. |

**Fórmula por semestre en la planilla:**
- **1° semestre:** `(F1 + F2 + F3 + S1) / 4`. D1 queda como línea base.
- **2° semestre:** `(F4 + F5 + prom(S2, S3)) / 3`.
- **Ponderación de las sumativas:** en la planilla de ejemplo da el mismo resultado usar el promedio ponderado (30/35) o el simple.

**Resultado con la planilla de ejemplo:**

| Indicador | Valor |
|---|---|
| Promedio del curso, 1° semestre | **4,4** |
| Promedio del curso, 2° semestre | **4,7** |
| Promedio del curso, anual | **4,6** |
| En 🔴 según el 2° semestre (semáforo) | **9**: E07, E09, E17, E18, E21, E30, E31, E32, E33 |
| Bajo 4,0 según el anual | **8**: E05, E07, E09, E17, E22, E31, E32, E33 |

**Casos que conviene mirar:**

| Estudiante | Línea base | 1° sem. | 2° sem. | Anual | Lectura |
|---|---|---|---|---|---|
| E05 | 2,9 | 3,3 | 4,3 | 3,8 | Partió muy bajo y viene mejorando: 🟢 en el semestre, pero el anual sigue bajo 4,0. |
| E18 | 4,2 | 4,6 | 3,7 | 4,2 | Cae en el 2° semestre: 🔴, aunque el anual se ve aprobado. |
| E22 | 3,3 | 3,3 | 4,1 | 3,7 | Mejora y sale del 🔴, pero el anual sigue bajo 4,0. |
| E30 | 4,9 | 4,9 | 3,7 | 4,3 | Empezó bien y cae: 🔴. Es el caso que el anual escondería. |

## 6. Tecnología

| Fase | Stack |
|---|---|
| Mock up (actual) | HTML |
| Desarrollo (futuro) | Backend en Python y frontend en Node |
| Repositorio | Git de Diana |

## 7. Restricciones y seguridad

- **Dato sensible principal:** identificador del estudiante. En Chile probablemente será el **RUT**, que debe estar protegido.
- En el mock up se usarán identificadores ficticios o seudonimizados, nunca RUT reales.
- **PIE:** es un dato sensible (necesidades educativas especiales).
  - Solo lo ve el docente del curso.
  - Se muestra como una marca discreta, no como un filtro ni un ranking.
  - Nunca se usa como factor de riesgo.
  - Nunca aparece en exportaciones sin control de acceso.
- **Asistencia:** no se usa, porque la plataforma no la tiene.

## 8. Metodología

Se trabajará con **Spec-Driven Development (SDD)**, según el material en `inputs/`. El flujo es **Constitución → Especificar → Planificar → Tareas → Implementar**. La Constitución del proyecto está en [`.specify/constitution.md`](.specify/constitution.md) (v5.0.3, ratificada el 2026-10-27). Los requerimientos y las historias de usuario están en [`specs/001-dashboard-docente/spec.md`](specs/001-dashboard-docente/spec.md): 9 épicas, 22 historias, 22 RF y 11 RNF. Estado: aprobada por el PO (v1.1, 27-10-2026). El plan técnico del mock up está en [`specs/001-dashboard-docente/plan.md`](specs/001-dashboard-docente/plan.md) (v1.0, aprobado) y las tareas en [`specs/001-dashboard-docente/tasks.md`](specs/001-dashboard-docente/tasks.md) (28 tareas, todas terminadas).

### 8.1 Estado del mock up (27-10-2026)

- **Archivo:** [`mockup/dashboard-docente.html`](mockup/dashboard-docente.html). Se abre con doble clic, sin servidor ni internet. Con `?verificar` muestra las pruebas (76 casos, todos correctos).
- **Datos:** [`data/mockup-data_generado.json`](data/mockup-data_generado.json), generado desde la planilla por [`mockup/scripts/extract-data.ps1`](mockup/scripts/extract-data.ps1). No incluye género ni asistencia.
- **Contenido:**
  - Pestañas Resumen (con la tabla "Requieren atención" tipo libro de clases), Estudiantes, Mapa de calor, Sumativas, Avance curricular y Mi semana.
  - Ficha del estudiante.
  - Maquetas de HU-21 ("Vista previa") y HU-22 ("Próximamente").
- **Capturas:** [`docs/capturas/`](docs/capturas/).
- **Accesibilidad:** contraste AA medido en modo claro y oscuro, uso completo con teclado, y ningún estado que dependa solo del color.
- **Ajustes respecto del plan:**
  - Los marcadores de datos son comentarios HTML.
  - Hay 490 resultados en vez de 525, porque OA3 y OA4 se suman en CN1M OA 20.
  - Se agregó más variación entre estudiantes en las preguntas simuladas.
  - "Requieren atención" pasó a ser tabla tipo libro de clases (spec v1.1).
  - El rótulo "Línea base" pasó a ser "Diagnóstico" (Constitución v5.0.3).
  - La pestaña se puede indicar en la dirección (`#heatmap`), nunca con datos de estudiantes.
  - Nombre y apellido se separan desde el nombre completo de la planilla (la plataforma real los entrega por separado).
- **Repositorio público:** https://github.com/diser41/dashboard-docente. No incluye `inputs/` ni la transcripción de la sesión.
- **Siguiente paso:** validar el mock up con docentes.

## 9. Preguntas abiertas

- [x] Feedback de la profesora sobre qué información quiere ver (ver 5.2).
- [x] Estructura del Excel (ver 4.1).
- [x] **Todas las evaluaciones llevan nota:** diagnósticas, formativas y sumativas (ver 5.7; Constitución v4.0.0).
- [x] **Ponderación:** la diagnóstica no pesa; cada formativa pesa 1; el promedio de sumativas pesa 1 (ver 5.7; Constitución v5.0.0).
- [x] **Datos por pregunta:** la plataforma los registra (ver 4).
- [x] **OA del año:** están en la plataforma; los de Química 1° medio quedaron en `data/OA_Quimica_1M_MINEDUC.csv` (ver 4.2).
- [x] **PIE y asistencia:** PIE sí, asistencia no (ver 4 y 7).
- [x] **Criterio de riesgo:** semáforo aprobado (ver 5.4).
- [x] **Constitución:** redactada (`.specify/constitution.md`).
- [x] **Fechas de cierre:** 30 de junio y 3 de diciembre (ver 5.5).
- [x] **Habilidades (OAH):** por ahora solo se muestran los OA de conocimiento (ver 5.5).
- [x] **Promedio por semestre:** se muestran los dos; el semáforo usa el del semestre en curso (ver 5.6).
- [x] **Promedio anual:** es el promedio simple de los dos semestres (ver 5.6).
- [ ] **Alcance del mock up:** validar la propuesta de 5.3.
- [x] **Planificación semanal (P4):** solo evaluaciones (EP9 / HU-22).
- [x] **Prioridad de HU-22:** se mantiene en W (solo maqueta visual, con un ejemplo marcado "Próximamente"). Decisión del PO del 27-10-2026.
- [x] **Decisiones del plan del mock up (D1–D7):** mapa de calor en el 2° semestre, habilidades en el análisis de sumativas, ventana de 2 meses, evaluaciones consecutivas, conteo de ausencias, semáforo de un semestre cerrado y carpeta `mockup/scripts/`. Detalle en `plan.md`, sección 11. Aprobadas por el PO el 27-10-2026; D3–D7 quedaron en la Constitución v5.0.1.
