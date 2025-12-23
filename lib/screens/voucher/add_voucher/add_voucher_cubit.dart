import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/screens/voucher/add_voucher/add_voucher_state.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';

import '../../../enums/processing/dialog_name_enum.dart';
import '../../../enums/processing/notify_message_enum.dart';
import '../../../enums/processing/process_state_enum.dart';
import '../../../enums/voucher_related/distribution_type.dart';
import '../../../objects/voucher_related/voucher.dart';
import '../../../objects/voucher_related/voucher_argument.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:genai/genai.dart';

class AddVoucherCubit extends Cubit<AddVoucherState> {
  AddVoucherCubit()
      : super(AddVoucherState(
          voucherArgument: VoucherArgument(
            isLimited: false,
            isPercentage: false,
            hasEndTime: false,
            distributionType: DistributionType.public,
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
        redeemPrice: voucherArgument.redeemPrice,
        voucherName: voucherArgument.voucherName,
        isEnabled: voucherArgument.isEnabled,
        startTime: voucherArgument.startTime ?? now,
        maxUsagePerPerson: voucherArgument.maxUsagePerPerson,
        endTime: (voucherArgument.hasEndTime ?? false)
            ? (voucherArgument.endTime ?? now.add(const Duration(days: 7)))
            : null,
        maximumUsage: (voucherArgument.isLimited ?? false) ? voucherArgument.maximumUsage : 0,
        usageLeft: (voucherArgument.isLimited ?? false) ? voucherArgument.usageLeft : 0,
        maximumDiscountValue: (voucherArgument.isPercentage ?? false) ? voucherArgument.maximumDiscountValue : 0,
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

    final request = AIRequestModel(
      modelApiProvider: ModelAPIProvider.gemini, // or openai, anthropic, etc.
      model: "gemini-2.0-flash",
      apiKey: apiKey,
      url: kGeminiUrl,
      systemPrompt: "You are a translator, and you are translating the following Vietnamese text to English.",
      userPrompt: inputText,
      stream: false,
    );

    final answer = await executeGenAIRequest(request);

    return answer ?? inputText;
  } catch (e) {
    if (kDebugMode) {
      print('Error translating to English: $e');
    }
    return inputText;
  }
}

Future<String> translateIntoVietnamese(String inputText) async {
  try {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    final request = AIRequestModel(
      modelApiProvider: ModelAPIProvider.gemini,
      model: "gemini-2.0-flash",
      apiKey: apiKey,
      url: kGeminiUrl,
      systemPrompt: "You are a translator, and you are translating the following Englist text to Vietnamese.",
      userPrompt: inputText,
      stream: false,
    );

    final answer = await executeGenAIRequest(request);

    return answer ?? inputText;
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

    final voucherInfo = inputVoucher;
    final promptDetails = [
      'Discount value: ${voucherInfo.discountValue}${(voucherInfo.isPercentage! ? '%' : '₫')}',
      'Minimum purchase amount: ${voucherInfo.minimumPurchase}₫',
      'Discount type: ${voucherInfo.isPercentage ?? false ? 'Percentage' : 'Fixed amount'}',
      if (voucherInfo.isPercentage ?? false) 'Maximum discount value: ${voucherInfo.maximumDiscountValue}₫',
      'Usage limit per person: ${voucherInfo.maxUsagePerPerson}',
      if (voucherInfo.isLimited ?? false) 'Maximum total usage: ${voucherInfo.maximumUsage}',
      'Valid from: ${voucherInfo.startTime?.toString().substring(0, 10)}',
      if (voucherInfo.hasEndTime ?? false) 'Valid until: ${voucherInfo.endTime?.toString().substring(0, 10)}',
      'Claim type: ${voucherInfo.distributionType?.description}',
      if (voucherInfo.distributionType == DistributionType.rewards) 'Redeem price: ${voucherInfo.redeemPrice} points',
    ].join('\n');

    final request = AIRequestModel(
      modelApiProvider: ModelAPIProvider.gemini, // or openai, anthropic, etc.
      model: "gemini-2.0-flash",
      apiKey: apiKey,
      url: kGeminiUrl,
      systemPrompt: "You are an assistant for an online store, and you are making description for vouchers.",
      userPrompt: promptDetails,
      stream: false,
    );

    final answer = await executeGenAIRequest(request);

    return answer ?? promptDetails;
  } catch (e) {
    if (kDebugMode) {
      print('Error generating description: $e');
    }
    return '$e';
  }
}
