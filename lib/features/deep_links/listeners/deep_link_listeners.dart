import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:daily_water_tracker/common/router.dart';
import 'package:daily_water_tracker/features/deep_links/cubit/deep_link_cubit.dart';
import 'package:daily_water_tracker/features/deep_links/cubit/deep_link_state.dart';
import 'package:daily_water_tracker/features/deep_links/models/water_link_purpose.dart';
import 'package:daily_water_tracker/features/deep_links/widgets/share_progress_sheet.dart';

class DeepLinkListeners extends StatefulWidget {
  const DeepLinkListeners({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<DeepLinkListeners> createState() => _DeepLinkListenersState();
}

class _DeepLinkListenersState extends State<DeepLinkListeners>
    with WidgetsBindingObserver {
  int _lastPresentedDeliveryId = 0;
  bool _isPresentingShareSheet = false;
  WaterLinkPurposeShareProgress? _pendingShare;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _tryPresentPendingShare();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeepLinkCubit, DeepLinkState>(
      listenWhen: (prev, next) =>
          next.shareDeliveryId != prev.shareDeliveryId &&
          next.purpose is WaterLinkPurposeShareProgress,
      listener: (context, state) {
        final purpose = state.purpose;
        if (purpose is! WaterLinkPurposeShareProgress) return;

        _pendingShare = purpose;
        unawaited(_tryPresentShare(context, deliveryId: state.shareDeliveryId));
      },
      child: widget.child,
    );
  }

  Future<void> _tryPresentPendingShare() async {
    if (!mounted || _pendingShare == null || _isPresentingShareSheet) return;

    final cubit = context.read<DeepLinkCubit>();
    final deliveryId = cubit.state.shareDeliveryId;
    if (deliveryId <= _lastPresentedDeliveryId) return;

    await _tryPresentShare(context, deliveryId: deliveryId);
  }

  Future<void> _tryPresentShare(
    BuildContext context, {
    required int deliveryId,
  }) async {
    if (_isPresentingShareSheet || deliveryId <= _lastPresentedDeliveryId) {
      return;
    }

    final purpose = _pendingShare;
    if (purpose == null) return;

    final cubit = context.read<DeepLinkCubit>();
    _isPresentingShareSheet = true;
    const attempts = 12;
    const baseDelay = Duration(milliseconds: 120);

    try {
      for (var i = 0; i < attempts; i++) {
        await Future<void>.delayed(baseDelay * (i + 1));
        if (!mounted) return;

        final overlayContext = rootNavigatorKey.currentContext;
        if (overlayContext == null || !overlayContext.mounted) continue;

        final navigator = Navigator.maybeOf(overlayContext, rootNavigator: true);
        if (navigator == null) continue;

        await ShareProgressSheet.show(overlayContext, ml: purpose.ml);

        if (!mounted) return;
        _lastPresentedDeliveryId = deliveryId;
        _pendingShare = null;
        cubit.resetPurpose();
        return;
      }
    } finally {
      _isPresentingShareSheet = false;
    }
  }
}
