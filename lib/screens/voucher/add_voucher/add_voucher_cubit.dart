import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/screens/voucher/add_voucher/add_voucher_state.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';

import '../../../enums/processing/dialog_name_enum.dart';
import '../../../enums/processing/notify_message_enum.dart';
import '../../../enums/processing/process_state_enum.dart';
import '../../../objects/voucher_related/voucher.dart';
import '../../../objects/voucher_related/voucher_argument.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

class AddVoucherCubit extends Cubit<AddVoucherState> {
  AddVoucherCubit()
      : super(AddVoucherState(
          voucherArgument: VoucherArgument(
            isLimited: false,
            isPercentage: false,
            hasEndTime: false,
            isVisible: true,
            isEnabled: true,
            startTime: DateTime.now(),

            enDescription: '',
            viDescription: '',
          ),
        ));

  void updateVoucherArgument(VoucherArgument voucherArgument) {
    final now = DateTime.now();
    emit(state.copyWith(
      voucherArgument: voucherArgument.copyWith(
        isLimited: voucherArgument.isLimited,
        isPercentage: voucherArgument.isPercentage,
        hasEndTime: voucherArgument.hasEndTime,
        isVisible: voucherArgument.isVisible,
        isEnabled: voucherArgument.isEnabled,
        startTime: voucherArgument.startTime ?? now,
        maxUsagePerPerson: voucherArgument.maxUsagePerPerson,
        endTime: (voucherArgument.hasEndTime ?? false)
            ? (voucherArgument.endTime ?? now.add(const Duration(days: 7)))
            : null,
        maximumUsage: (voucherArgument.isLimited ?? false) ? voucherArgument.maximumUsage : 0,
        usageLeft: (voucherArgument.isLimited ?? false) ? voucherArgument.usageLeft : 0,
        maximumDiscountValue: (voucherArgument.isPercentage ?? false) ? voucherArgument.maximumDiscountValue : 0.0,
        enDescription: voucherArgument.enDescription ?? '',
        viDescription: voucherArgument.viDescription ?? '',
      ),
    ));
  }

  void toSuccess() {
    emit(state.copyWith(processState: ProcessState.success));
  }

  void toIdle() {
    emit(state.copyWith(processState: ProcessState.idle));
  }

  Future<void> addVoucher() async {
    emit(state.copyWith(processState: ProcessState.loading));
    try {
      Voucher voucher = state.voucherArgument!.createVoucher();
      await Firebase().addVoucher(voucher);
      emit(state.copyWith(
          processState: ProcessState.success,
          dialogName: DialogName.success,
          notifyMessage: NotifyMessage.msg17));
    } catch (e, stack) {
      if (kDebugMode) {
        print('Add voucher error: $e');
      }
      if (kDebugMode) {
        print(stack);
      }
      emit(state.copyWith(
          processState: ProcessState.failure,
          dialogName: DialogName.failure,
          notifyMessage: NotifyMessage.msg18));
    }
  }

  Future<void> generateEnDescription() async {
    if (state.voucherArgument!.isEnEmpty) {
      String enDescription = '';
      String viDescription = '';

      if (!state.voucherArgument!.isViEmpty) {
        enDescription = await translateIntoEnglish(
          state.voucherArgument?.viDescription ?? '',
        );

        updateVoucherArgument(
            state.voucherArgument!.copyWith(enDescription: enDescription));
      }
      else {
        enDescription = await generateDescription(state.voucherArgument!);
        viDescription = await translateIntoVietnamese(enDescription);

        updateVoucherArgument(state.voucherArgument!.copyWith(
            enDescription: enDescription,
            viDescription: viDescription
        ));
      }

      emit(state.copyWith(
          processState: ProcessState.success,
          dialogName: DialogName.success,
          notifyMessage: NotifyMessage.msg21));
    }
  }

  Future<void> generateViDescription() async {
    if (state.voucherArgument!.isViEmpty) {
      String enDescription = '';
      String viDescription = '';

      if (!state.voucherArgument!.isEnEmpty) {
        viDescription = await translateIntoVietnamese(
          state.voucherArgument?.enDescription ?? '',
        );

        updateVoucherArgument(
            state.voucherArgument!.copyWith(viDescription: viDescription));
      }
      else {
        enDescription = await generateDescription(state.voucherArgument!);
        viDescription = await translateIntoVietnamese(enDescription);

        updateVoucherArgument(state.voucherArgument!.copyWith(
            enDescription: enDescription,
            viDescription: viDescription
        ));
      }

      emit(state.copyWith(
          processState: ProcessState.success,
          dialogName: DialogName.success,
          notifyMessage: NotifyMessage.msg21));
    }
  }
}

Future<String> translateIntoEnglish(String inputText) async {
  try {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    final dio = Dio();
    final response = await dio.post(
      url,
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: {
        'contents': [{
          'parts': [{
            'text': 'Translate this Vietnamese text to English changing special character like \$ or %. Return only the translated text: $inputText'
          }]
        }],
        'generationConfig': {
          'temperature': 0.2,
          'topP': 0.8,
          'maxOutputTokens': 100
        }
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = response.data;
      final candidates = jsonResponse['candidates'] as List;
      if (candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        final parts = content['parts'] as List;
        if (parts.isNotEmpty) {
          final translatedText = parts[0]['text'] as String;
          return translatedText.trim();
        }
      }
    }

    return inputText;
  } catch (e) {
    if (kDebugMode) {
      print('Error translating to English: $e');
    }
    return inputText;
  }
}

Future<String> translateIntoVietnamese(String inputText) async {
  try {
    if (inputText.isEmpty) {
      return '';
    }

    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    final dio = Dio();
    final response = await dio.post(
      url,
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: {
        'contents': [{
          'parts': [{
            'text': 'INSTRUCTION: Translate the following English text to Vietnamese without changing special character like \$ or %.\n\nENGLISH TEXT: $inputText\n\nTRANSLATION (in Vietnamese only, no English explanation or notes):'
          }]
        }],
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = response.data;
      final candidates = jsonResponse['candidates'] as List;
      if (candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        final parts = content['parts'] as List;
        if (parts.isNotEmpty) {
          final translatedText = parts[0]['text'] as String;
          return translatedText.trim();
        }
      }
    }

    return inputText;
  } catch (e) {
    if (kDebugMode) {
      print('Error translating to Vietnamese: $e');
    }
    return inputText;
  }
}

Future<String> generateDescription(VoucherArgument inputVoucher) async {
  try {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    final dio = Dio();
    final voucherInfo = inputVoucher;
    final promptDetails = [
      'Discount value: ${voucherInfo.discountValue}',
      ',Minimum purchase amount: ${voucherInfo.minimumPurchase}',
      'Discount type: ${voucherInfo.isPercentage ?? false ? 'Percentage' : 'Fixed amount'}',
      if (voucherInfo.isPercentage ?? false) 'Maximum discount value: ${voucherInfo.maximumDiscountValue}',
      'Usage limit per person: ${voucherInfo.maxUsagePerPerson}',
      if (voucherInfo.isLimited ?? false) 'Maximum total usage: ${voucherInfo.maximumUsage}',
      'Valid from: ${voucherInfo.startTime?.toString().substring(0, 10)}',
      if (voucherInfo.hasEndTime ?? false) 'Valid until: ${voucherInfo.endTime?.toString().substring(0, 10)}',
    ].join('\n');
    final response = await dio.post(
      url,
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: {
        'contents': [{
          'parts': [{
            'text': 'Create a short, professional 1-2 sentence voucher description in English based on these details:\n$promptDetails\n\nMake it concise, appealing and marketing-oriented. Return ONLY the description, no additional text, and use special character like \$ or % if needed.'
          }]
        }],
        'generationConfig': {
          'temperature': 0.2,
          'topP': 0.8,
          'maxOutputTokens': 100
        }
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = response.data;
      final candidates = jsonResponse['candidates'] as List;
      if (candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        final parts = content['parts'] as List;
        if (parts.isNotEmpty) {
          final translatedText = parts[0]['text'] as String;
          return translatedText.trim();
        }
      }
    }

    return '';
  } catch (e) {
    if (kDebugMode) {
      print('Error generating description: $e');
    }
    return '';
  }
}

