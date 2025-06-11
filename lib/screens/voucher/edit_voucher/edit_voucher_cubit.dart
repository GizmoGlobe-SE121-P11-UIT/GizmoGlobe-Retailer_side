import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:gizmoglobe_client/screens/voucher/edit_voucher/edit_voucher_state.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

import '../../../enums/processing/dialog_name_enum.dart';
import '../../../enums/processing/notify_message_enum.dart';
import '../../../enums/processing/process_state_enum.dart';
import '../../../objects/voucher_related/voucher.dart';
import '../../../objects/voucher_related/voucher_argument.dart';

class EditVoucherCubit extends Cubit<EditVoucherState> {
  EditVoucherCubit() : super(const EditVoucherState());

  void initialize(Voucher voucher) {
    final voucherArgument = VoucherArgument.fromVoucher(voucher);
    emit(state.copyWith(
      voucherArgument: voucherArgument,
      processState: ProcessState.idle,
    ));
  }

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

  void editVoucher() async {
    emit(state.copyWith(processState: ProcessState.loading));
    try {
      Voucher voucher = state.voucherArgument!.createVoucher();
      await Firebase().updateVoucher(voucher);
      emit(state.copyWith(
          processState: ProcessState.success,
          dialogName: DialogName.success,
          notifyMessage: NotifyMessage.msg22));
    } catch (e, stack) {
      print('Edit voucher error: $e');
      print(stack);
      emit(state.copyWith(
          processState: ProcessState.failure,
          dialogName: DialogName.failure,
          notifyMessage: NotifyMessage.msg23));
    }
  }

  Future<void> generateEnDescription() async {
    String enDescription = '';
    if (!state.voucherArgument!.isViEmpty) {
      enDescription = await translateIntoEnglish(
        state.voucherArgument?.viDescription ?? '',
      );
    } else {
      enDescription = await generateEnglishDescription(state.voucherArgument!);
    }
    updateVoucherArgument(state.voucherArgument!.copyWith(enDescription: enDescription));
    emit(state.copyWith(
        processState: ProcessState.success,
        dialogName: DialogName.success,
        notifyMessage: NotifyMessage.msg21));
  }

  Future<void> generateViDescription() async {
    String viDescription = '';
    if (!state.voucherArgument!.isEnEmpty) {
      viDescription = await translateIntoVietnamese(
        state.voucherArgument?.enDescription ?? '',
      );
    } else {
      viDescription = await generateVietnameseDescription(state.voucherArgument!);
    }
    updateVoucherArgument(state.voucherArgument!.copyWith(viDescription: viDescription));
    emit(state.copyWith(
        processState: ProcessState.success,
        dialogName: DialogName.success,
        notifyMessage: NotifyMessage.msg21));
  }
}

Future<String> translateIntoEnglish(String inputText) async {
  try {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=[0m$apiKey';

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
    print('Error translating to English: $e');
    return inputText;
  }
}

Future<String> generateEnglishDescription(VoucherArgument inputVoucher) async {
  try {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    final dio = Dio();
    final voucherInfo = inputVoucher;
    final promptDetails = [
      'Discount value: [0m${voucherInfo.discountValue}',
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
    print('Error generating English description: $e');
    return '';
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
    print('Error translating to Vietnamese: $e');
    return inputText;
  }
}

Future<String> generateVietnameseDescription(VoucherArgument inputVoucher) async {
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
            'text': 'Create a short, professional 1-2 sentence voucher description in Vietnamese based on these details:\n$promptDetails\n\nMake it concise, appealing and marketing-oriented. Return ONLY the description, no additional text special character like \$ or % if needed.'
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
    print('Error generating Vietnamese description: $e');
    return '';
  }
}

