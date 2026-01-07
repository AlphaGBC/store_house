import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/core/constant/imgaeasset.dart';

/// A widget that displays different UI based on [StatusRequest].
/// For error or empty states, wraps content in a scrollable view
/// to allow pull-to-refresh to work.
class HandlingDataView extends StatelessWidget {
  final StatusRequest statusRequest;
  final Widget widget;

  const HandlingDataView({
    super.key,
    required this.statusRequest,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (statusRequest) {
      case StatusRequest.loading:
        content = Center(
          child: Lottie.asset(AppImageAsset.loading, width: 250, height: 250),
        );
        break;
      case StatusRequest.offlinefailure:
        content = Center(
          child: Lottie.asset(AppImageAsset.offline, width: 250, height: 250),
        );
        break;
      case StatusRequest.serverfailure:
        content = Center(
          child: Lottie.asset(AppImageAsset.server, width: 250, height: 250),
        );
        break;
      case StatusRequest.failure:
        content = Center(
          child: Lottie.asset(
            AppImageAsset.noData,
            width: 250,
            height: 250,
            repeat: true,
          ),
        );
        break;
      default:
        // When data is loaded successfully, show the provided widget
        return widget;
    }

    // For all non-success states, wrap in scrollable to enable pull-to-refresh
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        // Ensure the scrollable takes up available height
        height:
            MediaQuery.of(context).size.height -
            kToolbarHeight -
            MediaQuery.of(context).padding.top,
        child: content,
      ),
    );
  }
}

/// A widget similar to [HandlingDataView] but without an empty-data state.
class HandlingDataRequest extends StatelessWidget {
  final StatusRequest statusRequest;
  final Widget widget;

  const HandlingDataRequest({
    super.key,
    required this.statusRequest,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (statusRequest) {
      case StatusRequest.loading:
        content = Center(
          child: Lottie.asset(AppImageAsset.loading, width: 250, height: 250),
        );
        break;
      case StatusRequest.offlinefailure:
        content = Center(
          child: Lottie.asset(AppImageAsset.offline, width: 250, height: 250),
        );
        break;
      case StatusRequest.serverfailure:
        content = Center(
          child: Lottie.asset(AppImageAsset.server, width: 250, height: 250),
        );
        break;
      default:
        // On success, show the provided widget
        return widget;
    }

    // Wrap errors in scrollable to allow pull-to-refresh
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height:
            MediaQuery.of(context).size.height -
            kToolbarHeight -
            MediaQuery.of(context).padding.top,
        child: content,
      ),
    );
  }
}
