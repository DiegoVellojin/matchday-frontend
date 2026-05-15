import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/entities/match_entity.dart';
import '../../../domain/utils/match_role_resolver.dart';
import '../../utils/match_action.dart';
import '../../bloc/matches_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../payments/domain/entities/payment_entity.dart';

class MatchDetailActions {
  final List<MatchAction> primaryActions;
  final List<MatchAction> secondaryActions;
  final List<MatchAction> destructiveActions;

  const MatchDetailActions({
    this.primaryActions = const [],
    this.secondaryActions = const [],
    this.destructiveActions = const [],
  });

  bool get isEmpty =>
      primaryActions.isEmpty &&
      secondaryActions.isEmpty &&
      destructiveActions.isEmpty;
}

abstract class _MatchDetailsActionLink {
  _MatchDetailsActionLink? _next;

  _MatchDetailsActionLink setNext(_MatchDetailsActionLink next) {
    _next = next;
    return next;
  }

  MatchDetailActions? handle(_MatchDetailsActionRequest req);

  MatchDetailActions? passDown(_MatchDetailsActionRequest req) =>
      _next?.handle(req);
}

class _MatchDetailsActionRequest {
  final BuildContext context;
  final MatchEntity match;
  final int? currentUserId;
  final MatchRole role;
  final bool hasVerifiedPayment;
  final bool hasReportedPayment;
  final bool amIInA;

  const _MatchDetailsActionRequest({
    required this.context,
    required this.match,
    required this.currentUserId,
    required this.role,
    this.hasVerifiedPayment = false,
    this.hasReportedPayment = false,
    this.amIInA = false,
  });

  bool get isOrganizer => role == MatchRole.captainA;
  bool get isAnyCaptain =>
      role == MatchRole.captainA || role == MatchRole.captainB;
  bool get isExternal => role == MatchRole.external;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Eslabones concretos
// ─────────────────────────────────────────────────────────────────────────────

class _PublicadaDetailsLink extends _MatchDetailsActionLink {
  @override
  MatchDetailActions? handle(_MatchDetailsActionRequest req) {
    if (req.match.estatus != 'publicada') return passDown(req);

    if (req.isOrganizer) {
      return MatchDetailActions(
        secondaryActions: [
          MatchAction(
            label: 'Editar Datos',
            onTap: () => req.context.push('/crear-partido', extra: req.match),
          ),
        ],
        destructiveActions: [
          MatchAction(
            label: 'Cancelar',
            onTap: () => MatchDetailsActionHandler.handleCancelMatch(
                req.context, req.match.id),
          ),
        ],
      );
    }

    // 2. Si el usuario es el Capitán B asignado o parte del Equipo B invitado
    if (req.role == MatchRole.captainB || (req.role == MatchRole.playerTeamB && req.match.idCapitanB == null)) {
      return MatchDetailActions(
        primaryActions: [
          MatchAction(
            label: 'Aceptar Encuentro',
            onTap: () =>
                req.context.push('/accept-encounter', extra: {'match': req.match}),
          ),
        ],
        secondaryActions: [
          MatchAction(
            label: '🛡️ Ver Equipo Rival',
            onTap: () => req.context.push('/team-dashboard/${req.match.idEquipoA}'),
          ),
        ],
      );
    }

    // 3. Si el usuario es externo y no hay equipo B (Oferta abierta)
    if (req.isExternal && req.match.idEquipoB == null) {
      return MatchDetailActions(
        primaryActions: [
          MatchAction(
            label: 'Aceptar Encuentro',
            onTap: () =>
                req.context.push('/accept-encounter', extra: {'match': req.match}),
          ),
        ],
        secondaryActions: [
          MatchAction(
            label: '🛡️ Ver Equipo Rival',
            onTap: () => req.context.push('/team-dashboard/${req.match.idEquipoA}'),
          ),
        ],
      );
    }

    // 4. Para jugadores que ya están dentro (Team A)
    if (req.role == MatchRole.playerTeamA || req.role == MatchRole.captainA) {
      return MatchDetailActions(
        secondaryActions: [
          MatchAction(
            label: '⚽ Ver Mi Equipo',
            onTap: () => req.context.push('/team-dashboard/${req.match.idEquipoA}'),
          ),
        ],
      );
    }

    return const MatchDetailActions();
  }
}

class _NegociandoDetailsLink extends _MatchDetailsActionLink {
  @override
  MatchDetailActions? handle(_MatchDetailsActionRequest req) {
    if (req.match.estatus != 'negociando') return passDown(req);

    if (req.isAnyCaptain) {
      return MatchDetailActions(
        primaryActions: [
          MatchAction(
            label: 'Coordinar Encuentro',
            onTap: () => req.context.push('/configure-match', extra: {'matchEntity': req.match}),
          ),
        ],
        secondaryActions: [
          MatchAction(
            label: 'Contactar Rival',
            onTap: () => MatchDetailsActionHandler.handleContactar(req.context, req.match, req.currentUserId),
          ),
        ],
      );
    }

    // Jugadores en negociación
    if (!req.isExternal) {
      return MatchDetailActions(
        secondaryActions: [
          MatchAction(
            label: '⚽ Ver Detalles',
            onTap: () => {}, 
          ),
        ],
      );
    }

    return const MatchDetailActions();
  }
}

class _PendientePagoDetailsLink extends _MatchDetailsActionLink {
  @override
  MatchDetailActions? handle(_MatchDetailsActionRequest req) {
    if (req.match.estatus != 'pendiente_pago') return passDown(req);

    if (req.isAnyCaptain) {
      return MatchDetailActions(
        primaryActions: [
          MatchAction(
            label: 'Gestionar Pagos',
            onTap: () => req.context.push('/match-dashboard', extra: {'matchEntity': req.match}),
          ),
        ],
        secondaryActions: [
          MatchAction(
            label: 'Contactar Rival',
            onTap: () => MatchDetailsActionHandler.handleContactar(req.context, req.match, req.currentUserId),
          ),
        ],
      );
    }

    // Para jugadores regulares
    if (!req.isExternal) {
      return MatchDetailActions(
        primaryActions: [
          MatchAction(
            label: req.hasReportedPayment ? 'Modificar Pago' : 'Ir a Pagar',
            onTap: () => _handlePaymentNavigation(req),
          ),
        ],
      );
    }

    return const MatchDetailActions();
  }

  void _handlePaymentNavigation(_MatchDetailsActionRequest req) {
    if (req.hasVerifiedPayment) {
      ScaffoldMessenger.of(req.context).showSnackBar(
        const SnackBar(content: Text('Tu pago ya ha sido verificado')),
      );
      return;
    }

    final myName = req.amIInA
        ? (req.match.nombreEquipoA ?? 'Tu Equipo')
        : (req.match.nombreEquipoB ?? 'Tu Equipo');
    final myLogo = req.amIInA ? req.match.logoEquipoA : req.match.logoEquipoB;

    final payment = PaymentEntity(
      idPartida: req.match.id,
      teamName: myName,
      teamLogo: myLogo,
      concepto: req.match.sportName ?? 'Partido',
      monto: req.match.cuotaPorJugador,
      isPaid: false,
      estatusPago: req.hasReportedPayment ? 'pendiente' : 'pendiente',
      banco: req.amIInA ? req.match.bancoReceptor : req.match.bancoCapitanB,
      cedula: req.amIInA ? req.match.cedulaReceptora : req.match.cedulaCapitanB,
      telefono: req.amIInA ? req.match.telefonoReceptor : req.match.telefonoCapitanBPago,
      moneda: req.match.moneda,
    );

    req.context.push('/upload-receipt', extra: {'payment': payment});
  }
}

class _ConfirmadaDetailsLink extends _MatchDetailsActionLink {
  @override
  MatchDetailActions? handle(_MatchDetailsActionRequest req) {
    if (req.match.estatus != 'confirmada') return passDown(req);

    if (req.isAnyCaptain) {
      final hasMatchPassed = DateTime.now().isAfter(req.match.fechaInicioEstimada);
      if (!hasMatchPassed) {
        return MatchDetailActions(
          primaryActions: [
            MatchAction(
              label: 'Gestionar Pagos',
              onTap: () => req.context.push('/match-dashboard', extra: {'matchEntity': req.match}),
            ),
          ],
          secondaryActions: [
            MatchAction(
              label: 'Contactar Rival',
              onTap: () => MatchDetailsActionHandler.handleContactar(req.context, req.match, req.currentUserId),
            ),
          ],
        );
      }

      final isCaptainA = req.currentUserId == req.match.idUsuarioOrg;
      final myGoles = isCaptainA ? req.match.resultadoGolesACapA : req.match.resultadoGolesBCapB;
      final hasRegistered = myGoles != null;

      return MatchDetailActions(
        primaryActions: [
          MatchAction(
            label: hasRegistered ? 'Ver Resultado' : 'Registrar Resultado',
            onTap: () {
              if (hasRegistered) {
                req.context.push('/confirm-result', extra: {'matchEntity': req.match});
              } else {
                req.context.push('/register-result', extra: {'matchEntity': req.match});
              }
            },
          ),
        ],
        secondaryActions: [
          MatchAction(
            label: 'Contactar Rival',
            onTap: () => MatchDetailsActionHandler.handleContactar(req.context, req.match, req.currentUserId),
          ),
        ],
      );
    }

    if (!req.isExternal) {
      final hasMatchPassed = DateTime.now().isAfter(req.match.fechaInicioEstimada);
      if (!hasMatchPassed) {
        return MatchDetailActions(
          primaryActions: [
            MatchAction(
              label: req.hasReportedPayment ? 'Modificar Pago' : 'Ir a Pagar',
              onTap: () {
                final link = _PendientePagoDetailsLink();
                link._handlePaymentNavigation(req);
              },
            ),
          ],
        );
      }
    }

    return const MatchDetailActions();
  }
}

class _CompletadaDetailsLink extends _MatchDetailsActionLink {
  @override
  MatchDetailActions? handle(_MatchDetailsActionRequest req) {
    if (req.match.estatus != 'completada') return passDown(req);

    if (req.isAnyCaptain || !req.isExternal) {
      return MatchDetailActions(
        primaryActions: [
          MatchAction(
            label: 'Ver Resultado',
            onTap: () => req.context.push('/match-history'),
          ),
        ],
        secondaryActions: req.isAnyCaptain
            ? [
                MatchAction(
                  label: 'Contactar Rival',
                  onTap: () => MatchDetailsActionHandler.handleContactar(req.context, req.match, req.currentUserId),
                )
              ]
            : [],
      );
    }

    return const MatchDetailActions();
  }
}

class _DefaultDetailsLink extends _MatchDetailsActionLink {
  @override
  MatchDetailActions? handle(_MatchDetailsActionRequest req) {
    return const MatchDetailActions();
  }
}

class MatchDetailsActionHandler {
  MatchDetailsActionHandler._();

  static MatchDetailActions resolve({
    required BuildContext context,
    required MatchEntity match,
    required int? currentUserId,
    required MatchRole role,
    bool hasVerifiedPayment = false,
    bool hasReportedPayment = false,
    bool amIInA = false,
  }) {
    final chain = _PublicadaDetailsLink();
    chain
        .setNext(_NegociandoDetailsLink())
        .setNext(_PendientePagoDetailsLink())
        .setNext(_ConfirmadaDetailsLink())
        .setNext(_CompletadaDetailsLink())
        .setNext(_DefaultDetailsLink());

    final req = _MatchDetailsActionRequest(
      context: context,
      match: match,
      currentUserId: currentUserId,
      role: role,
      hasVerifiedPayment: hasVerifiedPayment,
      hasReportedPayment: hasReportedPayment,
      amIInA: amIInA,
    );

    return chain.handle(req) ?? const MatchDetailActions();
  }

  static void handleContactar(BuildContext context, MatchEntity match, int? currentUserId) async {
    final isCaptainA = currentUserId == match.idUsuarioOrg;
    final rivalPhone = isCaptainA ? match.telefonoCapitanB : match.telefonoCapitanA;

    if (rivalPhone == null || rivalPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay número de teléfono disponible para el capitán rival')),
      );
      return;
    }

    final cleanPhone = rivalPhone.replaceAll(RegExp(r'\D'), '');
    final message = "Hola, soy el capitán rival para el partido del ${DateFormat('dd/MM/yyyy').format(match.fechaInicioEstimada)}. ¿Cómo coordinamos?";
    final url = "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    }
  }

  static void handleCancelMatch(BuildContext context, int matchId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          '¿Cancelar Partido?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Esta acción eliminará el partido permanentemente y notificará a los interesados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Volver', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MatchesBloc>().add(CancelMatchEvent(matchId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(
              'Confirmar Cancelación',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
