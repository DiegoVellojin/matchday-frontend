# ⚽ MatchDay App

> **"La élite del deporte amateur, profesionalizada en la palma de tu mano."**

Proyecto de ingeniería de software de alto impacto que permite a capitanes y jugadores gestionar, descubrir y organizar encuentros deportivos amateur (Fútbol, Padel, Tenis, Basket) con pagos y resultados en tiempo real. Esta aplicación no es solo una plataforma funcional, sino una demostración avanzada de **Clean Architecture (4 Capas)**, **Inyección de Dependencias**, y **Programación Funcional**.

<p align="center">
   <img src="https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png" alt="Logo-Flutter" width="300">
   <br>
   <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter Version" />
   <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart Version" />
   <img src="https://img.shields.io/badge/Architecture-Clean%20(4%20Layers)-success?style=for-the-badge" alt="Clean Architecture" />
   <img src="https://img.shields.io/badge/UI-Premium%20Responsive-black?style=for-the-badge" alt="Premium UI" />
</p>

## 🏛️ Arquitectura de Software: Clean Architecture Estricta

Este proyecto representa una implementación canónica y rigurosa de **Clean Architecture**. Dividir el software en cuatro capas concéntricas obedece a principios S.O.L.I.D. y Separación de Preocupaciones (SoC), garantizando un ciclo de vida saludable, testable y escalable a largo plazo.

### ¿Por qué esta separación?
1.  **Aislamiento del Framework:** Flutter es tratado puramente como una herramienta de UI. La lógica de negocio (`Domain`) es agnóstica a Flutter. Esto facilita enormemente el mantenimiento y las pruebas unitarias.
2.  **Manejo de Errores Tipado:** Gracias a la Programación Funcional, evitamos los bloques `try-catch` dispersos. El compilador nos obliga a manejar explícitamente los casos de éxito y de fallo.
3.  **Desacoplamiento:** Los cambios en una API o en la base de datos no afectan a la UI ni a la lógica core.

### Desglose de Capas

#### 1. Domain (Dominio) - *El Corazón Inmutable*
Aquí residen las reglas absolutas del negocio de MatchDay.
*   **`entities/`**: Modelos puros que utilizan `Equatable` para garantizar integridad por valor (ej. `MatchEntity`).
*   **`repositories/` (Interfaces)**: Definición de contratos bajo el **Principio de Inversión de Dependencias (DIP)**. El dominio dicta las reglas, y las capas externas deben cumplirlas.

#### 2. Application (Aplicación) - *El Orquestador*
La lógica transaccional de la app.
*   **`usecases/`**: Encapsulan acciones atómicas (Single Responsibility Principle). Ejemplo: `AcceptEncounterUseCase`. Retornan un `Either<Failure, Type>` forzando un manejo de errores determinista.

#### 3. Infrastructure (Infraestructura) - *El Mundo Exterior*
Capa técnica que lidia con HTTP, Firebase y Bases de Datos.
*   **`datasources/`**: Comunicación cruda (API con Dio, Firebase).
*   **`repositories/` (Implementación)**: Actúan como traductores. Toman los JSONs de la API y los convierten en Entidades del Dominio, protegiendo a la app de los detalles de implementación del backend.

#### 4. Presentation (Presentación) - *La Interfaz Visual*
Gobernada por el patrón **BLoC (Business Logic Component)**.
*   La UI es **totalmente reactiva y pasiva**. Solo escucha estados del BLoC (`Loading`, `Loaded`, `Error`) y reacciona visualmente. No toma decisiones de negocio.
*   Uso de `GlobalKey<FormState>` para validaciones robustas de entrada en tiempo real.

---

## 🛠️ Stack Tecnológico

Selección de herramientas de nivel empresarial (definidas en `pubspec.yaml`):

### Arquitectura & Estado
* **`flutter_bloc`**: Gestión de estado reactiva basada en eventos.
* **`get_it` & `injectable`**: Inyección de dependencias escalable y centralizada (Service Locator), facilitando los Mocks en tests.
* **`dartz` / `fpdart`**: Programación Funcional (`Either<Failure, Success>`).

### Conectividad & Datos
*   **`dio`**: Cliente HTTP robusto con **Interceptores** para inyectar tokens JWT en cada petición y manejar deslogueos automáticos ante errores 401.
*   **`firebase_core` & `firebase_messaging`**: Infraestructura para notificaciones push transaccionales en tiempo real (ej. confirmaciones de pago).
*   **`google_maps_flutter`**: Integración cartográfica para el catálogo de canchas.

### Diseño & Motion (UI Premium)
*   **`flutter_animate`**: Coreografía de animaciones fluidas (fade, slide, scale) sin boilerplate.
*   **`shimmer`**: Esqueletos de carga (*Skeleton Loading*) de alta fidelidad que eliminan el "Layout Shift" y mejoran la percepción de velocidad.

---

## 🧩 Patrones de Diseño Aplicados

### Chain of Responsibility (Manejador de Partidos)
Para manejar la compleja máquina de estados de un partido (`publicada`, `negociando`, `pendiente_pago`, `confirmada`, `completada`), implementamos el patrón de **Cadena de Responsabilidad**. El frontend utiliza un `MatchActionHandler` que delega las transiciones y validaciones según el rol (Capitán Organizador, Capitán Rival, Jugador), eliminando por completo los anti-patrones de múltiples `if/else` en los Widgets.

### Formularios Centralizados
Validaciones asíncronas de campos de texto integradas en el framework nativo. Cada input retroalimenta visualmente su estado, protegiendo a la capa de Aplicación de "Garbage Data".

---

## 📂 Estructura del Proyecto

El proyecto se divide modularmente por características funcionales de negocio bajo el patrón **Feature-First**:

```text
lib/features/
├── auth/            # 🔐 Identidad (Login, Register, Validaciones)
├── catalogs/        # 🏟️ Catálogos y Canchas (Google Maps)
├── main_hub/        # 🧭 Orquestador de Navegación Principal (BottomBar)
├── matches/         # ⚽ Núcleo de Partidos (ActionHandlers, Resultados, Retos)
├── notifications/   # 🔔 Bandeja de Notificaciones y alertas
├── payments/        # 💸 Finanzas (Cuotas dinámicas, subida de comprobantes)
├── profile/         # 👤 Perfil y Settings (Tema Claro/Oscuro dinámico)
├── rankings/        # 📈 Tablas de posiciones
└── teams/           # 🛡️ Gestión de Equipos (Membresías y Capitanía)
```

Dentro de cada feature, la estructura Clean Architecture se mantiene impecable:
```text
lib/features/matches/
├── domain/                  # Entidades (MatchEntity) e Interfaces de Repo
├── application/             # Casos de uso (AcceptMatchUseCase)
├── infrastructure/          # Datasources y RepositoryImpl (HTTP, JSON)
└── presentation/            # UI (MatchDetailsPage), Widgets modulares y BLoC
```

---

## 🚀 Guía de Inicio Rápido

### Prerrequisitos
* **Flutter SDK** (^3.19.0)
* **IDE**: VSCode o Android Studio.
* Archivo `.env` configurado (API Keys de Google Maps).

### Instalación

1.  **Clonar el repositorio:**
    ```bash
    git clone https://github.com/MatchDay-UCAB/matchday_app.git
    cd matchday_app
    ```

2.  **Instalar dependencias:**
    ```bash
    flutter pub get
    ```

3.  **Generación de Código (Fundamental):**
    Utilizamos generadores para Inyección de Dependencias y Rutas.
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Ejecutar:**
    ```bash
    flutter run
    ```

<br>
<hr>
<p align="center">
  <sub>Desarrollado como Pasante de <b>TecnoRed @ UCAB</b> - 2026</sub><br>
  <small>Ingeniería de Software Móvil de Alto Impacto</small>
</p>
