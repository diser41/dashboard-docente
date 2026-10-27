# Spec 001 — Dashboard docente: requerimientos e historias de usuario

| | |
|---|---|
| **Estado** | ✅ Aprobada por el Product Owner (27-10-2026) |
| **Versión** | 1.1 (HU-04: tabla "Requieren atención" tipo libro de clases) |
| **Fecha** | 2026-10-27 |
| **Rige** | [Constitución v5.0.3](../../.specify/constitution.md) |
| **Contexto** | [contexto-proyecto.md](../../contexto-proyecto.md) |

---

## 1. Visión del producto

> **Para** docentes de asignatura **que** evalúan a sus estudiantes en la plataforma, **el dashboard docente** es una vista de seguimiento **que** muestra a tiempo quién necesita apoyo, qué OA reforzar y cuánto currículum falta cubrir antes del cierre del semestre. **A diferencia de** una planilla de notas que solo muestra resultados al final, **nuestro producto** alerta durante el semestre y lleva cada dato a una acción pedagógica.

### 1.1 Objetivos y métricas de éxito

| # | Objetivo | Métrica (a medir con docentes piloto) |
|---|---|---|
| O1 | Detectar antes a los estudiantes en riesgo | Más del 80% de los estudiantes que terminan en 🔴 tuvieron una alerta 🟡 al menos 3 semanas antes. |
| O2 | Retroalimentar mejor después de cada sumativa | El docente identifica las preguntas más descendidas en menos de 1 minuto. |
| O3 | Llegar al cierre con el currículum cubierto | 0 OA de conocimiento sin evaluar en la fecha de cierre del semestre. |
| O4 | Ahorrar tiempo al docente | No hay carga manual de datos; el docente ve el estado de su curso en menos de 3 clics. |

---

## 2. Usuarios (personas)

| Persona | Etapa | Descripción | Qué necesita |
|---|---|---|---|
| **Docente de asignatura** | Etapa 1 (este spec) | Hace clases en uno o más cursos. Configura evaluaciones en la plataforma. Tiene poco tiempo. | Saber, de un vistazo, cómo va cada curso, a quién apoyar, qué OA reforzar y cuánto le queda. |
| Equipo directivo (UTP, dirección) | Etapa 2 (spec futuro) | Supervisa varias asignaturas y cursos. | Panorama agregado del establecimiento. |

---

## 3. Alcance

| Incluido en este spec | Fuera de este spec |
|---|---|
| Resumen del curso, semáforo de riesgo, mapa de calor, análisis de sumativas, avance curricular y ficha del estudiante | Vista del equipo directivo (etapa 2) |
| Maqueta visual (sin funcionalidad real) de sugerencias de actividades con IA y del calendario semanal de evaluaciones | Generación real de actividades con IA |
| | Actividades, reuniones y entrevistas con estudiantes o apoderados en el calendario |
| | Cobertura de habilidades (OAH) |
| | Asistencia (la plataforma no la tiene ni la tendrá) |
| |No se considera carga manual de datos |

**Entregas:**
- **Mock up:** HTML con datos ficticios, para validar con docentes.
- **MVP:** primera versión funcional (Python + Node) conectada a la plataforma.
- **Futuro:** fuera del MVP; se especificará aparte.

---

## 4. Épicas

| ID | Épica | Origen | Entrega |
|---|---|---|---|
| EP1 | Acceso, contexto y navegación | Transversal | Mock up / MVP |
| EP2 | Resumen del curso | Equipo | Mock up / MVP |
| EP3 | Semáforo de riesgo y alertas tempranas | Equipo (aprobado 27-10) | Mock up / MVP |
| EP4 | Mapa de calor estudiantes × OA | Equipo | Mock up / MVP |
| EP5 | Análisis de evaluaciones sumativas | Profesora (P2) | Mock up / MVP |
| EP6 | Avance y cobertura curricular | Equipo + Profesora (P1) | Mock up / MVP |
| EP7 | Ficha del estudiante | Equipo | Mock up / MVP |
| EP8 | Sugerencias de actividades con IA | Profesora (P3) | Maqueta visual → Futuro |
| EP9 | Planificación semanal de evaluaciones| Profesora (P4) | Maqueta visual → Futuro |

---

## 5. Historias de usuario

**Formato:** *Como [rol], quiero [acción], para [beneficio]*. Los criterios de aceptación usan Dado / Cuando / Entonces. Los valores de ejemplo vienen de la planilla `data/Base_Evaluaciones_1MA_Quimica_2026.xlsx`, con fecha de referencia 27-10-2026.

**Prioridad (MoSCoW):**
- **M** = Must (debe tener).
- **S** = Should (debería tener).
- **C** = Could (podría tener).
- **W** = Won't (no en esta entrega).

### EP1 — Acceso, contexto y navegación

#### HU-01 · Ver solo mis cursos — M · MVP
**Como** docente, **quiero** ver únicamente los cursos y asignaturas que yo dicto, **para** no exponer ni confundir datos de otros cursos.
- **Dado** que dicto Química en 1° Medio A y 1° Medio B, **cuando** entro al dashboard, **entonces** veo solo esos dos cursos y ningún otro.
- **Dado** que intento acceder por URL a un curso que no dicto, **cuando** cargo la página, **entonces** veo "No tienes acceso a este curso" y no se muestra ningún dato.

#### HU-02 · Elegir curso, asignatura y semestre — M · Mock up / MVP
**Como** docente, **quiero** cambiar entre mis cursos y entre el 1° y el 2° semestre, **para** revisar cada grupo por separado.
- **Dado** que entro al dashboard, **cuando** carga, **entonces** se muestra por defecto el semestre en curso según la fecha de hoy (al 27-10-2026, el 2° semestre).
- **Dado** que cambio de curso o de semestre, **cuando** selecciono otro, **entonces** todos los indicadores se recalculan para esa selección.

#### HU-03 · Saber cuándo se actualizó la información — S · MVP
**Como** docente, **quiero** ver la fecha y hora de la última actualización, **para** confiar en que estoy viendo datos vigentes.
- **Dado** que un estudiante rindió una evaluación, **cuando** la evaluación se cierra en la plataforma, **entonces** el dashboard la refleja sin que yo cargue nada, y muestra "Actualizado: dd-mm-aaaa hh:mm".

---

### EP2 — Resumen del curso

#### HU-04 · Ver el estado del curso de un vistazo — M · Mock up / MVP
**Como** docente, **quiero** ver al entrar un resumen con los indicadores clave del curso, **para** saber en segundos cómo va y dónde poner atención.
- **Dado** que entro a 1° Medio A Química, 2° semestre, **cuando** carga el resumen, **entonces** veo:
  - Promedio del curso en el semestre: 4,7.
  - Promedio anual del curso: 4,6.
  - N° de estudiantes por color del semáforo, con 9 en 🔴.
  - OA de conocimiento cubiertos sobre el total del año.
  - Días al cierre del semestre: 37.
- **Dado** que un indicador no tiene datos (por ejemplo, un semestre sin sumativas), **cuando** carga, **entonces** muestra "Sin notas" y no 0 ni 1,0.
- **Dado** que hay estudiantes en 🔴 o 🟡, **cuando** veo el resumen, **entonces** aparecen en una tabla tipo libro de clases (agregado por el PO el 27-10-2026):
  - Columnas: ID, nombre, apellido, estado, diagnóstico, una columna por cada evaluación del semestre, promedio semestral, promedio anual y motivos.
  - Las notas bajo 4,0 se destacan, y un ausente se muestra como "Ausente".
  - Al hacer clic en el nombre se abre la ficha del estudiante.

#### HU-05 · Ver los promedios semestral y anual — M · Mock up / MVP
**Como** docente, **quiero** ver el promedio del semestre en curso y el anual, por estudiante y por curso, **para** entender la situación actual sin perder la visión del año.
- **Dado** un estudiante con 3,4 en el 1° semestre y 4,2 en el 2°, **cuando** veo sus promedios, **entonces** el anual es 3,8.
- **Dado** que el 2° semestre está en curso, **cuando** veo el anual, **entonces** se calcula con el promedio parcial del 2° semestre y se indica "parcial".
- **Dado** E05 en el 2° semestre (F4 4,0 · F5 4,8 · S2 4,0 · S3 4,4), **cuando** veo su promedio semestral, **entonces** es 4,3: (4,0 + 4,8 + 4,2) / 3, donde 4,2 es el promedio de sus sumativas.
- **Dado** una diagnóstica con nota, **cuando** veo los promedios, **entonces** no influye en ellos y se muestra aparte con el rótulo "Diagnóstico".
- Regla: Constitución 6.1.

---

### EP3 — Semáforo de riesgo y alertas tempranas

#### HU-06 · Ver a cada estudiante con su color de riesgo — M · Mock up / MVP
**Como** docente, **quiero** ver la lista de estudiantes con un semáforo 🔴🟡🟢, **para** identificar rápido a quién apoyar.
- **Dado** el 2° semestre de 1° Medio A, **cuando** veo la lista, **entonces** hay 9 estudiantes en 🔴: los que tienen un promedio del semestre en curso menor a 4,0.
- **Dado** el estudiante E30 (anual 4,3, pero 3,7 en el semestre), **cuando** veo la lista, **entonces** aparece en 🔴.
- **Dado** cualquier estudiante, **cuando** veo su estado, **entonces** el color va acompañado de un ícono y un texto ("En riesgo", "Alerta", "Sin alerta"), no solo del color.
- **Dado** que el semestre aún no tiene evaluaciones con nota, **cuando** veo la lista, **entonces** nadie aparece en 🔴; solo puede haber 🟡 o 🟢.
- Regla: Constitución 6.3.

#### HU-07 · Entender el motivo de cada alerta — M · Mock up / MVP
**Como** docente, **quiero** ver por qué un estudiante está en 🔴 o 🟡, **para** decidir qué acción tomar.
- **Dado** un estudiante en 🟡 por dos formativas en nivel Insuficiente, **cuando** veo su fila, **entonces** leo, por ejemplo, "2 formativas Insuficiente (OA 18, OA 20)".
- **Dado** un estudiante que cumple varias señales, **cuando** veo su fila, **entonces** se listan todas.
- **Dado** un estudiante en 🔴, **cuando** veo su fila, **entonces** leo "Promedio semestral 3,4 (bajo 4,0)".

#### HU-08 · Filtrar y ordenar por riesgo — S · Mock up / MVP
**Como** docente, **quiero** filtrar la lista por color y ordenarla por promedio o por nombre, **para** enfocarme primero en los casos urgentes.
- **Dado** que filtro por 🟡, **cuando** se aplica el filtro, **entonces** veo solo los estudiantes con alerta temprana.
- **Dado** que la lista se muestra por defecto, **cuando** carga, **entonces** está ordenada 🔴 → 🟡 → 🟢 y, dentro de cada color, por promedio ascendente.
- PIE **no** es una opción de filtro ni de orden (Constitución 7).

#### HU-09 · Ver la marca PIE como contexto — S · Mock up / MVP
**Como** docente, **quiero** ver una marca discreta junto a los estudiantes que están en PIE, **para** considerar ese contexto al planificar apoyos.
- **Dado** un estudiante PIE, **cuando** veo su fila, **entonces** aparece una etiqueta "PIE" junto al nombre.
- **Dado** cualquier cálculo del semáforo, **cuando** se evalúa, **entonces** PIE no influye en el color.

---

### EP4 — Mapa de calor estudiantes × OA

#### HU-10 · Ver el logro de cada estudiante en cada OA — M · Mock up / MVP
**Como** docente, **quiero** ver una tabla de estudiantes (filas) por OA (columnas), coloreada según el % de logro, **para** ver qué OA reforzar con todo el curso y a quién apoyar en cada uno.
- **Dado** el mapa de calor, **cuando** carga, **entonces** cada celda muestra el % de logro acumulado del estudiante en ese OA, con un color según el nivel:
  - Insuficiente: menos de 60%.
  - Elemental: de 60% a 79,9%.
  - Adecuado: 80% o más.
- **Dado** el mapa de calor, **cuando** carga, **entonces** la primera columna muestra el semáforo del estudiante y la última fila muestra el promedio del curso por OA.
- **Dado** un OA que no ha sido evaluado (CN1M OA 19), **cuando** veo su columna, **entonces** aparece en gris con "Sin evaluar".
- **Dado** una celda sin datos por ausencia, **cuando** la veo, **entonces** se muestra vacía con la marca "Ausente", no como 0%.
- Las columnas usan los códigos oficiales (CN1M OA 17…20) y la descripción aparece al pasar el cursor.

#### HU-11 · Elegir qué evaluaciones considera el mapa — C · MVP
**Como** docente, **quiero** elegir si el mapa usa todas las evaluaciones, solo las formativas o solo las sumativas, **para** distinguir el progreso del resultado final.
- **Dado** que elijo "Solo formativas", **cuando** se aplica, **entonces** los % de logro se recalculan con esas evaluaciones.

---

### EP5 — Análisis de evaluaciones sumativas (P2)

#### HU-12 · Ver el resumen de una evaluación sumativa — M · Mock up / MVP
**Como** docente, **quiero** ver para cada sumativa el promedio del curso, la distribución de notas y la cantidad de aprobados y reprobados, **para** saber cómo le fue al curso.
- **Dado** que selecciono S1 "Prueba Unidad 1: reacciones químicas", **cuando** carga, **entonces** veo:
  - Promedio del curso: 4,6.
  - N° de reprobados (nota menor a 4,0): 10.
  - N° de aprobados.
  - N° de ausentes.
  - Distribución de notas en tramos (1,0–3,9 · 4,0–4,9 · 5,0–5,9 · 6,0–7,0).

#### HU-13 · Ver quiénes reprobaron — M · Mock up / MVP
**Como** docente, **quiero** ver la lista con nombres de quienes reprobaron cada sumativa, **para** planificar remediales y comunicarme con ellos.
- **Dado** S1, **cuando** abro "Reprobados", **entonces** veo los 10 estudiantes con nota menor a 4,0, su nota y el OA en que les fue peor, ordenados de menor a mayor nota.

#### HU-14 · Ver los mejores resultados — S · Mock up / MVP
**Como** docente, **quiero** ver a los estudiantes con mejores resultados en cada sumativa, **para** reconocerlos y considerarlos como tutores de sus pares.
- **Dado** una sumativa, **cuando** abro "Mejores resultados", **entonces** veo los 5 estudiantes con nota más alta, incluyendo los empates en el 5° lugar.

#### HU-15 · Ver las preguntas con menor logro — M · Mock up / MVP
**Como** docente, **quiero** ver las preguntas de cada sumativa ordenadas de menor a mayor % de acierto, **para** retroalimentar los contenidos más descendidos.
- **Dado** una sumativa, **cuando** abro "Preguntas", **entonces** veo cada pregunta con su número, el OA asociado y el % del curso que la respondió correctamente, ordenadas de menor a mayor.
- **Dado** una pregunta con menos de 50% de acierto, **cuando** la veo, **entonces** se destaca como "Crítica".
- **Dado** el mock up, **cuando** se muestran preguntas, **entonces** estas son ficticias y coherentes con los puntajes por OA de la planilla.

#### HU-16 · Ver el logro por OA dentro de una sumativa — S · Mock up / MVP
**Como** docente, **quiero** ver el % de logro del curso por cada OA medido en la sumativa, **para** saber qué OA reforzar.
- **Dado** S1 (mide CN1M OA 17 y OA 18), **cuando** carga, **entonces** veo una barra por OA con el % de logro del curso y su nivel.

---

### EP6 — Avance y cobertura curricular (P1)

#### HU-17 · Ver cuántos OA del año he trabajado y cubierto — M · Mock up / MVP
**Como** docente, **quiero** ver los OA de conocimiento del año y su estado, **para** saber cuánto he avanzado en el currículum.
- **Dado** Química 1° medio (CN1M OA 17–20), **cuando** veo el avance, **entonces** cada OA muestra uno de estos estados:
  - **Cubierto:** medido en al menos una sumativa.
  - **Trabajado:** medido solo en evaluaciones diagnósticas o formativas.
  - **Sin evaluar.**
- **Dado** el ejemplo, **cuando** veo el avance, **entonces** CN1M OA 19 aparece "Sin evaluar" y el resumen dice "3 de 4 OA cubiertos".
- **Dado** cualquier OA, **cuando** lo selecciono, **entonces** veo su texto oficial y en qué evaluaciones se midió, con su fecha.
- Las habilidades (OAH) **no** se muestran (Constitución 6.4).

#### HU-18 · Ver cuánto tiempo me queda para el cierre — M · Mock up / MVP
**Como** docente, **quiero** ver los días que faltan para el cierre de calificaciones del semestre, junto con los OA pendientes, **para** planificar lo que me falta evaluar.
- **Dado** la fecha 27-10-2026, **cuando** veo el avance, **entonces** leo "Quedan 37 días para el cierre del 2° semestre (03-12-2026)".
- **Dado** que hay OA sin evaluar y quedan 45 días o menos para el cierre, **cuando** veo el avance, **entonces** aparece la alerta "CN1M OA 19 aún no ha sido evaluado".

#### HU-19 · Ver la línea de tiempo de evaluaciones — S · Mock up / MVP
**Como** docente, **quiero** ver en una línea de tiempo las evaluaciones del año por tipo y por OA, junto con las fechas de cierre, **para** visualizar el ritmo de avance.
- **Dado** el ejemplo, **cuando** veo la línea de tiempo, **entonces** se ven:
  - Las 9 evaluaciones (D1, F1–F5 y S1–S3), con colores distintos para diagnóstica, formativa y sumativa.
  - Las fechas de cierre 30-06 y 03-12.
  - La fecha de hoy.

---

### EP7 — Ficha del estudiante

#### HU-20 · Ver la trayectoria de un estudiante — M · Mock up / MVP
**Como** docente, **quiero** abrir la ficha de un estudiante y ver todas sus evaluaciones, sus notas y su logro por OA, **para** preparar una conversación con él o con su apoderado.
- **Dado** que hago clic en un estudiante, **cuando** se abre la ficha, **entonces** veo:
  - Su semáforo y el motivo.
  - Sus promedios semestral y anual.
  - Su nota de **diagnóstico** (la línea base), para comparar su punto de partida con su promedio actual.
  - Un gráfico de la evolución de su % de logro por evaluación.
  - Su logro por OA comparado con el promedio del curso.
  - La marca PIE, si corresponde.
- **Dado** la ficha, **cuando** se muestra, **entonces** el RUT aparece enmascarado (`12.***.***-K`) o no aparece.

---

### EP8 — Sugerencias de actividades con IA (P3)

#### HU-21 · Ver ideas de actividades para los OA descendidos — C · Mock up (solo maqueta) / Futuro
**Como** docente, **quiero** pedir ideas de actividades para los OA con menor logro del curso, **para** ahorrar tiempo al planificar la remediación.
- **Dado** el mock up, **cuando** hago clic en "Sugerir actividades" en un OA descendido, **entonces** veo 2 o 3 actividades de ejemplo, escritas a mano y marcadas como "Vista previa".
- **Dado** la versión futura, **cuando** se envía la consulta a la IA, **entonces** solo viajan datos agregados y anónimos (por ejemplo, "CN1M OA 19, 45% de logro del curso") y nunca datos individuales (Constitución 7.5).

### EP9 — Planificación semanal de evaluaciones (P4)

#### HU-22 · Ver las evaluaciones de mi semana en formato calendario — W · Mock up (solo maqueta) / Futuro
**Como** docente, **quiero** ver un calendario semanal con las evaluaciones programadas en cada uno de mis cursos, **para** organizar mi semana y anticipar la corrección y la retroalimentación.
- **Dado** que abro "Mi semana", **cuando** carga, **entonces** veo los días de lunes a viernes con cada evaluación programada: curso, nombre, tipo (diagnóstica, formativa o sumativa) y OA que mide.
- **Dado** el calendario, **cuando** lo veo, **entonces** los tipos de evaluación se distinguen por color **y** por etiqueta de texto.
- **Dado** que puedo navegar entre semanas, **cuando** paso a la semana del cierre del semestre, **entonces** el día de cierre (30-06 o 03-12) aparece marcado.
- **Dado** el mock up, **cuando** abro "Mi semana", **entonces** veo un calendario de ejemplo marcado como "Próximamente".
- **Fuera de alcance:** actividades, reuniones y entrevistas con estudiantes o apoderados.

---

## 6. Requerimientos funcionales

| ID | Requerimiento | HU | Prioridad |
|---|---|---|---|
| RF-01 | Restringir los datos a los cursos y asignaturas del docente autenticado | HU-01 | M |
| RF-02 | Seleccionar curso, asignatura y semestre; por defecto, el semestre en curso | HU-02 | M |
| RF-03 | Leer los datos de la plataforma sin carga manual y mostrar la fecha de actualización | HU-03 | S |
| RF-04 | Mostrar un resumen con promedios, conteo del semáforo, cobertura de OA y días al cierre | HU-04 | M |
| RF-05 | Calcular el promedio semestral (ponderaciones reescaladas) y el anual (promedio simple de semestres) | HU-05 | M |
| RF-06 | Calcular el semáforo 🔴🟡🟢 según la Constitución 6.3, con umbrales configurables | HU-06 | M |
| RF-07 | Mostrar el motivo textual de cada alerta | HU-07 | M |
| RF-08 | Filtrar y ordenar la lista por color, promedio y nombre | HU-08 | S |
| RF-09 | Mostrar la marca PIE sin usarla en cálculos, filtros ni orden | HU-09 | S |
| RF-10 | Mostrar el mapa de calor estudiantes × OA por nivel de logro, con OA no evaluados y ausencias diferenciados | HU-10 | M |
| RF-11 | Filtrar el mapa de calor por tipo de evaluación | HU-11 | C |
| RF-12 | Mostrar el resumen por sumativa: promedio, distribución, aprobados, reprobados y ausentes | HU-12 | M |
| RF-13 | Listar los reprobados por sumativa, con nombre, nota y OA más débil | HU-13 | M |
| RF-14 | Listar el top 5 de resultados por sumativa, con empates | HU-14 | S |
| RF-15 | Listar las preguntas por % de acierto y destacar las que tienen menos de 50% | HU-15 | M |
| RF-16 | Mostrar el % de logro del curso por OA dentro de cada sumativa | HU-16 | S |
| RF-17 | Mostrar el estado de cada OA de conocimiento: Cubierto, Trabajado o Sin evaluar | HU-17 | M |
| RF-18 | Mostrar los días al cierre del semestre y alertar por OA sin evaluar | HU-18 | M |
| RF-19 | Mostrar la línea de tiempo de evaluaciones con fechas de cierre y la fecha de hoy | HU-19 | S |
| RF-20 | Mostrar la ficha del estudiante con trayectoria, promedios y logro por OA | HU-20 | M |
| RF-21 | Maqueta de sugerencias de actividades (solo visual) | HU-21 | C |
| RF-22 | Maqueta de calendario semanal de evaluaciones (solo visual) | HU-22 | W |

## 7. Requerimientos no funcionales

| ID | Categoría | Requerimiento |
|---|---|---|
| RNF-01 | Privacidad | El RUT nunca se muestra completo ni va en URLs, logs o exportaciones. Internamente se usa un ID seudónimo. |
| RNF-02 | Privacidad | PIE es visible solo para el docente del curso. No se usa en cálculos, filtros, rankings ni exportaciones sin control de acceso. |
| RNF-03 | Privacidad | Ningún dato individual de un estudiante se envía a servicios de IA externos. |
| RNF-04 | Accesibilidad | Cumple WCAG 2.1 AA. El color nunca es la única señal; hay texto o ícono junto a cada color. |
| RNF-05 | Usabilidad | Cualquier dato de un estudiante está a 3 clics o menos desde el resumen. |
| RNF-06 | Usabilidad | Diseñado para escritorio de 1366 px o más; se puede leer en tablet de 768 px. |
| RNF-07 | Localización | Interfaz en español de Chile, decimales con coma (4,5) y fechas dd-mm-aaaa. |
| RNF-08 | Rendimiento | El resumen de un curso de hasta 45 estudiantes carga en menos de 2 segundos (MVP). |
| RNF-09 | Configurabilidad | Los umbrales del semáforo, las fechas de cierre y las ponderaciones son parámetros, no valores fijos en el código. |
| RNF-10 | Exactitud | Las notas y promedios coinciden con las reglas de la Constitución 6. Las reglas de dominio tienen una cobertura de tests de 90% o más. |
| RNF-11 | Mock up | Un solo archivo HTML, sin servidor ni dependencias externas, solo con datos ficticios. |

## 8. Reglas de negocio (resumen)

Las reglas completas están en la [Constitución, sección 6](../../.specify/constitution.md).

| ID | Regla |
|---|---|
| RN-01 | Escala de notas de 1,0 a 7,0 con 60% de exigencia; se aprueba con 4,0. **Todas las evaluaciones llevan nota**; un ausente no tiene nota. |
| RN-02 | Niveles de logro: Insuficiente (menos de 60%), Elemental (de 60% a 79,9%) y Adecuado (80% o más). |
| RN-03 | Promedio semestral = promedio simple de [cada formativa, promedio de sumativas]. La diagnóstica no pesa (es la línea base). Las formativas pesan igual entre sí, y el promedio de sumativas pesa como una formativa. |
| RN-04 | Promedio anual: (semestre 1 + semestre 2) / 2, con cada semestre redondeado a 1 decimal. |
| RN-05 | 🔴 si el promedio del semestre en curso es menor a 4,0. 🟡 si hay alertas tempranas: última sumativa menor a 4,0; 2 o más Insuficiente en 2 meses; caída de 20 puntos o más; 2 o más ausencias. |
| RN-06 | Cierres de calificaciones: 30-06 (1° semestre) y 03-12 (2° semestre). |
| RN-07 | La cobertura curricular considera solo OA de conocimiento. Cubierto = medido en una sumativa; Trabajado = medido en cualquier evaluación. |
| RN-08 | Un estado "Ausente" deja el % de logro vacío; no cuenta como 0%. |

## 9. Trazabilidad: necesidad → historias

| Necesidad | Fuente | Historias |
|---|---|---|
| Contrastar los OA del año con los OA evaluados | Equipo | HU-17, HU-19 |
| Identificar estudiantes en riesgo de forma sencilla | Equipo | HU-06, HU-07, HU-08, HU-10 |
| P1: avance curricular y tiempo restante | Profesora | HU-17, HU-18, HU-19 |
| P2: reprobados, mejores resultados, promedio y preguntas descendidas | Profesora | HU-12, HU-13, HU-14, HU-15, HU-16 |
| P3: ideas de actividades con IA | Profesora | HU-21 |
| P4: mini planificación semanal (acotada a evaluaciones) | Profesora | HU-22 |
| Promedio semestral y anual | Equipo (27-10) | HU-04, HU-05 |

## 10. Supuestos del PO (validados el 27-10-2026)

| # | Supuesto | Dónde impacta |
|---|---|---|
| S1 | ✅ "Mejores resultados" = top 5 notas de la sumativa, con empates. | HU-14 |
| S2 | ✅ Una pregunta es "Crítica" si tiene menos de 50% de acierto. | HU-15 |
| S3 | ✅ La alerta de OA pendientes se activa cuando quedan 45 días o menos para el cierre. | HU-18 |
| S4 | ✅ El mapa de calor usa por defecto el % acumulado de **todas** las evaluaciones del semestre. | HU-10 |
| S5 | ✅ Un docente puede tener varios cursos y asignaturas; el mock up muestra uno solo (1° Medio A Química). | HU-02 |
| S6 | ✅ Cada pregunta de la plataforma está asociada a un solo OA. | HU-15, HU-16 |
| S7 | ✅ **Resuelto:** la diagnóstica no pesa; cada formativa pesa 1; el promedio de sumativas pesa 1 (Constitución v5.0.0). | HU-04, HU-05, HU-06 |

## 11. Glosario

| Término | Definición |
|---|---|
| OA | Objetivo de Aprendizaje del currículum MINEDUC (por ejemplo, CN1M OA 17). |
| OAH | Objetivo de Aprendizaje de Habilidad. Fuera del alcance de la cobertura curricular. |
| PIE | Programa de Integración Escolar. |
| Diagnóstica / Formativa / Sumativa | Tipos de evaluación. Todas llevan nota. La diagnóstica no pesa en el promedio (Constitución 6.1). |
| Diagnóstico (línea base) | Nota de la evaluación diagnóstica: el punto de partida del estudiante. En la interfaz se rotula "Diagnóstico". |
| % de logro | Puntaje obtenido ÷ puntaje máximo. |
| Cubierto / Trabajado | Estado de un OA: medido en una sumativa, o solo en otro tipo de evaluación. |
| Semestre en curso | Semestre al que pertenece la fecha de hoy según los cierres 30-06 y 03-12. |
