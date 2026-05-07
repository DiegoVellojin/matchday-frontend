# ⚽ MatchDay App

> **"La élite del fútbol amateur, en la palma de tu mano."**

![Banner Principal](https://raw.githubusercontent.com/MatchDay-UCAB/matchday_app/main/assets/banner_premium.png)
*(Captura conceptual de la interfaz Premium)*

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20(4%20Layers)-success?style=for-the-badge)
![UI](https://img.shields.io/badge/UI-Premium%20Dark-black?style=for-the-badge)

<br>

[![Disponible en Play Store](https://img.shields.io/badge/Google%20Play-Próximamente-green?style=for-the-badge&logo=google-play&logoColor=white)](https://play.google.com/store)

</div>

---

## 📖 Sobre el Proyecto

**MatchDay** es una plataforma integral diseñada para profesionalizar la experiencia del fútbol amateur. Más que una app de partidos, es un ecosistema de competición donde los capitanes pueden gestionar equipos, los jugadores pueden descubrir retos y las ligas pueden escalar su visibilidad.

Este proyecto ha sido desarrollado bajo los más altos estándares de ingeniería de software, implementando una arquitectura desacoplada y un sistema de diseño "Premium High-Fidelity" para garantizar una experiencia de usuario fluida y libre de parpadeos (*flicker-free*).

---

## 🏛️ Ingeniería de Software: Arquitectura de Excelencia

El núcleo de MatchDay se basa en **Clean Architecture**, dividiendo la aplicación en cuatro capas concéntricas para asegurar independencia tecnológica, facilidad de prueba y escalabilidad masiva.

### Desglose de Capas

#### 1. 🎯 Domain (Dominio)
El corazón inmutable del negocio. Contiene las reglas que definen MatchDay independientemente de la tecnología.
*   **Entities:** Modelos puros que utilizan `Equatable` para comparaciones precisas por valor.
*   **Repositories (Interfaces):** Definición de contratos que la infraestructura debe obedecer (Inversión de Dependencias).

#### 2. 🏗️ Application (Aplicación)
El cerebro operativo que orquestra los casos de uso.
*   **Use Cases:** Clases de responsabilidad única (SRP) que ejecutan acciones como `JoinMatch` o `CreateTeam`. Utilizan el patrón funcional `Either<Failure, T>` para un manejo de errores robusto y tipado.

#### 3. 🔌 Infrastructure (Infraestructura)
El puente con el mundo exterior.
*   **Data Sources:** Comunicación cruda mediante `Dio` (HTTP) y `Firebase Admin`.
*   **Repository Impls:** Traductores que convierten datos externos (JSON) en verdades de dominio, protegiendo a la app de cambios en la API.

#### 4. 🎨 Presentation (Presentación)
La capa visual regida por el patrón **BLoC (Business Logic Component)**.
*   **State Management:** Separación total de la lógica y la interfaz. La UI es una función pasiva del estado.
*   **Full Persistencia:** Implementación de cachés locales para evitar parpadeos durante las actualizaciones en segundo plano.

---

## 🛠️ Stack Tecnológico de Élite

*   **UI & Motion:** `flutter_animate`, `shimmer`, `lottie` y `google_fonts` para una estética vibrante y moderna.
*   **Networking:** `Dio` con interceptores personalizados para gestión de Tokens JWT y logs en tiempo real.
*   **Geolocalización:** Integración avanzada con `google_maps_flutter` para el registro y búsqueda de canchas.
*   **Cloud Services:** `firebase_core`, `firebase_storage` (para multimedia) y `firebase_messaging` (notificaciones push).
*   **Local Storage:** `flutter_secure_storage` para la protección de credenciales sensibles.

---

## 💎 Características "Premium" Destacadas

### 🏆 Leaderboard Dinámico
Un sistema de rankings en tiempo real con un podio visualmente impactante, efectos de glassmorphism y transiciones fluidas.

### ⚡ Skeleton Loading (Shimmer)
Adiós a los spinners genéricos. MatchDay utiliza esqueletos de alta fidelidad que imitan la estructura final del contenido, eliminando el "layout shift" y mejorando la percepción de velocidad.

### 🗺️ Registro de Canchas con Maps
Integración directa con el mapa para localizar y añadir nuevos centros deportivos con precisión de coordenadas.

### 💸 Gestión de Pagos (Wallet)
Módulo dedicado para que los capitanes validen comprobantes de pago y gestionen las finanzas de cada encuentro sin salir de la app.

---

## 🚀 Guía de Inicio

### Prerrequisitos
*   Flutter SDK (^3.11.5)
*   Dart SDK (^3.x)
*   Key de Google Maps API configurada en Android/iOS.

### Instalación

1.  **Clonar y configurar:**
    ```bash
    git clone https://github.com/MatchDay-UCAB/matchday_app.git
    cd matchday_app
    ```

2.  **Obtener dependencias:**
    ```bash
    flutter pub get
    ```

3.  **Generación de código:**
    MatchDay utiliza generadores para DI y serialización:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Ejecutar:**
    ```bash
    flutter run
    ```

---

<div align="center">
  <sub>Desarrollado como Pasante de <b>TecnoRed @ UCAB</b> - 2026</sub>
  <br>
  <small>Ingeniería de Software de Alto Impacto</small>
</div>
