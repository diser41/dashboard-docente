# Tareas 001 — Mock up del dashboard docente

| | |
|---|---|
| **Estado** | ✅ Terminado: mock up listo para validar con docentes (27-10-2026) |
| **Versión** | 1.0 |
| **Fecha** | 2026-10-27 |
| **Rige** | [Constitución v5.0.2](../../.specify/constitution.md) |
| **Implementa** | [Plan 001 v1.0](plan.md) · [Spec 001 v1.0](spec.md) |

---

## Cómo leer esta lista

- **Formato:** `T000 · Título — HU / sección del plan`. Cada tarea indica qué se hace, de qué tareas depende y cuándo está terminada.
- **Marca [P]:** la tarea se puede hacer en paralelo con la anterior, porque toca otro archivo. Las tareas sin [P] van en orden: casi todas editan el mismo archivo `mockup/dashboard-docente.html`.
- **Pruebas primero:** cada tarea de dominio agrega sus casos al modo `?verificar` **antes** de escribir la función. La tarea termina cuando esos casos pasan.
- **Una tarea está terminada cuando:**
  - Se cumple su criterio de aceptación.
  - `?verificar` sigue todo en ✅.
  - La consola del navegador no muestra errores.
- **Git:** cuando el proyecto esté en el repositorio de Diana, se trabaja en la rama `feature/001-dashboard-docente`. Un commit por tarea, con Conventional Commits en español, por ejemplo `feat(semaforo): agrega alerta por caída de logro`.

---

## Fase 0 · Preparación de datos

### ✅ T001 · Crear la estructura del mock up — plan §4
- **Hacer:** crear `mockup/` y `mockup/scripts/`.
- **Depende de:** —
- **Terminado cuando:** las carpetas existen, igual que en la Constitución 3.

### ✅ T002 · Script de extracción de la planilla — plan §4, §5
- **Hacer:** escribir `mockup/scripts/extract-data.ps1`. El script:
  - Descomprime el `.xlsx` en una carpeta temporal y lee las hojas Estudiantes, Evaluaciones y Resultados, más el CSV de OA MINEDUC.
  - Convierte OA1–OA5 a códigos oficiales: OA3 y OA4 se suman en CN1M OA 20, y OA5 pasa a CN1M OAH d, f como habilidad.
  - Escribe `data/mockup-data_generado.json` con el modelo del plan §5.
  - Recibe las rutas como parámetros y **no** modifica los originales de `data/`.
- **Depende de:** T001
- **Terminado cuando:** el JSON tiene:
  - 35 estudiantes, sin campos de género ni asistencia.
  - 9 evaluaciones, con las fechas y ponderaciones de la planilla (S1 35, S2 30, S3 35).
  - Las 525 filas de la planilla, convertidas a OA oficiales: quedan 490 resultados, porque OA3 y OA4 se suman en CN1M OA 20 dentro de D1. Hay 8 ausencias.
  - 4 OA de conocimiento, incluido CN1M OA 19 sin resultados.
  - El script imprime un resumen con esos conteos y termina con error si alguno no coincide.

### ✅ T003 · Simulación de preguntas de las sumativas — plan §7 · HU-15, HU-16
- **Hacer:** agregar al script la generación de preguntas y respuestas de S1, S2 y S3:
  - Una pregunta de 1 punto por cada punto máximo del OA.
  - Dificultad con generador pseudoaleatorio de semilla fija.
  - Aciertos asignados según el puntaje del estudiante en el OA; los ausentes no tienen respuestas.
- **Depende de:** T002
- **Terminado cuando:**
  - Para cada estudiante, sumativa y OA, los aciertos son **iguales** al puntaje de la planilla (el script lo comprueba).
  - Dos ejecuciones seguidas generan un JSON idéntico.

### ✅ T004 · Esqueleto del HTML y carga de datos — plan §4
- **Hacer:**
  - Crear `mockup/dashboard-docente.html` con los 6 bloques del plan §4 (Configuración, Reglas de dominio, Datos, Formato es-CL, Vistas, Verificación) y los marcadores `<!-- DATA:BEGIN -->` y `<!-- DATA:END -->`.
  - Hacer que el script inserte el JSON entre los marcadores.
  - En el bloque Datos, leer el JSON y armar índices por estudiante, evaluación y OA.
- **Depende de:** T003
- **Terminado cuando:**
  - El HTML se abre con doble clic, sin conexión.
  - La consola muestra "35 estudiantes · 9 evaluaciones".
  - No hay solicitudes de red en la pestaña de red del navegador.

---

## Fase 1 · Reglas de dominio y verificación

### ✅ T005 · Modo `?verificar` — plan §10.1
- **Hacer:**
  - Crear el arnés de casos: una función `check(nombre, obtenido, esperado)`.
  - Mostrar un panel ✅/❌ cuando la URL tenga `?verificar`, con el detalle también en la consola.
- **Depende de:** T004
- **Terminado cuando:** un caso de ejemplo en ✅ y otro forzado en ❌ se muestran bien, y el caso forzado se elimina.

### ✅ T006 · Configuración — plan §6.3
- **Hacer:** declarar los 12 parámetros del plan §6.3 con nombre, en el bloque Configuración.
- **Depende de:** T004
- **Terminado cuando:** fuera del bloque Configuración no aparece ningún número de umbral (4,0; 0,6; 0,8; 20; 2; 45; 0,5; 5) ni ninguna fecha de cierre.

### ✅ T007 · Nota y nivel de logro — Constitución 6.1, 6.2 · plan §6.1
- **Hacer:**
  - Escribir `roundHalfUp` para enteros.
  - Escribir `scoreToGrade(score, max)`, que devuelve la nota en décimas.
  - Escribir `achievementLevel(score, max)`.
- **Depende de:** T005, T006
- **Casos:**
  - 0% → 1,0 · 30% → 2,5 · 60% → 4,0 · 80% → 5,5 · 100% → 7,0.
  - 59,9% → Insuficiente · 60% → Elemental · 79,9% → Elemental · 80% → Adecuado.

### ✅ T008 · Semestre y días al cierre — Constitución 6.4
- **Hacer:** escribir `semesterOf(date)` y `daysToClose(refDate)`.
- **Depende de:** T006
- **Casos:**
  - 30-06-2026 → 1° semestre · 01-07-2026 → 2° semestre.
  - Al 27-10-2026 quedan 37 días.
  - Las 9 evaluaciones caen en el semestre del contexto 4.1: D1, F1, F2, S1 y F3 en el 1°; S2, F4, F5 y S3 en el 2°.

### ✅ T009 · Nota por evaluación y línea base — Constitución 6.1 · HU-05
- **Hacer:** escribir `evaluationGrade(studentId, evalId)` (con el puntaje total de la evaluación, incluida la habilidad) y `baseline(studentId)`.
- **Depende de:** T007
- **Casos:**
  - D1: promedio del curso 3,9, con 19 de 35 bajo 4,0.
  - S1: promedio del curso 4,6, con 10 bajo 4,0.
  - F2 de E05 → `null` y se muestra "Ausente".
  - Promedio y conteo bajo 4,0 de las 9 evaluaciones, iguales a la tabla del contexto 5.7.

### ✅ T010 · Promedios semestral y anual — Constitución 6.1 · HU-04, HU-05
- **Hacer:** escribir `summativeAverage`, `semesterAverage` y `annualAverage` (con la marca `partial`).
- **Depende de:** T008, T009
- **Casos:**
  - Sumativas 4,0 y 4,4 con pesos 30 y 35 → 4,2.
  - E05, 2° semestre → 4,3.
  - E05, 1° semestre → 3,3 (F2 Ausente y D1 no pesan).
  - Anual: 3,4 y 4,2 → 3,8 · 3,9 y 4,0 → 4,0.
  - Un semestre sin notas → `null` ("Sin notas").
  - Casos del contexto 5.7: E05, E18, E22 y E30, con sus 4 valores (línea base, 1° semestre, 2° semestre y anual).
  - Curso: 4,4 (1° semestre), 4,7 (2° semestre) y 4,6 (anual).
  - 8 estudiantes bajo 4,0 anual: E05, E07, E09, E17, E22, E31, E32 y E33.

### ✅ T011 · Semáforo con motivos — Constitución 6.3 (v5.0.1) · HU-06, HU-07
- **Hacer:** escribir `riskStatus(studentId, semester, refDate)`, que devuelve `{ status, reasons }`. Debe:
  - Usar la ventana inclusiva (D3), la secuencia anual para la caída (D4) y las ausencias del semestre (D5).
  - Para un semestre cerrado, usar su fecha de cierre (D6).
  - Redactar los motivos en texto, por ejemplo "Promedio semestral 3,4 (bajo 4,0)" o "2 formativas Insuficiente (CN1M OA 20)".
- **Depende de:** T010
- **Casos:**
  - 2° semestre: 9 en 🔴 (E07, E09, E17, E18, E21, E30, E31, E32 y E33), con E30 en 🔴.
  - Al menos un caso que active cada señal (a), (b), (c) y (d), y uno 🟢.
  - Borde de la ventana: 27-08 entra y 26-08 no.
  - Cambiar `pie` de un estudiante no cambia su color.
  - Un semestre sin notas no tiene nadie en 🔴.

### ✅ T012 · Cobertura curricular — Constitución 6.4 · HU-17
- **Hacer:** escribir `objectiveCoverage(code)` y el % de logro acumulado por estudiante y OA. Las habilidades quedan fuera.
- **Depende de:** T009
- **Casos:**
  - CN1M OA 17, 18 y 20 → Cubierto · CN1M OA 19 → Sin evaluar.
  - Resumen: "3 de 4 OA cubiertos".
  - Ninguna OAH aparece en la cobertura.

### ✅ T013 · Formato es-CL — Constitución 6.5 · plan §9
- **Hacer:** escribir `formatGrade`, `formatPercent`, `formatDate` y las etiquetas de nivel y semáforo.
- **Depende de:** T007
- **Casos:**
  - 46 → "4,6" · 0,625 → "62,5%" · 2026-10-27 → "27-10-2026".
  - `null` → "Sin notas" · Ausente → "Ausente".

### ✅ T014 · Cifras de 🟡 como control — plan §12
- **Hacer:**
  - Calcular el conteo de 🟡 y 🟢 del 2° semestre al 27-10-2026, y del 1° semestre al 30-06.
  - Mostrárselo al PO para que lo valide.
  - Una vez validado, agregarlo a `?verificar` y al contexto 5.4.
- **Depende de:** T011
- **Terminado cuando:** el PO confirma los conteos y estos quedan como casos de control.
- **Resultado validado por el PO (27-10-2026)** y agregado a `?verificar` y a la Constitución 5 (v5.0.2):

  | Semestre | 🔴 | 🟡 | 🟢 | Señales que generan 🟡 |
  |---|---|---|---|---|
  | 2° (al 27-10-2026) | 9 | 5 | 21 | Las 5 por caída de 20 puntos o más (E01, E15, E22, E25, E34) |
  | 1° (al cierre, 30-06) | 9 | 13 | 13 | 11 por caída, 1 por última sumativa y 1 por ambas |

  - En el 2° semestre, 4 de las 5 alertas vienen del par F5 → S3, y 3 de las 5 caen justo en el límite de 20 puntos.
  - Ningún estudiante tiene 2 o más ausencias en un mismo semestre.
  - La señal (b) se cumple solo en estudiantes que ya están en 🔴.

---

## Fase 2 · Vistas

### ✅ T015 · Encabezado y pestañas — plan §8 · HU-02
- **Hacer:**
  - Encabezado fijo con selector de curso (una sola opción), selector de semestre (por defecto, el 2°) y la leyenda "Datos de ejemplo al 27-10-2026".
  - Las 6 pestañas.
  - Al cambiar de semestre se vuelve a dibujar la pestaña activa.
  - En el 1° semestre se muestra "Estado al cierre del 1° semestre" (D6).
- **Depende de:** T013
- **Terminado cuando:**
  - Cambiar de semestre actualiza todas las cifras visibles.
  - Las pestañas se pueden usar con el teclado.

### ✅ T016 · Ficha del estudiante — plan §8 · HU-20
- **Hacer:** panel lateral que se abre desde cualquier nombre. Muestra:
  - El semáforo y sus motivos.
  - Los promedios semestral y anual (con "parcial") y la línea base.
  - La evolución del % de logro en un gráfico SVG.
  - El logro por OA frente al curso.
  - La etiqueta PIE.
  - Sin RUT.
- **Depende de:** T011, T012, T015
- **Terminado cuando:**
  - La ficha de E30 muestra línea base 4,9, 1° semestre 4,9, 2° semestre 3,7, anual 4,3 y estado 🔴.
  - La ficha se cierra con Esc.

### ✅ T017 · Resumen — HU-04, HU-05, HU-18
- **Cambio del PO (27-10-2026):** la lista "Requieren atención" pasa a ser una tabla tipo libro de clases (spec v1.1, HU-04).
- **Hacer:** tarjetas con:
  - El promedio del semestre y el promedio anual (con "parcial").
  - El conteo 🔴🟡🟢.
  - Los OA cubiertos sobre el total.
  - Los días al cierre.
  - La alerta "CN1M OA 19 aún no ha sido evaluado", que se muestra solo con 45 días o menos al cierre.
- **Depende de:** T015
- **Terminado cuando:** el 2° semestre muestra 4,7 · 4,6 (parcial) · 9 en 🔴 · 3 de 4 · 37 días, y la alerta de OA 19 aparece.

### ✅ T018 · Lista de estudiantes — HU-06 a HU-09
- **Hacer:** tabla con:
  - Semáforo (ícono y texto) y motivos.
  - Línea base, promedio semestral y promedio anual.
  - Etiqueta PIE.
  - Filtro por color, y orden por color, promedio o nombre.
  - Por defecto, el orden es 🔴 → 🟡 → 🟢 y, dentro de cada color, por promedio ascendente.
- **Depende de:** T016
- **Terminado cuando:**
  - El filtro 🔴 muestra 9 estudiantes.
  - PIE no aparece como filtro ni como criterio de orden.
  - Al hacer clic en un nombre, se abre la ficha.

### ✅ T019 · Mapa de calor — HU-10 · D1
- **Hacer:** matriz de estudiantes × CN1M OA 17–20. Debe:
  - Mostrar en cada celda el % de logro y el nivel (con color y texto).
  - Llevar el semáforo en la primera columna y el promedio del curso en la última fila.
  - Diferenciar "No evaluado en este semestre", "Sin evaluar en el año" y "Ausente".
  - Mostrar el texto oficial del OA al pasar el cursor.
- **Depende de:** T018
- **Terminado cuando:**
  - En el 2° semestre, OA 17 y 18 aparecen como "No evaluado en este semestre" y OA 19 como "Sin evaluar en el año".
  - No hay columna de habilidades.

### ✅ T020 · Sumativas: resumen, reprobados y mejores — HU-12 a HU-14
- **Hacer:**
  - Selector S1, S2 y S3.
  - Promedio, aprobados, reprobados y ausentes.
  - Distribución de notas en 4 tramos.
  - Lista de reprobados, con nota y OA más débil.
  - Top 5 con empates.
- **Depende de:** T016
- **Terminado cuando:**
  - S1 muestra promedio 4,6, 10 reprobados y 0 ausentes.
  - La lista de reprobados está ordenada de menor a mayor nota.
  - El top 5 incluye a todos los empatados en el 5° lugar.

### ✅ T021 · Sumativas: preguntas y logro por OA — HU-15, HU-16 · D2
- **Hacer:**
  - Preguntas ordenadas por % de acierto, con número, OA y % de acierto.
  - Marca "Crítica" bajo 50%.
  - Barras de logro por OA, con la habilidad etiquetada "Habilidad".
  - La leyenda "Preguntas de ejemplo".
- **Depende de:** T020
- **Terminado cuando:**
  - El % de logro por OA que muestran las barras es igual al que resulta de la planilla.
  - S3 muestra CN1M OA 20 y la habilidad etiquetada.

### ✅ T022 · Avance curricular — HU-17, HU-18
- **Hacer:**
  - Estado de los 4 OA de conocimiento.
  - Al hacer clic en un OA: su texto oficial y las evaluaciones en que se midió, con su fecha.
  - Los días al cierre y la alerta de OA pendientes.
- **Depende de:** T015
- **Terminado cuando:**
  - Se muestra "3 de 4 OA cubiertos" y "Quedan 37 días para el cierre del 2° semestre (03-12-2026)".
  - CN1M OA 19 aparece "Sin evaluar".

### ✅ T023 · Línea de tiempo — HU-19
- **Hacer:** línea de tiempo en SVG con las 9 evaluaciones (color y etiqueta por tipo), los cierres 30-06 y 03-12 y la marca "Hoy".
- **Depende de:** T022
- **Terminado cuando:** se ven las 9 evaluaciones en su fecha y se distinguen por tipo sin depender del color.

### ✅ T024 · Maqueta de ideas de actividades — HU-21
- **Hacer:** botón "Sugerir actividades" en los OA descendidos, que abre 2 o 3 actividades escritas a mano con la marca "Vista previa".
- **Depende de:** T022
- **Terminado cuando:**
  - La maqueta no hace ninguna llamada de red.
  - La marca "Vista previa" es visible.

### ✅ T025 · Maqueta de "Mi semana" — HU-22
- **Hacer:** calendario de lunes a viernes, con evaluaciones de ejemplo (tipo por color y etiqueta) y el cierre marcado, bajo la banda "Próximamente".
- **Depende de:** T015
- **Terminado cuando:**
  - Solo aparecen evaluaciones; no hay actividades, reuniones ni entrevistas.
  - La banda "Próximamente" es visible.

---

## Fase 3 · Cierre

### ✅ T026 · Accesibilidad y tamaños de pantalla — RNF-04, RNF-06
- **Hacer:** revisar el contraste (AA), el texto junto a cada color, el foco del teclado y el diseño a 1366 px y a 768 px.
- **Depende de:** T017 a T025
- **Terminado cuando:**
  - No hay scroll horizontal en el Resumen a 768 px.
  - Ningún estado depende solo del color.
- **Resultado:**
  - Contraste medido en modo claro y oscuro: todos los textos tienen 4,5:1 o más. Las barras y los bordes de controles quedaron en 3:1 o más, después de oscurecer dos colores de barra y agregar el token `--control-border`.
  - Teclado: Tab recorre los controles, las flechas cambian de pestaña, Enter abre la ficha y Esc la cierra devolviendo el foco. El foco es visible.
  - Sin scroll horizontal de página a 768 px en ninguna pestaña. Todo estado lleva texto; los gráficos y barras tienen descripción accesible.

### ✅ T027 · Revisión final y capturas — plan §10
- **Hacer:**
  - Correr `?verificar`.
  - Completar la lista manual del plan §10.2.
  - Tomar capturas de cada pestaña a 1366 px y guardarlas en `docs/capturas/`.
- **Depende de:** T026
- **Terminado cuando:**
  - Todo `?verificar` está en ✅.
  - La lista manual está completa.
  - Las capturas están guardadas.
- **Resultado:** `?verificar` en 76 de 76; lista manual del plan §10.2 completa. Capturas en `docs/capturas/`: 6 pestañas a 1366 px, tomadas con Edge sin ventana abriendo el archivo directamente, y la ficha del estudiante (E30), tomada con el navegador de la app. Para capturar cada pestaña, la página acepta su nombre en la dirección (por ejemplo `#heatmap`).

### ✅ T028 · Actualizar la documentación
- **Hacer:** registrar en `contexto-proyecto.md` y en la memoria del export:
  - Lo construido.
  - Las cifras de 🟡 validadas.
  - Las desviaciones del plan, si las hubo.
- **Depende de:** T027
- **Terminado cuando:** los documentos reflejan el estado del mock up y queda listo para la validación con docentes.

---

## Resumen de dependencias

```
T001 → T002 → T003 → T004 ─┬─ T005 ─┐
                           └─ T006 ─┴─ T007 ─┬─ T009 ─┬─ T010 → T011 → T014
                                     T008 ───┘        └─ T012
                                             T007 → T013 → T015
T015 → T016 (requiere T011, T012) → T018 → T019
                                  → T020 → T021
T015 → T017 · T022 → T023, T024 · T025
T017…T025 → T026 → T027 → T028
```

## Trazabilidad: historias → tareas

| HU | Tareas |
|---|---|
| HU-02 | T015 |
| HU-04, HU-05 | T009, T010, T017 |
| HU-06, HU-07 | T011, T018 |
| HU-08, HU-09 | T018 |
| HU-10 | T012, T019 |
| HU-12 a HU-14 | T020 |
| HU-15, HU-16 | T003, T021 |
| HU-17, HU-18 | T008, T012, T017, T022 |
| HU-19 | T023 |
| HU-20 | T016 |
| HU-21 | T024 |
| HU-22 | T025 |
| HU-01, HU-03, HU-11 | Fuera del mock up (MVP) |
