import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/match_entity.dart';
import '../pages/register_result_page.dart';
import '../pages/confirm_result_page.dart';
import 'match_action.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Interfaces para el patrón Cadena de Responsabilidad
// ─────────────────────────────────────────────────────────────────────────────

/// Contrato de cada eslabón de la cadena.
abstract class _MatchActionLink {
  _MatchActionLink? _next;

  _MatchActionLink setNext(_MatchActionLink next) {
    _next = next;
    return next;
  }

  /// Devuelve un [MatchAction] si este eslabón sabe manejar el estado,
  /// de lo contrario delega al siguiente.
  MatchAction? handle(_MatchActionRequest req);

  /// Pasa la solicitud al siguiente eslabón.
  MatchAction? passDown(_MatchActionRequest req) => _next?.handle(req);
}

/// Objeto de transferencia que viaja por la cadena.
class _MatchActionRequest {
  final BuildContext context;
  final MatchEntity match;
  final int? currentUserId;

  const _MatchActionRequest({
    required this.context,
    required this.match,
    required this.currentUserId,
  });

  bool get isOrganizer =>
      currentUserId != null && match.idUsuarioOrg == currentUserId;

  bool get isCaptainB =>
      currentUserId != null && match.idCapitanB == currentUserId;

  bool get isAnyCaptain => isOrganizer || isCaptainB;

  /// Goles a favor desde la perspectiva del usuario actual (solo capitanes).
  int? get myGolesFavor => isOrganizer
      ? match.resultadoGolesACapA
      : (isCaptainB ? match.resultadoGolesBCapB : null);

  bool get hasRegisteredResult => myGolesFavor != null;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Eslabones concretos
// ─────────────────────────────────────────────────────────────────────────────

/// Maneja el estado "completada".
class _CompletadaLink extends _MatchActionLink {
  @override
  MatchAction? handle(_MatchActionRequest req) {
    if (!req.match.status.isCompleted) return passDown(req);
    return MatchAction(
      label: '🏅 Ver Resumen',
      onTap: () => req.context.push('/match-history-detail/${req.match.id}'),
    );
  }
}

/// Maneja el estado "confirmada".
class _ConfirmadaLink extends _MatchActionLink {
  @override
  MatchAction? handle(_MatchActionRequest req) {
    if (!req.match.status.isConfirmed) return passDown(req);

    if (req.isAnyCaptain) {
      if (req.hasRegisteredResult) {
        return MatchAction(
          label: '👀 Ver Resultado',
          onTap: () => Navigator.push(
            req.context,
            MaterialPageRoute(
              builder: (_) => ConfirmarResultadoPage(
                match: req.match,
                currentUserId: req.currentUserId!,
              ),
            ),
          ),
        );
      } else {
        return MatchAction(
          label: '🏆 Registrar Resultado',
          onTap: () => Navigator.push(
            req.context,
            MaterialPageRoute(
              builder: (_) => RegisterResultPage(
                match: req.match,
                currentUserId: req.currentUserId!,
              ),
            ),
          ),
        );
      }
    }

    return MatchAction(
      label: '⚽ Ver Encuentro',
      onTap: () => req.context.push(
        '/player-match-dashboard',
        extra: {'match': req.match},
      ),
    );
  }
}

/// Maneja el estado "pendiente_pago".
class _PendientePagoLink extends _MatchActionLink {
  @override
  MatchAction? handle(_MatchActionRequest req) {
    if (!req.match.status.isPendingPayment) return passDown(req);

    if (req.isAnyCaptain) {
      return MatchAction(
        label: '⚙️ Administrar Partido',
        onTap: () => req.context.push(
          '/match-dashboard',
          extra: {'matchEntity': req.match},
        ),
      );
    }

    return MatchAction(
      label: '⚽ Ver Encuentro',
      onTap: () => req.context.push(
        '/player-match-dashboard',
        extra: {'match': req.match},
      ),
    );
  }
}

/// Maneja el estado "negociando".
class _NegociandoLink extends _MatchActionLink {
  @override
  MatchAction? handle(_MatchActionRequest req) {
    if (!req.match.status.isNegotiating) return passDown(req);

    if (req.isAnyCaptain) {
      return MatchAction(
        label: '🛠️ Configurar Encuentro',
        onTap: () => req.context.push(
          '/configure-match',
          extra: {'matchEntity': req.match},
        ),
      );
    }

    return MatchAction(
      label: '⚽ Ver Encuentro',
      onTap: () => req.context.push(
        '/player-match-dashboard',
        extra: {'match': req.match},
      ),
    );
  }
}

/// Maneja el estado "publicada".
class _PublicadaLink extends _MatchActionLink {
  @override
  MatchAction? handle(_MatchActionRequest req) {
    if (!req.match.status.isPublished) return passDown(req);

    if (req.isOrganizer) {
      return MatchAction(
        label: '⚙️ Administrar Partido',
        onTap: () => req.context.push('/match-details/${req.match.id}'),
      );
    }

    return MatchAction(
      label: '🤝 Aceptar Encuentro',
      onTap: () => req.context.push(
        '/accept-encounter',
        extra: {'match': req.match},
      ),
    );
  }
}

/// Eslabón de fallback — cualquier otro estado.
class _DefaultLink extends _MatchActionLink {
  @override
  MatchAction? handle(_MatchActionRequest req) {
    return MatchAction(
      label: '🔍 Ver Detalles',
      onTap: () => req.context.push('/match-details/${req.match.id}'),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Fachada pública
// ─────────────────────────────────────────────────────────────────────────────

/// Punto de entrada para resolver la acción del botón CTA de un partido.
///
/// Construye la cadena una sola vez y delega al primer eslabón.
/// Uso:
/// ```dart
/// final action = MatchActionHandler.resolve(
///   context: context,
///   match: match,
///   currentUserId: userId,
/// );
/// ElevatedButton(onPressed: action.onTap, child: Text(action.label));
/// ```
class MatchActionHandler {
  MatchActionHandler._();

  static MatchAction resolve({
    required BuildContext context,
    required MatchEntity match,
    required int? currentUserId,
  }) {
    // Construir la cadena: Completada → Confirmada → PendientePago → Negociando → Publicada → Default
    final chain = _CompletadaLink();
    chain
        .setNext(_ConfirmadaLink())
        .setNext(_PendientePagoLink())
        .setNext(_NegociandoLink())
        .setNext(_PublicadaLink())
        .setNext(_DefaultLink());

    final req = _MatchActionRequest(
      context: context,
      match: match,
      currentUserId: currentUserId,
    );

    return chain.handle(req)!; // _DefaultLink siempre devuelve algo.
  }
}
