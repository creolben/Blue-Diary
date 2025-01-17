
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_appstore/open_appstore.dart';
import 'package:todo_app/Delegators.dart';
import 'package:todo_app/Localization.dart';
import 'package:todo_app/Secrets.dart';
import 'package:todo_app/Utils.dart';
import 'package:todo_app/domain/usecase/SettingsUsecases.dart';
import 'package:todo_app/presentation/App.dart';
import 'package:todo_app/presentation/createpassword/CreatePasswordScreen.dart';
import 'package:todo_app/presentation/inputpassword/InputPasswordScreen.dart';

class SettingsBloc {
  static const _SENDGRID_SEND_API_ENDPOINT = 'https://api.sendgrid.com/v3/mail/send';
  // ignore: non_constant_identifier_names
  static final _EMAIL_VALIDATION_REGEX = RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");

  final SettingsUsecases _usecases = dependencies.settingsUsecases;

  void Function() _needUpdateListener;

  final _twoSeconds = const Duration(seconds: 2);

  SettingsBlocDelegator delegator;

  SettingsBloc({
    @required this.delegator,
  });

  void updateDelegator(SettingsBlocDelegator delegator) {
    this.delegator = delegator;
  }

  void setNeedUpdateListener(void Function() listener) {
    this._needUpdateListener = listener;
  }

  Future<void> onUseLockScreenChanged(BuildContext context) async {
    final useLockScreen = await _usecases.getUseLockScreen();
    final userPassword = await _usecases.getUserPassword();

    if (useLockScreen && userPassword.isEmpty) {
      _usecases.setUseLockScreen(false);
      _showCreatePasswordDialog(context,
        onCreated: () {
          _usecases.setUseLockScreen(true);
          if (_needUpdateListener != null) {
            _needUpdateListener();
          }
        }
      );
    } else if (!useLockScreen) {
      // set it to true forcefully instantly.
      // will set to false when user inputs password correctly
      _usecases.setUseLockScreen(true);
      delegator.showBottomSheet((context) =>
        InputPasswordScreen(onSuccess: () {
          _usecases.setUseLockScreen(false);
          if (_needUpdateListener != null) {
            _needUpdateListener();
          }
        }, onFail: () {
          delegator.showSnackBar(AppLocalizations.of(context).unlockFail, _twoSeconds);
        }),
      );
    }
  }

  Future<void> _showCreatePasswordDialog(BuildContext context, {
    void Function() onCreated,
  }) async {
    return Utils.showAppDialog(context,
      AppLocalizations.of(context).createPassword,
      AppLocalizations.of(context).createPasswordBody,
      null,
        () => _onCreatePasswordOkClicked(context, onCreated: onCreated),
    );
  }

  Future<void> _onCreatePasswordOkClicked(BuildContext context, {
    void Function() onCreated,
  }) async {
    final successMsg = AppLocalizations.of(context).createPasswordSuccess;
    final failMsg = AppLocalizations.of(context).createPasswordFail;

    delegator.showBottomSheet((context) => CreatePasswordScreen(),
      onClosed: () async {
        final isPasswordSaved = await _usecases.getUserPassword().then((s) => s.length > 0);
        if (isPasswordSaved) {
          delegator.showSnackBar(successMsg, _twoSeconds);
          if (onCreated != null) {
            onCreated();
          }
        } else {
          delegator.showSnackBar(failMsg, _twoSeconds);
        }
      }
    );
  }

  Future<void> onSendTempPasswordClicked(BuildContext context) async {
    final recoveryEmail = await _usecases.getRecoveryEmail();
    if (!_EMAIL_VALIDATION_REGEX.hasMatch(recoveryEmail)) {
      final message = AppLocalizations.of(context).invalidRecoveryEmail;
      delegator.showSnackBar(message, _twoSeconds);
    } else {
      _showConfirmSendTempPasswordDialog(context);
    }
  }

  Future<void> _showConfirmSendTempPasswordDialog(BuildContext context) async {
    return Utils.showAppDialog(context,
      AppLocalizations.of(context).confirmSendTempPassword,
      AppLocalizations.of(context).confirmSendTempPasswordBody,
      null,
        () => _onConfirmSendTempPasswordOkClicked(context),
    );
  }

  Future<void> _onConfirmSendTempPasswordOkClicked(BuildContext context) async {
    final mailSentMsg = AppLocalizations.of(context).tempPasswordMailSent;
    final mailSendFailedMsg = AppLocalizations.of(context).tempPasswordMailSendFailed;
    final failedToSaveTempPasswordMsg = AppLocalizations.of(context).failedToSaveTempPasswordByUnknownError;

    final prevPassword = await _usecases.getUserPassword();
    await _usecases.setUserPassword(_createRandomPassword());
    final changedPassword = await _usecases.getUserPassword();

    if (changedPassword.isNotEmpty && prevPassword != changedPassword) {
      final mailTitle = AppLocalizations.of(context).tempPasswordMailSubject;
      final mailBody = AppLocalizations.of(context).tempPasswordMailBody;
      final recoveryEmail = await _usecases.getRecoveryEmail();
      final body = _createEmailBodyJson(
        targetEmail: recoveryEmail,
        title: mailTitle,
        body: '$mailBody$changedPassword');
      final response = await http.post(
        _SENDGRID_SEND_API_ENDPOINT,
        headers: {
          HttpHeaders.authorizationHeader: SENDGRID_AUTHORIZATION,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: body,
      );
      if (response.statusCode.toString().startsWith('2')) {
        delegator.showSnackBar(mailSentMsg, _twoSeconds);
      } else {
        delegator.showSnackBar(mailSendFailedMsg, _twoSeconds);
      }
    } else {
      delegator.showSnackBar(failedToSaveTempPasswordMsg, _twoSeconds);
    }
  }

  String _createRandomPassword() {
    final rand = Random();
    return '${rand.nextInt(10)}${rand.nextInt(10)}${rand.nextInt(10)}${rand.nextInt(10)}';
  }

  String _createEmailBodyJson({
    @required String targetEmail,
    @required String title,
    @required String body,
  }) {
    return '{"personalizations":[{"to":[{"email":"$targetEmail"}],"subject":"$title"}],"content": [{"type": "text/plain", "value": "$body"}],"from":{"email":"giantsol64@gmail.com","name":"Blue Diary Developer"}}';
  }

  Future<void> onResetPasswordClicked(BuildContext context) async {
    final prevPassword = await _usecases.getUserPassword();

    if (prevPassword.isEmpty) {
      _showCreatePasswordDialog(context);
    } else {
      final changedMsg = AppLocalizations.of(context).passwordChanged;
      final unchangedMsg = AppLocalizations.of(context).passwordUnchanged;

      delegator.showBottomSheet((context) =>
        InputPasswordScreen(
          onSuccess: () async {
            delegator.showBottomSheet((context) => CreatePasswordScreen(),
              onClosed: () async {
                final changedPassword = await _usecases.getUserPassword();
                if (prevPassword != changedPassword) {
                  delegator.showSnackBar(changedMsg, _twoSeconds);
                } else {
                  delegator.showSnackBar(unchangedMsg, _twoSeconds);
                }
              }
            );
          }
        )
      );
    }
  }

  void onFeedbackClicked(context) {
    Utils.showAppDialog(context,
      AppLocalizations.of(context).leaveFeedbackTitle,
      AppLocalizations.of(context).leaveFeedbackBody,
      null,
        () => OpenAppstore.launch(androidAppId: 'com.giantsol.blue_diary'),
    );
  }
}
