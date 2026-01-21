import 'package:gptom/utils/json_keys.dart';

class GpTomRegisterRequest {
  final String? originReferenceNum;
  final String? clientId;
  final bool persistPending;

  const GpTomRegisterRequest({required this.originReferenceNum, this.clientId, this.persistPending = true});

  Map<String, dynamic> toJson() => {
    JsonKeys.originReferenceNum: originReferenceNum,
    JsonKeys.clientId: clientId,
    JsonKeys.persistPending: persistPending,
  };
}
