# Constitución del proyecto — Misión Dashboard

- **Versión:** 5.0.3
- **Ratificada:** 2026-10-27
- **Última modificación:** 2026-10-27

Este documento fija las reglas **inmutables** del proyecto. Toda especificación, plan, tarea o línea de código debe respetarlas. El *qué* de cada funcionalidad vive en `specs/`; este documento define el *cómo* y los límites.

- **Contexto de negocio:** [`contexto-proyecto.md`](../contexto-proyecto.md).
- **Si una especificación contradice esta Constitución, gana la Constitución.** Se detiene el trabajo y se consulta a una persona del equipo.

---

## 1. Principios

1. **El docente primero.** Cada pantalla debe responder una pregunta concreta del docente y llevarlo a una acción pedagógica. Si un indicador no lleva a una acción, no va.
2. **Simple antes que completo.** Se ve de un vistazo y se profundiza con un clic. Máximo 3 clics desde la vista inicial para llegar a cualquier dato de un estudiante.
3. **Privacidad por diseño.** Los datos de estudiantes son de menores de edad. Se muestra lo mínimo necesario, solo a quien corresponde.
4. **Datos de la plataforma, sin carga manual.** El dashboard **lee** datos que ya existen. Nunca le pide al docente subir o tipear información.
5. **Reglas de dominio explícitas y probadas.** Notas, niveles y semáforo se calculan con las fórmulas de la sección 6, en un solo módulo y con tests.
6. **Currículum oficial.** Los OA se identifican siempre con su código oficial MINEDUC (por ejemplo `CN1M OA 19`), nunca con numeraciones locales.

---

## 2. Stack tecnológico

| Capa | Fase mock up (actual) | Fase desarrollo |
|---|---|---|
| Frontend | Un archivo HTML autocontenido con CSS y JavaScript vanilla (ES2020), sin build | Node.js 20 LTS, React 18 + TypeScript 5 (modo `strict`), Vite 5 |
| Gráficos | SVG o CSS propio, sin librerías | Por decidir en el `plan.md` de la primera feature (**Ask First**) |
| Backend | — (datos ficticios embebidos como JSON en el HTML) | Python 3.12, FastAPI, Pydantic v2 |
| Datos | `data/*.xlsx` y `data/*.csv` de ejemplo | Base de datos de la plataforma (motor por definir, **Ask First**) |
| Tests | Revisión manual con la lista de la sección 5 | `pytest` (backend) y `Vitest` (frontend) |
| Calidad | — | `ruff` (lint y formato Python), `ESLint` + `Prettier` (TypeScript) |
| Repositorio | Git de Diana | Git de Diana |

---

## 3. Estructura del proyecto

```
mision-dashboard/
├── .specify/
│   └── constitution.md        # Este documento
├── contexto-proyecto.md       # Contexto de negocio y decisiones
├── inputs/                    # Material de referencia (fotos, feedback). SOLO LECTURA
├── data/                      # Datos de ejemplo FICTICIOS. Originales SOLO LECTURA
├── specs/
│   └── NNN-nombre-feature/    # Una carpeta por feature, ej: 001-mockup-docente
│       ├── spec.md            # Qué hace (lo escribe el equipo)
│       ├── plan.md            # Cómo se hará técnicamente
│       └── tasks.md           # Lista de tareas
├── mockup/                    # Mock ups HTML (fase actual)
│   └── scripts/               # Preparación de datos ficticios para el mock up
├── backend/                   # Python (fase desarrollo)
│   ├── src/dashboard/
│   │   ├── domain/            # Reglas de negocio puras: notas, niveles, semáforo
│   │   ├── data/              # Acceso a datos
│   │   └── api/               # Endpoints FastAPI
│   └── tests/
├── frontend/                  # Node/React (fase desarrollo)
│   ├── src/
│   └── tests/
└── docs/                      # Documentación técnica adicional
```

- Las reglas de dominio (sección 6) viven **solo** en `backend/src/dashboard/domain/`. En el mock up viven en un único bloque `// === Reglas de dominio ===` dentro del HTML.
- Los archivos derivados de `data/` (por ejemplo, JSON generado para el mock up) llevan el sufijo `_generado` y nunca reemplazan al original.

---

## 4. Comandos

| Tarea | Comando |
|---|---|
| Ver el mock up | Abrir `mockup/<archivo>.html` en el navegador (no requiere servidor) |
| Instalar backend | `cd backend && pip install -r requirements.txt` |
| Tests backend | `cd backend && pytest -v` |
| Lint backend | `cd backend && ruff check --fix . && ruff format .` |
| Levantar API | `cd backend && uvicorn dashboard.api.main:app --reload` |
| Instalar frontend | `cd frontend && npm install` |
| Frontend en desarrollo | `cd frontend && npm run dev` |
| Tests frontend | `cd frontend && npm test` |
| Lint frontend | `cd frontend && npm run lint -- --fix` |
| Build frontend | `cd frontend && npm run build` |

Antes de dar una tarea por terminada (fase desarrollo), deben pasar **los tests y el lint** de la capa modificada.

---

## 5. Estrategia de pruebas

- **Reglas de dominio:** cobertura mínima de **90%** con `pytest`. Casos obligatorios:
  - Nota: 0% → 1.0 · 30% → 2.5 · 60% → 4.0 · 80% → 5.5 · 100% → 7.0.
  - Nivel de logro: 59,9% → Insuficiente · 60% → Elemental · 79,9% → Elemental · 80% → Adecuado.
  - Ausente: el % de logro queda vacío y no cuenta como 0 en formativas.
  - Semáforo: al menos un caso por cada condición roja, amarilla y verde.
  - Semestre: 30-06 → 1° semestre · 01-07 → 2° semestre. Tiempo restante al 27-10-2026 → 37 días.
  - Ventana de 2 meses al 27-10-2026: una evaluación del 27-08-2026 entra; una del 26-08-2026 no.
  - Nota por evaluación: D1 de la planilla → promedio del curso 3,9 con 19 bajo 4,0. F2 de E05 (Ausente) → "Ausente", sin nota.
  - Promedio de sumativas: con S2 = 4,0 y S3 = 4,4 (pesos 30 y 35), el promedio es 4,2.
  - Promedio semestral, E05 2° semestre: F4 4,0 · F5 4,8 · sumativas 4,2 → (4,0 + 4,8 + 4,2) / 3 = 4,33 → **4,3**.
  - Promedio semestral, E05 1° semestre: D1 2,9 (no pesa) · F1 3,5 · F2 Ausente (no entra) · F3 3,0 · S1 3,4 → (3,5 + 3,0 + 3,4) / 3 = 3,3.
  - Sin formativas ni sumativas con nota en el semestre, se muestra "Sin notas" y no hay rojo.
  - Anual: semestre 1 = 3,4 y semestre 2 = 4,2 → anual 3,8. Semestre 1 = 3,9 y semestre 2 = 4,0 → 3,95 → anual 4,0.
- **Frontend:** tests de componentes para el semáforo y las tablas. Verificar que el color nunca es la única señal (ver 7.4).
- **Datos de test:** siempre ficticios, generados o tomados de `data/`.
- **Mock up:** antes de entregar, revisar manualmente que:
  - Las cifras coinciden con la planilla recalculada:
    - Nota promedio del curso en S1: 4,6.
    - Promedio del curso: 4,4 en el 1° semestre, 4,7 en el 2° y 4,6 anual.
    - 9 estudiantes en 🔴 según el 2° semestre.
    - 8 bajo 4,0 según el anual.
    - Semáforo validado por el PO: 2° semestre al 27-10-2026 → 9 🔴, 5 🟡, 21 🟢; 1° semestre al cierre → 9 🔴, 13 🟡, 13 🟢.
  - El OA 19 aparece como no evaluado.
  - La vista se lee bien en una pantalla de 1366 px de ancho.

---

## 6. Reglas de dominio

Son reglas fijas. Cambiarlas requiere modificar esta Constitución.

### 6.1 Escala de notas (Chile)
- Escala de **1,0 a 7,0**, con nota de aprobación **4,0** y **60% de exigencia**.
- Si % < 60%: `nota = 1 + (% / 0,6) × 3`.
- Si % ≥ 60%: `nota = 4 + ((% − 0,6) / 0,4) × 3`.
- Redondeo a **1 decimal**, con la regla de Excel `ROUND`: 0,05 sube.
- **Todas las evaluaciones llevan nota:** diagnósticas, formativas y sumativas. Todas usan la misma escala y muestran además su % de logro y su nivel.
  - Nota por evaluación: `% de logro = puntaje obtenido total / puntaje máximo total` de la evaluación, convertido a nota con la fórmula anterior.
  - Un estudiante **Ausente** no tiene nota en esa evaluación: se muestra "Ausente", nunca 1,0, y no cuenta en el promedio.
- **Qué cuenta en el promedio, según el tipo de evaluación:**
  - **Diagnóstica:** tiene nota, pero **no pesa** en ningún promedio. En la interfaz se muestra con el nombre **"Diagnóstico"**: es la línea base, una referencia del punto de partida del estudiante (v5.0.3).
  - **Formativa:** cada formativa es **un elemento** del promedio, y todas pesan igual.
  - **Sumativas:** su promedio cuenta como **un elemento más**, con el mismo peso que una formativa.
    - El promedio de sumativas usa las ponderaciones de cada sumativa del semestre (en el ejemplo: S2 30%, S3 35%), reescaladas para que sumen 100%.
    - Se redondea a 1 decimal antes de entrar al promedio semestral.
- **Se muestran siempre dos promedios:**
  - **Semestral:** `promedio simple de [nota F₁, …, nota Fₙ, promedio de sumativas]` del semestre en curso, redondeado a 1 decimal.
    - Ejemplo del 2° semestre en la planilla: `(F4 + F5 + prom(S2, S3)) / 3`.
    - Si el semestre aún no tiene sumativas, el promedio usa solo las formativas, y viceversa.
  - **Anual:** promedio simple de los dos semestres, `(semestre 1 + semestre 2) / 2`, redondeado a 1 decimal.
    - Cada promedio semestral se redondea a 1 decimal antes de promediar.
    - Mientras el 2° semestre está en curso, se usa su promedio parcial.
    - Si un semestre no tiene notas, el anual es igual al semestre que sí las tiene.
- Dentro de un semestre solo cuentan las evaluaciones **ya rendidas**. Una formativa con estado Ausente no entra al promedio.
- Las columnas de promedio de la planilla de ejemplo (hoja `Notas`) **no** son fuente de verdad: el dashboard siempre recalcula con estas reglas.
- Si el semestre en curso aún no tiene formativas ni sumativas con nota, el promedio semestral se muestra como "Sin notas" (nunca como 0 o 1,0). Una diagnóstica sola no genera promedio.

### 6.2 % de logro y nivel
- `% de logro = puntaje obtenido / puntaje máximo`.
- **Niveles:**
  - **Insuficiente:** menos de 60%.
  - **Elemental:** de 60% a 79,9%.
  - **Adecuado:** 80% o más.

### 6.3 Semáforo de riesgo (aprobado el 2026-10-27)

| Estado | Condición |
|---|---|
| 🔴 En riesgo | **Promedio del semestre en curso** (6.1) menor a 4,0. |
| 🟡 Alerta temprana | No está en rojo y cumple al menos una de estas señales: (a) última sumativa menor a 4,0; (b) 2 o más formativas o diagnósticas con nota menor a 4,0 (equivale a nivel Insuficiente) en los últimos 2 meses; (c) caída de 20 puntos porcentuales o más en el % de logro entre dos evaluaciones consecutivas; (d) 2 o más evaluaciones con estado Ausente. |
| 🟢 Sin alerta | No cumple ninguna de las condiciones anteriores. |

- **Aclaraciones** (v5.0.1):
  - (b) La ventana es **inclusiva**: entran las evaluaciones con fecha mayor o igual a hoy menos 2 meses. Al 27-10-2026 entra una del 27-08-2026.
  - (c) Las evaluaciones consecutivas se toman de la **secuencia del año**, ordenada por fecha, con todos los tipos. La comparación cruza el cambio de semestre. Cada caída cuenta para el semestre de la evaluación **más reciente** del par (v5.0.2).
  - (d) Las ausencias se cuentan en el **semestre** que se evalúa.
  - **Semestre cerrado:** el semáforo de un semestre ya cerrado se calcula a su fecha de cierre y se muestra como "Estado al cierre del semestre".
- Cada estado 🔴 o 🟡 muestra **el motivo** en texto.
- Los umbrales (4,0; 60%; 20 puntos; 2 meses; 2 ausencias) son **parámetros de configuración** con nombre, nunca números escritos directamente en el código.
- **Factores prohibidos en el semáforo:** PIE, género y cualquier dato que no sea de desempeño evaluativo.
- La asistencia no se usa, porque la plataforma no la tiene.

### 6.4 Calendario y cobertura curricular
- **Cierre de calificaciones:** 1° semestre al **30 de junio**; 2° semestre al **3 de diciembre**. Son las fechas límite para tener todas las calificaciones registradas.
- **Tiempo restante:** días corridos entre hoy y el cierre del semestre en curso.
- **Asignación de semestre:** cada evaluación pertenece al semestre según su fecha.
  - **1° semestre:** hasta el 30 de junio, inclusive.
  - **2° semestre:** del 1 de julio al 3 de diciembre.
- **Fechas configurables:** las fechas de cierre son parámetros de configuración por año, no fechas fijas en el código.
- **Cobertura curricular:** se calcula **solo con OA de conocimiento**. Los OA de habilidad (OAH) quedan fuera hasta que una spec diga lo contrario.
  - Un OA está **cubierto** si fue medido en al menos una evaluación sumativa.
  - Un OA está **trabajado** si fue medido en al menos una evaluación de cualquier tipo.

### 6.5 Formato de presentación (es-CL)
- **Decimales con coma:** nota `4,5` y porcentaje `62,5%`.
- **Fechas** en formato `dd-mm-aaaa`.
- **Interfaz en español de Chile.** Se usan los términos del sistema escolar: OA, PIE, sumativa, formativa, diagnóstica, apoderado.

---

## 7. Privacidad y seguridad

1. **RUT:**
   - Nunca se muestra completo en pantalla; se enmascara (`12.***.***-K`) o se usa el nombre.
   - Nunca va en URLs, logs, nombres de archivo ni mensajes de error.
   - Internamente se usa un ID seudónimo.
2. **PIE:**
   - Solo lo ve el docente del curso, como una marca discreta junto al nombre.
   - No se usa para filtrar, ordenar ni hacer rankings.
   - No es un factor de riesgo.
   - No se exporta sin control de acceso.
3. **Acceso:** cada docente ve **solo sus cursos y asignaturas**. La vista del equipo directivo (etapa 2) muestra datos agregados, salvo que se especifique otra cosa.
4. **Accesibilidad:** el color nunca es la única señal. Todo semáforo lleva además un ícono o texto. El contraste cumple WCAG 2.1 AA.
5. **IA externa (P3, ideas de actividades):** a un servicio de IA externo solo se envían **datos agregados y anonimizados** (por ejemplo, "OA 19, 45% de logro del curso"). Nunca nombres, RUT, PIE ni resultados individuales.
6. **Datos reales:** nunca se versionan. En el repositorio solo existen datos ficticios.

---

## 8. Estilo de código y flujo Git

### 8.1 Estilo
- **Idioma:**
  - Identificadores de código (variables, funciones, archivos de código) en **inglés**.
  - Textos de interfaz, documentación y specs en **español**.
  - Términos de dominio sin traducción natural se mantienen: `oa`, `pie`.
- **Python:** tipado completo y modelos Pydantic, sin `dict` sueltos en las APIs.
- **TypeScript:** `strict`, sin `any`.
- **Funciones de dominio puras:** sin acceso a datos ni efectos secundarios.

Ejemplo de estilo esperado:

```python
from decimal import Decimal, ROUND_HALF_UP

PASSING_THRESHOLD = Decimal("0.6")  # 60% de exigencia


def score_to_grade(achievement: Decimal) -> Decimal:
    """Convierte % de logro (0–1) a nota chilena 1,0–7,0 con 60% de exigencia."""
    if achievement < PASSING_THRESHOLD:
        grade = 1 + achievement / PASSING_THRESHOLD * 3
    else:
        grade = 4 + (achievement - PASSING_THRESHOLD) / (1 - PASSING_THRESHOLD) * 3
    return grade.quantize(Decimal("0.1"), rounding=ROUND_HALF_UP)
```

### 8.2 Git
- **Ramas:** `main` (estable) y `feature/NNN-nombre-corto`, donde NNN es el número de la carpeta en `specs/`.
- **Commits:** Conventional Commits en español, por ejemplo `feat(semaforo): agrega alerta por caída de logro` o `fix(notas): corrige redondeo en 0,05`.
- **Pull Requests:**
  - Enlazan su `spec.md`.
  - Describen qué se probó.
  - Requieren la revisión de una persona antes de pasar a `main`.
  - El revisor valida esta Constitución (sección 10).

---

## 9. Límites para el agente de IA

### ✅ Siempre (Always Do)
- Leer esta Constitución y `contexto-proyecto.md` antes de planificar o implementar.
- Usar los códigos oficiales de OA y las fórmulas de la sección 6.
- Mostrar el motivo de cada alerta del semáforo.
- Usar solo datos ficticios en el mock up, tests y ejemplos.
- Escribir o actualizar tests cuando se toca una regla de dominio.
- Mantener la estructura de carpetas de la sección 3.
- Registrar en `contexto-proyecto.md` toda decisión nueva tomada con el equipo.

### ❓ Preguntar primero (Ask First)
- Agregar una dependencia o librería nueva (incluidas las de gráficos).
- Cambiar umbrales, ponderaciones o cualquier regla de la sección 6.
- Crear una vista o indicador que no esté en una `spec.md`.
- Elegir o cambiar el motor de base de datos o el esquema de datos.
- Integrar un servicio externo, incluida la IA para P3.
- Mostrar un dato nuevo de estudiantes que no sea desempeño evaluativo.
- Modificar archivos en `inputs/` o los originales en `data/`.

### ⛔ Nunca (Never Do)
- Versionar datos reales de estudiantes, RUT, credenciales, API keys o secretos.
- Mostrar el RUT completo o ponerlo en URLs o logs.
- Usar PIE, género u otro dato personal como factor de riesgo, filtro o ranking.
- Enviar datos individuales de estudiantes a servicios de IA externos.
- Escribir umbrales o fórmulas de dominio fuera del módulo de dominio.
- Pedir al docente que cargue datos manualmente.
- Borrar un test que falla, o hacer `push --force` a `main`, sin aprobación explícita.

---

## 10. Gobernanza

- **Autoría:** el equipo humano escribe, debate y aprueba esta Constitución. El agente puede **proponer** cambios, pero no aplicarlos sin aprobación.
- **Versionado semántico** del documento:
  - **MAJOR:** se cambia o elimina un principio o regla de dominio.
  - **MINOR:** se agrega una regla o sección.
  - **PATCH:** se aclara la redacción.
- **Revisión de código:** cada PR se valida contra esta lista:
  - ¿Respeta los límites de la sección 9?
  - ¿Usa las fórmulas de la sección 6?
  - ¿Cumple la privacidad de la sección 7?
  - ¿Respeta la estructura de la sección 3?
- **Ambigüedad:** si el agente incumple una regla de forma repetida, se reescribe la regla con más precisión en vez de corregir caso a caso.

### Historial
| Versión | Fecha | Cambio |
|---|---|---|
| 1.0.0 | 2026-10-27 | Versión inicial. Incluye el semáforo de riesgo aprobado. |
| 1.1.0 | 2026-10-27 | Agrega 6.4: fechas de cierre semestral (30-06 y 03-12) y cobertura solo con OA de conocimiento. |
| 2.0.0 | 2026-10-27 | Se muestran dos promedios, semestral y anual (6.1). El semáforo 🔴 pasa a usar el promedio del semestre en curso (6.3); cambia una regla de dominio. |
| 3.0.0 | 2026-10-27 | El promedio anual pasa a ser el promedio simple de los dos semestres (6.1), en vez de las ponderaciones por evaluación. Las columnas de promedio de la planilla dejan de ser fuente de verdad. |
| 4.0.0 | 2026-10-27 | **Todas las evaluaciones llevan nota** (diagnósticas, formativas y sumativas) y todas entran al promedio semestral según su ponderación (6.1). Los ausentes no tienen nota. Ponderación por defecto de diagnósticas y formativas: pendiente del PO. |
| 5.0.0 | 2026-10-27 | Ponderación definida: la diagnóstica no pesa (línea base); cada formativa pesa 1; el promedio de sumativas pesa como una formativa (6.1). |
| 5.0.1 | 2026-10-27 | Aclaraciones del semáforo (6.3), aprobadas por el PO en el plan 001 (D3–D6): ventana inclusiva, secuencia anual para la caída, ausencias por semestre y semáforo de un semestre cerrado. Se agrega `mockup/scripts/` a la estructura (D7). |
| 5.0.2 | 2026-10-27 | Aclaración de 6.3 (c): una caída cuenta para el semestre de la evaluación más reciente del par. Se agregan como cifras de control los conteos del semáforo validados por el PO (sección 5). |
| 5.0.3 | 2026-10-27 | En la interfaz, la nota de la diagnóstica se rotula "Diagnóstico" en vez de "Línea base" (6.1), a pedido del PO. Cambia solo el rótulo. |
